import admin from "firebase-admin";
import * as functions from "firebase-functions";
//import { user } from "firebase-functions/lib/providers/auth";

import { getPathStorageFromUrl, getDirectoryStorageFromUrl } from "./storage";

import { deleteVideo, uploadVideoToPublitio } from "./publitio";

import { FlybisBell, addBell, deleteBell } from "./bell";

import {
  encodeFromStorageFileImageToBlurHash,
  encodeFromPublitioFileImageToBlurHash,
} from "./blurhash";

export interface FlybisPost {
  // User
  userId: string;

  // Post
  postId: string;
  postTitle: string;
  postLocation: string;
  postDescription: string;
  postContents: Array<FlybisPostContent>;
  postValidity: Boolean;
  postPopularity: Number;
  postUrls: Array<string>;
  postTags: Array<string>;
  postMentions: Array<string>;

  // Likes
  likesCount: Number;

  // Dislikes
  dislikesCount: Number;

  // Timestamp
  timestamp: admin.firestore.Timestamp;
  timestampDuration: admin.firestore.Timestamp;
  timestampPopularity: admin.firestore.Timestamp;
}

export interface FlybisPostContent {
  // Content
  contentId: string;
  contentUrl: string;
  contentType: "text" | "image" | "video";
  contentThumbnail: string;
  contentAspectRatio: Number;

  // BlurHash
  blurHash: string;

  // Process
  hasProcessed: Boolean;
}

export async function createPostEvent(snapshot, context) {
  try {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const ref = snapshot.ref;

    const flybisPost = snapshot.data() as FlybisPost;

    const timestamp = flybisPost.timestamp;
    const timestampFormated =
      timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000;

    const minimumPostDurations = await admin
      .firestore()
      .collection("flybis")
      .doc("public")
      .collection("minimumPostDurations")
      .orderBy("timestamp", "desc")
      .limit(1)
      .get();
    const minimumPostDuration = minimumPostDurations.docs[0].data()
      .minimumPostDuration;

    const timestampDuration = admin.firestore.Timestamp.fromDate(
      new Date(timestampFormated + minimumPostDuration)
    );
    flybisPost.timestampDuration = timestampDuration;

    // Process Content by Type
    for (let i = 0; i < flybisPost.postContents.length; i++) {
      if (flybisPost.postContents[i].contentType === "image") {
        flybisPost.postContents[
          i
        ].blurHash = await encodeFromStorageFileImageToBlurHash(
          getPathStorageFromUrl(flybisPost.postContents[i].contentUrl)
        );
      }

      if (flybisPost.postContents[i].contentType === "video") {
        const video = await uploadVideoToPublitio(
          getPathStorageFromUrl(flybisPost.postContents[i].contentUrl)
        );

        if (video !== null) {
          flybisPost.postContents[i].contentId = video.id;
          flybisPost.postContents[i].contentUrl = video.downloadUrl;
          flybisPost.postContents[i].contentThumbnail = video.thumbnailUrl;
          flybisPost.postContents[i].contentAspectRatio = video.aspectRatio;
          flybisPost.postContents[i].hasProcessed = true;
          flybisPost.postContents[
            i
          ].blurHash = await encodeFromPublitioFileImageToBlurHash(
            flybisPost.postContents[i].contentThumbnail
          );
        }
      }
    }

    await admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("posts")
      .doc(postId)
      .update(flybisPost);

    // Get all the follower's from the user who made the post.
    const followersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers");

    // Add new post to each follower's timeline.
    const followersQuery = await followersRef.get();
    followersQuery.forEach(async (followerDoc) => {
      const followerId = followerDoc.id;

      const followerTimelinePostRef = admin
        .firestore()
        .collection("timelines")
        .doc(followerId)
        .collection("posts")
        .doc(postId);

      await followerTimelinePostRef.set(flybisPost);

      const flybisBell = {
        ref: ref,
        senderId: userId,
        receiverId: followerId,
        bellContent: {
          contentId: postId,
          contentType: flybisPost.postContents[0].contentType,
          contentText:
            flybisPost.postTitle.length > 0 ? flybisPost.postTitle : "",
          contentImage:
            flybisPost.postContents[0].contentType === "image"
              ? flybisPost.postContents[0].contentUrl
              : flybisPost.postContents[0].contentThumbnail,
        },
        bellMode: "post",
        timestamp: admin.firestore.Timestamp.now(),
      } as FlybisBell;

      await addBell(flybisBell);
    });
  } catch (error) {
    console.error(error);
  }
}

export async function updatePostEvent(change, context) {
  try {
    const post = change.after.data() as FlybisPost;
    const userId = context.params.userId;
    const postId = context.params.postId;

    await setPostPopularity(userId, postId, post);
  } catch (error) {
    console.error(error);
  }
}

export async function deletePostEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  const userId = context.params.userId;
  const postId = context.params.postId;

  const ref = snapshot.ref;

  const flybisPost = snapshot.data() as FlybisPost;

  const followersRef = admin
    .firestore()
    .collection("followers")
    .doc(userId)
    .collection("followers");

  const followersQuery = await followersRef.get();
  followersQuery.forEach(async (followerDoc) => {
    const followerId = followerDoc.id;

    const timelinePost = await admin
      .firestore()
      .collection("timelines")
      .doc(followerId)
      .collection("posts")
      .doc(postId)
      .get();

    if (timelinePost.exists) {
      await timelinePost.ref.delete();

      await deleteBell(followerId, ref);
    }
  });

  const likes = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .collection("likes")
    .get();
  likes.forEach(async (likeDoc) => {
    if (likeDoc.exists) {
      await deleteBell(likeDoc.id, likeDoc.ref);

      await likeDoc.ref.delete();
    }
  });

  const dislikes = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .collection("dislikes")
    .get();
  dislikes.forEach(async (dislikeDoc) => {
    if (dislikeDoc.exists) {
      await deleteBell(dislikeDoc.id, dislikeDoc.ref);

      await dislikeDoc.ref.delete();
    }
  });

  console.log(flybisPost);

  if (flybisPost.postContents !== null) {
    for (let i = 0; i < flybisPost.postContents.length; i++) {
      if (flybisPost.postContents[i].contentType === "image") {
        const filePath = getPathStorageFromUrl(
          flybisPost.postContents[i].contentUrl
        );

        try {
          await admin.storage().bucket().file(filePath).delete();
          console.log("Success to delete file", filePath);
        } catch (error) {
          console.error("Error to delete file", filePath, error);
        }
      }

      if (flybisPost.postContents[i].contentType === "video") {
        await deleteVideo(flybisPost.postContents[i].contentId);
      }
    }
  }

  const directory = getDirectoryStorageFromUrl(
    flybisPost.postContents[0].contentUrl
  );

  try {
    await admin.storage().bucket(directory).deleteFiles();
    console.log("Success to delete file", directory);
  } catch (error) {
    console.error("Error to delete directory", directory, error);
  }
}

export async function createPostLikeEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context
) {
  const userId = context.params.userId;
  const postId = context.params.postId;
  const senderId = context.params.senderId;

  const ref = snapshot.ref;

  const doc = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .get();

  if (doc.exists) {
    const post = doc.data() as FlybisPost;

    await setPostPopularity(userId, postId, post);

    const flybisBell = {
      ref: ref,
      senderId: senderId,
      receiverId: userId,
      bellContent: {
        contentId: post.postId,
        contentType: post.postContents[0].contentType,
        contentText: post.postTitle.length > 0 ? post.postTitle : "",
        contentImage:
          post.postContents[0].contentType === "image"
            ? post.postContents[0].contentUrl
            : post.postContents[0].contentThumbnail,
      },
      bellMode: "like",
      timestamp: admin.firestore.Timestamp.now(),
    } as FlybisBell;

    await addBell(flybisBell);
  }
}

export async function deletePostLikeEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context
) {
  const userId = context.params.userId;
  const postId = context.params.postId;
  //const senderId = context.params.senderId;

  const ref = snapshot.ref;

  const doc = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .get();

  if (doc.exists) {
    const post = doc.data() as FlybisPost;

    await setPostPopularity(userId, postId, post);
  }

  await deleteBell(userId, ref);

  await admin.firestore().collection("comments").doc(userId).collection("posts").doc(postId).delete();
}

export async function createPostDislikeEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context
) {
  const userId = context.params.userId;
  const postId = context.params.postId;
  //const senderId = context.params.senderId;

  const doc = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .get();

  if (doc.exists) {
    const post = doc.data() as FlybisPost;

    await setPostPopularity(userId, postId, post);
  }
}

export async function deletePostDislikeEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context
) {
  const userId = context.params.userId;
  const postId = context.params.postId;
  //const senderId = context.params.senderId;

  const doc = await admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts")
    .doc(postId)
    .get();

  if (doc.exists) {
    const post = doc.data() as FlybisPost;

    await setPostPopularity(userId, postId, post);
  }
}

async function setPostPopularity(
  userId: string,
  postId: string,
  flybisPost: FlybisPost
) {
  try {
    const likesCount = await (
      await admin
        .firestore()
        .collection("posts")
        .doc(userId)
        .collection("posts")
        .doc(postId)
        .collection("likes")
        .get()
    ).docs.length;
    console.log("Post Likes", likesCount);

    const dislikesCount = await (
      await admin
        .firestore()
        .collection("posts")
        .doc(userId)
        .collection("posts")
        .doc(postId)
        .collection("dislikes")
        .get()
    ).docs.length;
    console.log("Post Dislikes", dislikesCount);

    const total = likesCount + dislikesCount;
    console.log("Post Total Likes And Dislikes", total);

    const popularity = calculatePopularityOfPost(likesCount, total, 0.95);
    console.log("Post Popularity", popularity);

    const timestamp = flybisPost.timestamp;
    const timestampFormated =
      timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000;
    console.log("Post Timestamp", timestamp);

    const timestampDuration = flybisPost.timestampDuration;
    const timestampDurationFormated =
      timestampDuration.seconds * 1000 +
      timestampDuration.nanoseconds / 1000000;
    console.log("Post Timestamp Duration", timestampDuration);

    const timestampPopularity = admin.firestore.Timestamp.fromDate(
      new Date(
        calculateDurationOfPost(
          likesCount,
          dislikesCount,
          popularity,
          timestampFormated,
          timestampDurationFormated
        )
      )
    );
    const timestampPopularityFormated =
      timestampPopularity.seconds * 1000 +
      timestampPopularity.nanoseconds / 1000000;
    console.log("Post Timestamp Popularity", timestampPopularity);

    const timeLeft =
      timestampDurationFormated + timestampPopularityFormated - Date.now();
    const timeLeftHour = timeLeft * 60 * 60 * 1000;
    const timeLeftMinute = timeLeft * 60 * 1000;
    const timeLeftSecond = timeLeft * 1000;
    const timeLeftFormated =
      timeLeftHour + "h:" + timeLeftMinute + "m:" + timeLeftSecond + "s";
    console.log("Post Time Left", timeLeftFormated);

    const validity = checkValidityOfPost(
      timestampDurationFormated,
      timestampPopularityFormated
    );
    console.log("Post Validity", validity);

    // Update 'flybisPost'
    flybisPost.postValidity = validity;
    flybisPost.postPopularity = popularity;
    flybisPost.likesCount = likesCount;
    flybisPost.dislikesCount = dislikesCount;
    flybisPost.timestampPopularity = timestampPopularity;

    // Update original 'flybisPost'
    await admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("posts")
      .doc(postId)
      .update(flybisPost);

    // Update follower's timeline 'flybisPost'
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers");
    const querySnapshot = await userFollowersRef.get();
    querySnapshot.forEach((doc) => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timelines")
        .doc(followerId)
        .collection("posts")
        .doc(postId)
        .get()
        .then((docChild) => {
          if (docChild.exists) {
            docChild.ref.update(flybisPost);
          }

          return;
        })
        .catch((error) => {
          return;
        });
    });
  } catch (error) {
    console.error(error);
  }
}

function calculatePopularityOfPost(
  likes: number,
  total: number,
  confidence: number
) {
  const pnormaldist = require("pnormaldist");

  if (total === 0) {
    return 0;
  }

  const z = pnormaldist(1 - (1 - confidence) / 2);
  const phat = (1.0 * likes) / total;
  const popularity =
    (phat +
      (z * z) / (2 * total) -
      z * Math.sqrt((phat * (1 - phat) + (z * z) / (4 * total)) / total)) /
    (1 + (z * z) / total);

  return popularity;
}

const POPULARITY_POST_DURATION = 60 * 60 * 1000;

function calculateDurationOfPost(
  likesCount,
  dislikesCount,
  popularity,
  timestamp,
  timestampDuration
) {
  //const dataRelevancy = Date.now() - timestamp;

  const timestampPopularity =
    timestampDuration +
    Math.round(
      popularity * (POPULARITY_POST_DURATION * (likesCount - dislikesCount))
    );

  return timestampPopularity;
}

function checkValidityOfPost(
  timestampPopularityFormated,
  timestampDurationFormated
) {
  if (timestampPopularityFormated - Date.now() <= 0) {
    if (timestampDurationFormated - Date.now() <= 0) {
      return false;
    }
  }

  return true;
}

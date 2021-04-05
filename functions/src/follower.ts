import admin from "firebase-admin";
import * as functions from "firebase-functions";

import { FlybisBell, addBell, deleteBell } from "./bell";
import { FlybisPost } from "./post";
import { FlybisUser } from "./user";

export async function createFollowerEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  const userId = context.params.userId;
  const followerId = context.params.followerId;

  // 1. Create followed user's posts.
  const followedUserPostsRef = admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts");

  // 2. Create following user's timeline.
  const timelinePostsRef = admin
    .firestore()
    .collection("timelines")
    .doc(followerId)
    .collection("posts");

  // 3. Get the followed user's posts.
  const querySnapshot = await followedUserPostsRef.get();
  //console.log('QuerySnapshot', querySnapshot.size);

  // 4. Add each user post to following user's timeline.
  querySnapshot.forEach((doc) => {
    if (doc.exists) {
      const postId = doc.id;
      const flybisPost = doc.data() as FlybisPost;

      timelinePostsRef.doc(postId).set(flybisPost);
    }
  });

  await updateFollowersAndFollowing(userId, followerId);

  const flybisBell = {
    ref: snapshot.ref,
    senderId: followerId,
    receiverId: userId,
    bellContent: {
      contentId: "",
      contentType: "",
      contentText: "",
      contentImage: "",
    },
    bellMode: "follow",
    timestamp: admin.firestore.Timestamp.now(),
  } as FlybisBell;

  await addBell(flybisBell);
}

export async function deleteFollowerEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const followerTimelinePostsQuery = admin
      .firestore()
      .collection("timelines")
      .doc(followerId)
      .collection("posts")
      .where("uid", "==", userId);

    const followerTimeline = await followerTimelinePostsQuery.get();
    followerTimeline.forEach((followerTimelineDoc) => {
      if (followerTimelineDoc.exists) {
        followerTimelineDoc.ref.delete();
      }
    });

    await updateFollowersAndFollowing(userId, followerId);

    await deleteBell(userId, snapshot.ref);
  } catch (error) {
    console.error(error);
  }
}

async function updateFollowersAndFollowing(userId: string, followerId: string) {
  try {
    const followers = await admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers")
      .get();
    await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .update({
        followersCount: followers.empty === false ? followers.docs.length : 0,
      });

    const followings = await admin
      .firestore()
      .collection("followings")
      .doc(followerId)
      .collection("followings")
      .get();
    await admin
      .firestore()
      .collection("users")
      .doc(followerId)
      .update({
        followingsCount:
          followings.empty === false ? followings.docs.length : 0,
      });
  } catch (error) {
    console.error(error);
  }
}

import admin from "firebase-admin";
import * as functions from "firebase-functions";
import { user } from "firebase-functions/lib/providers/auth";

import { app } from "./app";
import { generateVirgilJwt } from "./generate-virgil-jwt";

admin.initializeApp();

// This HTTPS endpoint can only be accessed by your Firebase Users.
// Requests need to be authorized by providing an `Authorization` HTTP header
// with value `Bearer <Firebase ID Token>`.
export const api = functions.https.onRequest(app);

export const getVirgilJwt = functions.https.onCall((_data, context) => {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError("unauthenticated", "The function must be called " +
      "while authenticated.");
  }

  return {
    token: generateVirgilJwt(context.auth.uid).toString()
  };
});

export const onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    console.log("Follower Created", snapshot.data());
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1. Create followed user"s posts.
    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts");

    // 2. Create following user"s timeline.
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    // 3. Get the followed user"s posts.
    const querySnapshot = await followedUserPostsRef.get();
    console.log("QuerySnapshot", querySnapshot.size);

    // 4. Add each user post to following user"s timeline.
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });

    setFollowersAndFollowing(userId, followerId);
  });

export const onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snapshot, context) => {
    console.log("Follower Deleted", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });

    setFollowersAndFollowing(userId, followerId);
  });

function setFollowersAndFollowing(userId, followerId) {
  admin
    .firestore()
    .collection("followers")
    .doc(userId).collection("userFollowers").get().then((doc) => {
      const docs = doc.docs;

      admin
        .firestore()
        .collection("users")
        .doc(userId).update({
          followers: doc.empty === false ? docs.length : 0
        });
    });

  admin
    .firestore()
    .collection("following")
    .doc(followerId).collection("userFollowing").get().then((doc) => {
      const docs = doc.docs;

      admin
        .firestore()
        .collection("users")
        .doc(followerId).update({
          following: doc.empty === false ? docs.length : 0
        });
    });
}

const MINIMUM_POST_DURATION = 24 * 60 * 60 * 1000;

export const onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    console.log("Post Created", snapshot.data());
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const timestamp = snapshot.data().timestamp;
    const timestampDuration = admin.firestore.Timestamp.fromDate(new Date((timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000) + MINIMUM_POST_DURATION));

    admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("userPosts")
      .doc(postId)
      .update({ timestampDuration: timestampDuration });

    // Get all the follower"s from the user who made the post.
    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");
    const querySnapshot = await userFollowersRef.get();
    // Add new post to each follower"s timeline.
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .update({ timestampDuration: timestampDuration });
    });
  });

export const onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    console.log("Post Updated", change.after.data());
    const postUdpated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const likes = postUdpated.likes;
    let likesCount = 0;
    if (likes !== null) {
      Object.keys(likes).forEach((key) => {
        if (likes[key] === true) {
          likesCount = likesCount + 1;
        }
      });
    }
    console.log("Post Likes", likesCount);

    const dislikes = postUdpated.dislikes;
    let dislikesCount = 0;
    if (dislikes !== null) {
      Object.keys(dislikes).forEach((key) => {
        if (dislikes[key] === true) {
          dislikesCount = dislikesCount + 1;
        }
      });
    }
    console.log("Post Dislikes", dislikesCount);

    const total = likesCount + dislikesCount;
    console.log("Post Total Likes And Dislikes", total);

    const popularity = calculatePopularityOfPost(likesCount, total, 0.95);
    console.log("Post Popularity", popularity);

    const timestamp = postUdpated.timestamp;
    const timestampFormated = timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000;
    console.log("Post Timestamp", postUdpated.timestamp);

    const timestampDuration = postUdpated.timestampDuration;
    console.log("Post Timestamp Duration", timestampDuration);
    const timestampDurationFormated = timestampDuration.seconds * 1000 + timestampDuration.nanoseconds / 1000000;

    const timestampPopularity = admin.firestore.Timestamp.fromDate(new Date(calculateDurationOfPost(likesCount, dislikesCount, popularity, timestampFormated, timestampDurationFormated)));
    console.log("Post Timestamp Popularity", timestampPopularity);
    const timestampPopularityFormated = timestampPopularity.seconds * 1000 + timestampPopularity.nanoseconds / 1000000;

    const timeLeft = (timestampDurationFormated + timestampPopularityFormated) - Date.now();
    const timeLeftHour = timeLeft * 60 * 60 * 1000;
    const timeLeftMinute = timeLeft * 60 * 1000;
    const timeLeftSecond = timeLeft * 1000;
    const TimeLeftFormat = timeLeftHour + "h:" + timeLeftMinute + "m:" + timeLeftSecond + "s";
    console.log("Post Time Left", TimeLeftFormat);

    const validity = checkValidityOfPost(timestampDurationFormated, timestampPopularityFormated);
    console.log("Post Validity", validity);

    admin
      .firestore()
      .collection("posts")
      .doc(userId).collection("userPosts").doc(postId).update({
        validity: validity,
        popularity: popularity,
        timestampPopularity: timestampPopularity,

        likesCount: likesCount,
        dislikesCount: dislikesCount,
      });

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");
    const querySnapshot = await userFollowersRef.get();
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(docChild => {
          if (docChild.exists) {
            docChild.ref.update(postUdpated);
            docChild.ref.update({
              validity: validity,
              popularity: popularity,
              timestampPopularity: timestampPopularity,

              likesCount: likesCount,
              dislikesCount: dislikesCount,
            });
          }
          return;
        }).catch(error => {
          return;
        });

      admin
        .firestore()
        .collection("posts")
        .doc(userId).collection("userPosts").doc(postId).collection("likes").get().then((docChildTwo) => {
          const docs = docChildTwo.docs;

          docs.forEach(docChildThree => {
            admin
              .firestore()
              .collection("timeline")
              .doc(followerId).collection("timelinePosts").doc(postId).collection("likes").doc(docChildThree.id).set({});
          });
        });
      admin
        .firestore()
        .collection("posts")
        .doc(userId).collection("userPosts").doc(postId).collection("dislikes").get().then((docChildTwo) => {
          const docs = docChildTwo.docs;

          docs.forEach(docChildThree => {
            admin
              .firestore()
              .collection("timeline")
              .doc(followerId).collection("timelinePosts").doc(postId).collection("dislikes").doc(docChildThree.id).set({});
          });
        });
    });
  });

export const onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    console.log("Post Deleted", snapshot.data());
    const postUdpated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollowers");

    const querySnapshot = await userFollowersRef.get();
    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(docChild => {
          if (docChild.exists) {
            docChild.ref.delete(postUdpated);
          }
          return;
        }).catch(error => {
          return;
        });
    });
  });

function calculatePopularityOfPost(likes, total, confidence) {
  const pnormaldist = require("pnormaldist");

  if (total === 0) {
    return 0;
  }

  const z = pnormaldist(1 - (1 - confidence) / 2);
  const phat = 1.0 * likes / total;
  const popularity = (phat + z * z / (2 * total) - z * Math.sqrt((phat * (1 - phat) + z * z / (4 * total)) / total)) / (1 + z * z / total);

  return popularity;
}

const POPULARITY_POST_DURATION = 60 * 60 * 1000;

function calculateDurationOfPost(likesCount, dislikesCount, popularity, timestamp, timestampDuration) {
  const dataRelevancy = Date.now() - timestamp;

  const timestampPopularity = timestampDuration + Math.round(popularity * (POPULARITY_POST_DURATION * (likesCount - dislikesCount)));

  return timestampPopularity;
}

function checkValidityOfPost(timestampPopularityFormated, timestampDurationFormated) {
  if (timestampPopularityFormated - Date.now() <= 0) {
    if (timestampDurationFormated - Date.now() <= 0) {
      return false;
    }
  }
  return true;
}

export const onCreateActivityFeedItem = functions.firestore
  .document("/feed/{userId}/feedItems/{activityFeedItem}")
  .onCreate(async (snapshot, context) => {
    console.log("Activity Feed Item Created", snapshot.data());
    // Get user connected to the feed.
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();

    // Check if they have a notification token.
    const androidNotificationToken = doc.data().androidNotificationToken;
    if (androidNotificationToken) {
      // Send notification.
      sendNotification(androidNotificationToken, snapshot.data());

      console.log("With token for user, notification can be send", androidNotificationToken, snapshot.data());
    } else {
      console.log("Without token for user, cannot send notification");
    }

    function sendNotification(androidNotificationTokenChild, activityFeedItem) {
      let body;
      switch (activityFeedItem.type) {
        case "comment":
          body = `@${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
          break;

        case "like":
          body = `@${activityFeedItem.username} liked your post`;
          break;

        case "follow":
          body = `@${activityFeedItem.username} started following you`;
          break;

        default:
          break;
      }

      // Create message for pusn notification.
      const message = {
        notification: {
          body
        },
        token: androidNotificationTokenChild,
        data: { recipient: userId }
      };

      // Send message with admin messaging.
      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log("Successsfully sent message", response);
          return;
        })
        .catch(error => console.log("Error sending notification", error));
    }
  });

export const onCreateUser = functions.firestore
  .document("/users/{userId}")
  .onCreate(async (snapshot, context) => {
    console.log("User Created", snapshot.data());

    const ownerId = context.params.userId;
    const doc = snapshot.data();

    admin
      .firestore()
      .collection("usernames")
      .doc(doc.username).set({
        ownerId: ownerId,
      });
  });

export const onUpdateUser = functions.firestore
  .document("/users/{userId}")
  .onUpdate(async (change, context) => {
    console.log("User Updated", change.after.data());
    const userUdpated = change.after.data();
    const userId = context.params.userId;

    admin.auth().updateUser(userId, {
      email: userUdpated.email,
      //phoneNumber: userUdpated.phoneNumber,
      displayName: userUdpated.displayName,
      photoURL: userUdpated.photoURL,
    })
      .then(function (userRecord) {
        // See the UserRecord reference doc for the contents of userRecord.
        console.log("Successfully updated user", userRecord.toJSON());
      })
      .catch(function (error) {
        console.log("Error updating user:", error);
      });

    const feedRef = admin
      .firestore()
      .collection("feed");
    const querySnapshot = await feedRef.get();
    querySnapshot.forEach(doc => {
      const feedUserId = doc.id;
      admin
        .firestore()
        .collection("feed")
        .doc(feedUserId)
        .collection("feedItems")
        .doc(userId)
        .get()
        .then(docChild => {
          if (docChild.exists) {
            docChild.ref.update({
              username: userUdpated.username,
              userProfileImg: userUdpated.photoUrl
            });
          }
          return;
        }).catch(error => {
          return;
        });
    });

    const commentsRef = admin
      .firestore()
      .collection("comments");
    const commentsQuerySnapshot = await commentsRef.get();
    commentsQuerySnapshot.forEach(doc => {
      const commentPostId = doc.id;
      admin
        .firestore()
        .collection("comments")
        .doc(commentPostId)
        .collection("comments")
        .get()
        .then(docChild => {
          docChild.docs.forEach(docChildChild => {
            if (docChildChild.data().userId === userId) {
              admin.firestore().collection("comments")
                .doc(commentPostId)
                .collection("comments").doc(docChildChild.id).update({
                  username: userUdpated.username,
                  avatarUrl: userUdpated.photoUrl
                });
            }
          });
          return;
        }).catch(error => {
          return;
        });
    });
  });

/*
* Text Moderation Filter
*/
const capitalizeSentence = require("capitalize-sentence");
const badWords = require("bad-words");
const filter = new badWords();

// Moderates messages by lowering all uppercase messages and removing swearwords.
export const onCreateMessage = functions.firestore
  .document("/messages/{groupId}/userMessages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const message = snapshot.data();
    const groupId = context.params.groupId;
    const messageId = context.params.messageId;

    if (message && !message.sanitized && message.type == 0) {
      // Retrieved the message values.
      console.log("Retrieved message content:", message.content);

      // Run moderation checks on on the message and moderate if needed.
      const moderatedMessage = moderateMessage(message.content);

      // Update the Firebase DB with checked message.
      console.log("Message has been moderated. Saving to Firestore:", moderatedMessage);
      admin.firestore().collection("messages")
        .doc(groupId)
        .collection("userMessages").doc(messageId).update({
          content: moderatedMessage,
          sanitized: true,
          moderated: message.content !== moderatedMessage,
        });
    }

    return null;
  });

// Moderates the given message if appropriate.
function moderateMessage(message) {
  let messageLocal = message;

  // Re-capitalize if the user is Shouting.
  if (isShouting(message)) {
    console.log("User is shouting. Fixing sentence case...");
    messageLocal = stopShouting(message);
  }

  // Moderate if the user uses SwearWords.
  if (containsSwearwords(message)) {
    console.log("User is swearing. Moderating...");
    messageLocal = moderateSwearwords(message);
  }

  return messageLocal;
}

// Returns true if the string contains swearwords.
function containsSwearwords(message) {
  return message !== filter.clean(message);
}

// Hide all swearwords. e.g: Crap => ****.
function moderateSwearwords(message) {
  return filter.clean(message);
}

// Detect if the current message is shouting. i.e. there are too many Uppercase characters or exclamation points.
function isShouting(message) {
  return message.replace(/[^A-Z]/g, "").length > message.length / 2 || message.replace(/[^!]/g, "").length >= 3;
}

// Correctly capitalize the string as a sentence (e.g. uppercase after dots) and remove exclamation points.
function stopShouting(message) {
  return capitalizeSentence(message.toLowerCase()).replace(/!+/g, ".");
}
/*
* Text Moderation Filter - End
*/

/*
* Image Moderation Filter
*/
const mkdirp = require("mkdirp-promise");
const vision = require("@google-cloud/vision");
const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");

const VERY_UNLIKELY = "VERY_UNLIKELY";
const BLURRED_FOLDER = "blurred";

const nude = require('nude');

// When an image is uploaded we check if it is flagged as Adult or Violence by the Cloud Vision API and if it is we blur it using ImageMagick.
export const blurOffensiveImages = functions.storage.object().onFinalize(async (object) => {
  // Ignore things we"ve already blurred.
  if (object.name.startsWith(`${BLURRED_FOLDER}/`)) {
    console.log(`Ignoring upload "${object.name}" because it was already blurred.`);
    return null;
  }

  /*
  // Check the image content using the Cloud Vision API.
  const visionClient = new vision.ImageAnnotatorClient();
  const data = await visionClient.safeSearchDetection(
    `gs://${object.bucket}/${object.name}`
  );

  const safeSearch = data[0].safeSearchAnnotation;
  console.log("SafeSearch results on image", safeSearch);

  // Tune these detection likelihoods to suit your app.
  // The current settings show the most strict configuration.
  // Docs: https://cloud.google.com/vision/docs/reference/rpc/google.cloud.vision.v1#google.cloud.vision.v1.SafeSearchAnnotation
  if (
    safeSearch.adult !== VERY_UNLIKELY ||
    safeSearch.spoof !== VERY_UNLIKELY ||
    safeSearch.medical !== VERY_UNLIKELY ||
    safeSearch.violence !== VERY_UNLIKELY ||
    safeSearch.racy !== VERY_UNLIKELY
  ) {
    console.log("Offensive image found. Blurring.");
    return blurImage(object.name, object.bucket, object.metadata);
  }
  */

  const tempLocalFile = path.join(os.tmpdir(), object.name);
  const tempLocalDir = path.dirname(tempLocalFile);
  const bucket = admin.storage().bucket(object.bucket);
  // Create the temp directory where the storage file will be downloaded.
  await mkdirp(tempLocalDir);
  console.log("Temporary directory has been created", tempLocalDir);
  // Download file from bucket.
  await bucket.file(object.name).download({ destination: tempLocalFile });
  console.log("The file has been downloaded to:", tempLocalFile);
  let result;
  nude.scan(tempLocalFile, function (res) {
    result = res;
  });
  if (result) {
    console.log("Offensive Image Found. Blurring.");
    return blurImage(object.name, object.bucket, object.metadata);
  }

  return null;
});

// Blurs the given image located in the given bucket using ImageMagick.
async function blurImage(filePath, bucketName, metadata) {
  const tempLocalFile = path.join(os.tmpdir(), filePath);
  const tempLocalDir = path.dirname(tempLocalFile);
  const bucket = admin.storage().bucket(bucketName);

  // Create the temp directory where the storage file will be downloaded.
  await mkdirp(tempLocalDir);
  console.log("Temporary directory has been created", tempLocalDir);

  // Download file from bucket.
  await bucket.file(filePath).download({ destination: tempLocalFile });
  console.log("The file has been downloaded to:", tempLocalFile);

  // Blur the image using ImageMagick.
  await spawn("convert", [tempLocalFile, "-channel", "RGBA", "-blur", "0x8", tempLocalFile]);
  console.log("Blurred image created at:", tempLocalFile);

  // Uploading the Blurred image.
  await bucket.upload(tempLocalFile, {
    destination: `${BLURRED_FOLDER}/${filePath}`,
    metadata: { metadata: metadata }, // Keeping custom metadata.
  });
  console.log("Blurred image uploaded to Storage at", filePath);

  // Clean up the local file.
  fs.unlinkSync(tempLocalFile);
  console.log("Deleted local file:", filePath);
}
/*
* Image Moderation Filter - End
*/
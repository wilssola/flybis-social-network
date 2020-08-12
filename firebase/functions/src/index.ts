import { user } from "firebase-functions/lib/providers/auth";

import * as functions from 'firebase-functions';
import admin from 'firebase-admin';
import { generateVirgilJwt } from './generate-virgil-jwt';

admin.initializeApp();

export const getVirgilJwt = functions.https.onCall(async (_data, context) => {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called ' +
      'while authenticated.');
  }
  
  // You can use context.auth.token.email, context.auth.token.phone_number or any unique value for identity
  const identity = context.auth.token.uid;

  const token = await generateVirgilJwt(identity);

  return {
    token: token.toString()
  };
});

const md5 = require("md5");

export const getAgoraSignalingToken = functions.https.onCall((_data, context) => {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called ' +
      'while authenticated.');
  }

  const expiredTime = parseInt((new Date().getTime() / 1000).toString()) + 3600 * 24;

  const account = context.auth.uid;
  const appId = process.env['AGORA_APP_ID'];
  const appCertificate = process.env['AGORA_PRIMARY_CERTIFICATE'];

  var token_items = [];

  // append SDK VERSION
  token_items.push("1");

  // append appid
  token_items.push(appId);

  // expired time
  token_items.push(expiredTime);

  // md5 account + appid + appcertificate + expiredtime
  token_items.push(md5(account + appId + appCertificate + expiredTime));

  return { 
    token: token_items.join(":").toString() 
  };
});

export const onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snapshot, context) => {
    //console.log("Follower Created", snapshot.data());
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
    //console.log("QuerySnapshot", querySnapshot.size);

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
    //console.log("Follower Deleted", snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("uid", "==", userId);

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
    //console.log("Post Created", snapshot.data());
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
        .collection("createdPosts")
        .doc(postId)
        .set({ timestamp: postCreated.timestamp });

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
    //console.log("Post Updated", change.after.data());
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
    //console.log("Post Likes", likesCount);

    const dislikes = postUdpated.dislikes;
    let dislikesCount = 0;
    if (dislikes !== null) {
      Object.keys(dislikes).forEach((key) => {
        if (dislikes[key] === true) {
          dislikesCount = dislikesCount + 1;
        }
      });
    }
    //console.log("Post Dislikes", dislikesCount);

    const total = likesCount + dislikesCount;
    //console.log("Post Total Likes And Dislikes", total);

    const popularity = calculatePopularityOfPost(likesCount, total, 0.95);
    //console.log("Post Popularity", popularity);

    const timestamp = postUdpated.timestamp;
    const timestampFormated = timestamp.seconds * 1000 + timestamp.nanoseconds / 1000000;
    //console.log("Post Timestamp", postUdpated.timestamp);

    const timestampDuration = postUdpated.timestampDuration;
    //console.log("Post Timestamp Duration", timestampDuration);
    const timestampDurationFormated = timestampDuration.seconds * 1000 + timestampDuration.nanoseconds / 1000000;

    const timestampPopularity = admin.firestore.Timestamp.fromDate(new Date(calculateDurationOfPost(likesCount, dislikesCount, popularity, timestampFormated, timestampDurationFormated)));
    //console.log("Post Timestamp Popularity", timestampPopularity);
    const timestampPopularityFormated = timestampPopularity.seconds * 1000 + timestampPopularity.nanoseconds / 1000000;

    const timeLeft = (timestampDurationFormated + timestampPopularityFormated) - Date.now();
    const timeLeftHour = timeLeft * 60 * 60 * 1000;
    const timeLeftMinute = timeLeft * 60 * 1000;
    const timeLeftSecond = timeLeft * 1000;
    const TimeLeftFormat = timeLeftHour + "h:" + timeLeftMinute + "m:" + timeLeftSecond + "s";
    //console.log("Post Time Left", TimeLeftFormat);

    const validity = checkValidityOfPost(timestampDurationFormated, timestampPopularityFormated);
    //console.log("Post Validity", validity);

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
    });
  });

export const onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    //console.log("Post Deleted", snapshot.data());
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

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("createdPosts")
        .doc(postId).delete();
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
    //console.log("Activity Feed Item Created", snapshot.data());
    // Get user connected to the feed.
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const doc = await userRef.get();

    // Check if they have a notification token.
    const androidNotificationToken = doc.data().androidNotificationToken;
    if (androidNotificationToken) {
      // Send notification.
      sendNotification(androidNotificationToken, snapshot.data());

      //console.log("With Notification Token", androidNotificationToken, snapshot.data());
    } else {
      //console.log("Without Notification Token");
    }

    function sendNotification(androidNotificationTokenChild, activityFeedItem) {
      let body;

      switch (activityFeedItem.type) {
        case "friend":
          body = `@${activityFeedItem.username} want be your friend`;
          break;

        case "message":
          switch(activityFeedItem.contentType) {
            case "image":
              body = `@${activityFeedItem.username} talked: ${activityFeedItem.content}`;
              break;
            default:
              body = `@${activityFeedItem.username} talked: ${activityFeedItem.content}`;
              break;
          }
          break;

        case "comment":
          body = `@${activityFeedItem.username} replied: ${activityFeedItem.data}`;
          break;

        case "like":
          body = `@${activityFeedItem.username} liked your post`;
          break;

        case "follow":
          body = `@${activityFeedItem.username} started following you`;
          break;

        default:
          body = `you has new notifications`;
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
          //console.log("Notification Sended", response);
          return;
        })
      //.catch(error => console.log("Notification Send Error", error));
    }
  });

export const onCreateUser = functions.firestore
  .document("/users/{userId}")
  .onCreate(async (snapshot, context) => {
    //console.log("User Created", snapshot.data());
    const uid = context.params.userId;
    const doc = snapshot.data();

    admin
      .firestore()
      .collection("usernames")
      .doc(doc.username).set({
        uid: uid,
      });
  });

export const onUpdateUser = functions.firestore
  .document("/users/{userId}")
  .onUpdate(async (change, context) => {
    //console.log("User Updated", change.after.data());
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
        //console.log("Auth User Updated", userRecord.toJSON());
      })
      .catch(function (error) {
        //console.log("Auth User Update Error", error);
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
              photoUrl: userUdpated.photoUrl
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
                  photoUrl: userUdpated.photoUrl
                });
            }
          });
          return;
        }).catch(error => {
          return;
        });
    });
  });
import admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

import { getVirgilJwtFunction } from "./virgil";

export const getVirgilJwt = functions.https.onCall(getVirgilJwtFunction);

import { getAgoraSignalingTokenFunction } from "./agora";

export const getAgoraSignalingToken = functions.https.onCall(
  getAgoraSignalingTokenFunction
);

import * as flybis from "./flybis";

//export const cspReport = functions.https.onRequest(flybis.cspReport);

export const setMinimumPostDuration = functions.pubsub
  .schedule("0 18 * * *")
  .timeZone("America/Bahia")
  .onRun(flybis.setMinimumPostDuration);

import * as flybisFollower from "./follower";

const followersRef = "/followers/{userId}/followers/{followerId}";

export const onCreateFollower = functions.firestore
  .document(followersRef)
  .onCreate(flybisFollower.createFollowerEvent);

export const onDeleteFollower = functions.firestore
  .document(followersRef)
  .onDelete(flybisFollower.deleteFollowerEvent);

import * as flybisPost from "./post";

const postsRef = "/posts/{userId}/posts/{postId}";

export const onCreatePost = functions.firestore
  .document(postsRef)
  .onCreate(flybisPost.createPostEvent);

export const onUpdatePost = functions.firestore
  .document(postsRef)
  .onUpdate(flybisPost.updatePostEvent);

export const onDeletePost = functions.firestore
  .document(postsRef)
  .onDelete(flybisPost.deletePostEvent);

const postsLikesRef = "/posts/{userId}/posts/{postId}/likes/{senderId}";
const postsDislikesRef = "/posts/{userId}/posts/{postId}/dislikes/{senderId}";

export const onCreatePostLike = functions.firestore
  .document(postsLikesRef)
  .onCreate(flybisPost.createPostLikeEvent);

export const onDeletePostLike = functions.firestore
  .document(postsLikesRef)
  .onDelete(flybisPost.deletePostLikeEvent);

export const onCreatePostDislike = functions.firestore
  .document(postsDislikesRef)
  .onCreate(flybisPost.createPostDislikeEvent);

export const onDeletePostDislike = functions.firestore
  .document(postsDislikesRef)
  .onDelete(flybisPost.deletePostDislikeEvent);

import * as flybisUser from "./user";

const usersRef = "/users/{userId}";
const statusRef = "/status/{uid}";

export const onCreateUser = functions.firestore
  .document(usersRef)
  .onCreate(flybisUser.createUserEvent);

export const onUpdateUser = functions.firestore
  .document(usersRef)
  .onUpdate(flybisUser.updateUserEvent);

// Create a new function which is triggered on changes to /status/{uid}
// Note: This is a Realtime Database trigger, *not* Cloud Firestore.
export const onUserStatusChanged = functions.database
  .ref(statusRef)
  .onUpdate(flybisUser.updateUserStatusEvent);

import * as flybisComment from "./comment";

const commentsRef = "/comments/{userId}/posts/{postId}/comments/{commentId}";

export const onCreateComment = functions.firestore
  .document(commentsRef)
  .onCreate(flybisComment.createCommentEvent);

export const onDeleteComment = functions.firestore
  .document(commentsRef)
  .onDelete(flybisComment.deleteCommentEvent);

import * as flybisBell from "./bell";

const bellsRef = "/bells/{userId}/bells/{bellId}";
const bellsSendsRef = "/bells/{senderId}/sends/{receiverId}/bells/{bellId}";

export const onCreateBell = functions.firestore
  .document(bellsRef)
  .onCreate(flybisBell.createBellEvent);

export const onCreateBellSend = functions.firestore
  .document(bellsSendsRef)
  .onCreate(flybisBell.createBellSendEvent);

export const onDeleteBellSend = functions.firestore
  .document(bellsSendsRef)
  .onDelete(flybisBell.deleteBellSendEvent);

import * as flybisChat from "./chat";

const chatsRef = "/chats/{chatId}";
const messagesRef = "/chats/{chatId}/messages/{messageId}";

export const onCreateChat = functions.firestore
  .document(chatsRef)
  .onCreate(flybisChat.createChatEvent);

export const onCreateMessage = functions.firestore
  .document(messagesRef)
  .onCreate(flybisChat.createMessageEvent);

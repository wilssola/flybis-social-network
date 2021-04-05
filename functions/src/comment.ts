import admin from "firebase-admin";
import * as functions from "firebase-functions";

import { FlybisBell, addBell, deleteBell } from "./bell";
import { FlybisPost } from "./post";

export interface FlybisComment {
  // User
  userId: string;

  // Comment
  commentId: string;
  commentContent: string;
  commentType: "posts" | "lives" | "stories";

  // Timestamp
  timestamp: admin.firestore.Timestamp;
}

export async function createCommentEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const ref = snapshot.ref;

    const flybisComment = snapshot.data() as FlybisComment;

    const senderId = flybisComment.userId;

    const doc = await admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("posts")
      .doc(postId)
      .get();
    const flybisPost = doc.data() as FlybisPost;

    const flybisBell = {
      ref: ref,
      senderId: senderId,
      receiverId: userId,
      bellContent: {
        contentId: postId,
        contentType: "text",
        contentText: flybisComment.commentContent,
        contentImage:
          flybisPost.postContents[0].contentType === "image"
            ? flybisPost.postContents[0].contentUrl
            : flybisPost.postContents[0].contentThumbnail,
      },
      bellMode: "comment",
      timestamp: admin.firestore.Timestamp.now(),
    } as FlybisBell;

    await addBell(flybisBell);
  } catch (error) {
    console.error(error);
  }
}

export async function deleteCommentEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    const userId = context.params.userId;

    const ref = snapshot.ref;

    await deleteBell(userId, ref);
  } catch (error) {
    console.error(error);
  }
}

import admin from "firebase-admin";
import * as functions from "firebase-functions";

import { sendNotification } from "./notification";

import { Buffer } from "buffer";

export interface FlybisBell {
  /**
   * Reference
   */
  ref: admin.firestore.DocumentReference;

  /**
   * Users
   */
  senderId: string;
  receiverId: string;

  /**
   * Bell
   */
  bellId: string;
  bellContent: FlybisBellContent;
  bellMode: "comment" | "friend" | "follow" | "message" | "like" | "post"; // comment, friend, follow, message, like, post

  /**
   * Timestamp
   */
  timestamp: admin.firestore.Timestamp;
}

export interface FlybisBellContent {
  contentId: string;
  contentType: "" | "text" | "image" | "video" | "giphy"; // text, image, video, giphy
  contentText: string;
  contentImage: string;
}

export interface FlybisBellData {
  /**
   * Users
   */
  senderId: string;
  receiverId: string;

  /**
   * Bell
   */
  bellContent: FlybisBellContent;
  bellMode: "comment" | "friend" | "follow" | "message" | "like";
}

export async function createBellEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    // Get user owner of feed.
    const userId = context.params.userId;
    const bellId = context.params.bellId;

    const bell = snapshot.data() as FlybisBell;

    // Get FCM Tokens.
    const fcmTokensRef = admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("tokens")
      .doc("fcm");
    const doc = await fcmTokensRef.get();

    if (doc.exists) {
      const platforms = ["android", "ios", "web", "electron"];

      for (const platform of platforms) {
        const token: string = doc.data()[platform + "Token"];

        // Check if Token exists and Send Notification.
        if (token) {
          await sendNotification(token, userId, bellId, bell);
        }
      }
    }
  } catch (error) {
    console.error(error);
  }
}

export async function createBellSendEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    //const senderId = context.params.senderId;
    const receiverId = context.params.receiverId;
    const bellId = context.params.bellId;

    const flybisBell = snapshot.data() as FlybisBell;

    await admin
      .firestore()
      .collection("bells")
      .doc(receiverId)
      .collection("bells")
      .doc(bellId)
      .set(flybisBell);
  } catch (error) {
    console.error(error);
  }
}

export async function deleteBellSendEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    //const senderId = context.params.senderId;
    const receiverId = context.params.receiverId;
    const bellId = context.params.bellId;

    await admin
      .firestore()
      .collection("bells")
      .doc(receiverId)
      .collection("bells")
      .doc(bellId)
      .delete();
  } catch (error) {
    console.error(error);
  }
}

export async function addBell(bell: FlybisBell) {
  try {
    if (bell.senderId !== bell.receiverId) {
      const bellId = Buffer.from(
        bell.bellMode +
          "-" +
          bell.bellContent.contentId +
          "-" +
          bell.receiverId +
          "-" +
          bell.senderId
      ).toString("base64");

      bell.bellId = bellId;

      await admin
        .firestore()
        .collection("bells")
        .doc(bell.receiverId)
        .collection("bells")
        .doc(bellId)
        .set(bell);

      //await admin.firestore().collection('bells').doc(bell.sender).collection('sends').doc(bell.receiver).collection('bells').doc(ref.id).set({});
    }
  } catch (error) {
    console.error(error);
  }
}

export async function deleteBell(
  userId: string,
  ref: admin.firestore.DocumentReference
) {
  try {
    const query = await admin
      .firestore()
      .collection("bells")
      .doc(userId)
      .collection("bells")
      .where("ref", "==", ref)
      .limit(1)
      .get();

    if (query.docs.length > 0) {
      const doc = query.docs[0];

      //const bell = doc.data() as FlybisBell;

      if (doc.exists) {
        await doc.ref.delete();
      }

      //await admin.firestore().collection('bells').doc(bell.sender).collection('sends').doc(bell.receiver).collection('bells').doc(doc.id).delete();
    }
  } catch (error) {
    console.error(error);
  }
}

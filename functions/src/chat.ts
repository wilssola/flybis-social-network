import admin, { firestore } from "firebase-admin";
import * as functions from "firebase-functions";

import { FlybisBell, addBell, deleteBell } from "./bell";

import { decryptAESCryptoJS, encryptAESCryptoJS } from "./crypto";

import { v4 as uuidv4 } from "uuid";

export interface FlybisChatStatus {
  // Chat
  chatId: String;
  chatKey: String;
  chatType: "direct" | "group"; // direct, group
  chatUsers: Array<String>;

  // Message
  messageContent: String;
  messageType: String; // text, image, video, giphy
  messageColor: Number;
  messageCounts: Map<String, Number>;

  // Timestamp
  timestamp: admin.firestore.Timestamp;
}

export interface FlybisChatMessage {
  // Chat
  chatId: String;

  // User
  userId: String;

  // Message
  messageId: String;
  messageContent: String;
  messageType: String; // text, image, video, giphy
  messageColor: Number;

  // Timestamp
  timestamp: admin.firestore.Timestamp;
}

export async function createChatEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    await generateChatKey(snapshot);
  } catch (error) {
    console.log(error);
  }
}

export async function createMessageEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    const chatId = context.params.chatId;
    //const messageId = context.params.messageId;

    const ref = snapshot.ref;

    const flybisChatMessage = snapshot.data() as FlybisChatMessage;

    const doc = await admin.firestore().collection("chats").doc(chatId).get();
    const flybisChatStatus = doc.data() as FlybisChatStatus;

    flybisChatMessage.messageContent = decryptAESCryptoJS(
      flybisChatMessage.messageContent,
      flybisChatStatus.chatKey
    );

    for (var i = 0; i < flybisChatStatus.chatUsers.length; i++) {
      if (flybisChatStatus.chatUsers[i] != flybisChatMessage.userId) {
        const flybisBell = {
          ref: ref,
          senderId: flybisChatMessage.userId,
          receiverId: flybisChatStatus.chatUsers[i],
          bellContent: {
            contentId: chatId,
            contentType: flybisChatMessage.messageType,
            contentText:
              flybisChatMessage.messageType === "text"
                ? flybisChatMessage.messageContent
                : "",
            contentImage:
              flybisChatMessage.messageType === "image"
                ? flybisChatMessage.messageContent
                : "",
          },
          bellMode: "message",
          timestamp: admin.firestore.Timestamp.now(),
        } as FlybisBell;

        console.log(flybisBell);

        try {
          await addBell(flybisBell);
        } catch (error) {
          console.log(error);
        }
      }
    }
  } catch (error) {
    console.log(error);
  }
}

async function generateChatKey(snapshot: firestore.DocumentSnapshot) {
  try {
    const ref = snapshot.ref;

    const flybisChatStatus = snapshot.data() as FlybisChatStatus;
    flybisChatStatus.chatKey = uuidv4();

    await ref.update(flybisChatStatus);
  } catch (error) {
    console.log(error);
  }
}

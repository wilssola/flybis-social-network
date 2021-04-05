import admin from "firebase-admin";

import { FlybisBell, FlybisBellData } from "./bell";

import { FlybisUser } from "./user";

export async function sendNotification(
  token: string,
  userId: string,
  bellId: string,
  bell: FlybisBell
) {
  try {
    const doc = await admin
      .firestore()
      .collection("users")
      .doc(bell.senderId)
      .get();
    const sender = doc.data() as FlybisUser;

    const title = "Flybis";
    const link = "https://flybis.net/app";
    const icon = "https://flybis.net/assets/flybis-icon.png";

    const username = "@" + sender.username + " ";

    const colors = ["#248fcd"];

    let tag: string;
    let body: string;
    let image: string;
    let priority: string = "normal";
    let android_notification_priority: string = "default";
    let visibility: string = "public";

    switch (bell.bellMode) {
      case "comment":
        body = username + "replied: " + bell.bellContent.contentText;
        image = bell.bellContent.contentImage;
        tag = bell.bellContent.contentId;
        break;

      case "friend":
        body = username + "want be your friend";
        tag = bell.bellMode;
        break;

      case "follow":
        body = username + "started followings you";
        tag = bell.bellMode;
        break;

      case "message":
        switch (bell.bellContent.contentType) {
          case "image":
            body = username + "sended a image";
            image = bell.bellContent.contentImage;
            break;

          case "video":
            body = username + "sended a video";
            break;

          case "text":
            body = username + "talked: " + bell.bellContent.contentText;
            image = sender.photoUrl.length > 0 ? sender.photoUrl : icon;
            break;

          default:
            body = username + "sended a message";
            image = sender.photoUrl.length > 0 ? sender.photoUrl : icon;
            break;
        }
        tag = bell.senderId;
        priority = "high";
        android_notification_priority = "max";
        visibility = "secret";
        await deleteNotification(userId, bellId);
        break;

      case "like":
        body = username + "liked your post";
        image = bell.bellContent.contentImage;
        tag = bell.bellContent.contentId;
        break;

      case "post":
        switch (bell.bellContent.contentType) {
          case "image":
            body = username + "published a image";
            image = bell.bellContent.contentImage;
            break;

          case "video":
            body = username + "published a video";
            break;

          case "text":
            body = username + "published a text";
            image = sender.photoUrl;
            break;

          default:
            body = username + "make a new post";
            image = sender.photoUrl;
            break;
        }
        await deleteNotification(userId, bellId);
        break;

      default:
        body = `You has new notifications`;
        break;
    }

    const flybisBellData = {
      receiverId: bell.receiverId,
      senderId: bell.senderId,
      bellContent: bell.bellContent,
      bellMode: bell.bellMode,
    } as FlybisBellData;

    // Create message object for pusn notification.
    const message = {
      notification: {
        title,
        body,
        image,
      },
      token,
      data: flybisBellData as {},
      android: {
        priority,
        notification: {
          tag,
          icon,
          color: colors[0],
          imageUrl: image,
          priority: android_notification_priority,
          visibility,
          defaultSound: true,
        } as admin.messaging.AndroidNotification,
      } as admin.messaging.AndroidConfig,
      webpush: {
        notification: {
          title,
          icon,
          image,
        } as admin.messaging.WebpushNotification,
        fcmOptions: {
          link,
        } as admin.messaging.WebpushFcmOptions,
      } as admin.messaging.WebpushConfig,
    } as admin.messaging.Message;

    // Send message with admin messaging.
    try {
      await admin
        .messaging()
        .send(message)
        .then((response) => {
          console.log("Notification Send", response);
        });
    } catch (error) {
      console.error("Notification Error", error);
    }
  } catch (error) {
    console.error(error);
  }
}

async function deleteNotification(userId: string, bellId: string) {
  await admin
    .firestore()
    .collection("bells")
    .doc(userId)
    .collection("bells")
    .doc(bellId)
    .delete();
}

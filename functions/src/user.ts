import admin from "firebase-admin";
import * as functions from "firebase-functions";

export interface FlybisUser {
  /**
   * Firebase Auth
   */
  uid: string;
  email: string;
  photoUrl: string;
  displayName: string;
  displayNameQuery: string;

  /**
   * Flybis Auth
   */
  username: string;
  usernameQuery: string;
  bio: string;
  bioQuery: string;
  bioSentiment: string;
  bannerUrl: string;

  /**
   * Counts
   */
  followersCount: Number;
  followingsCount: Number;
  friendsCount: Number;
  postsCount: Number;

  /**
   * BlurHash
   */
  blurHash: string;

  /**
   * Premium
   */
  hasPremium: Boolean;
  hasVerified: Boolean;

  /**
   * Timestamp
   */
  timestamp: admin.firestore.Timestamp;
  timestampBirthday: admin.firestore.Timestamp;
}

export function createUserEvent(
  snapshot: functions.firestore.QueryDocumentSnapshot,
  context: functions.EventContext
) {
  try {
    const userId = context.params.userId;

    const flybisUser = snapshot.data() as FlybisUser;

    admin.firestore().collection("usernames").doc(flybisUser.username).set({
      uid: userId,
    });

    flybisUser.usernameQuery = flybisUser.username.toLowerCase();
    flybisUser.displayNameQuery = flybisUser.displayName.toLowerCase();
    flybisUser.bioQuery = flybisUser.bio.toLowerCase();

    admin.firestore().collection("users").doc(userId).update(flybisUser);
  } catch (error) {
    console.error(error);
  }
}

export async function updateUserEvent(
  change: functions.Change<functions.firestore.QueryDocumentSnapshot>,
  context: functions.EventContext
) {
  try {
    const userId = context.params.userId;

    const flybisUser = change.after.data() as FlybisUser;

    await admin.auth().updateUser(userId, {
      email: flybisUser.email,
      displayName: flybisUser.displayName,
      photoURL: flybisUser.photoUrl,
    } as admin.auth.UpdateRequest);

    flybisUser.usernameQuery = flybisUser.username.toLowerCase();
    flybisUser.displayNameQuery = flybisUser.displayName.toLowerCase();
    flybisUser.bioQuery = flybisUser.bio.toLowerCase();

    admin.firestore().collection("users").doc(userId).update(flybisUser);
  } catch (error) {
    console.error(error);
  }
}

export async function updateUserStatusEvent(
  change: functions.Change<functions.database.DataSnapshot>,
  context: functions.EventContext
) {
  try {
    // Get the data written to Realtime Database
    const eventStatus = change.after.val();

    // Then use other event data to create a reference to the
    // corresponding Firestore document.
    const userStatusFirestoreRef = admin
      .firestore()
      .doc("status/" + context.params.uid);

    // It is likely that the Realtime Database change that triggered
    // this event has already been overwritten by a fast change in
    // online / offline status, so we'll re-read the current data
    // and compare the timestamps.
    const statusSnapshot = await change.after.ref.once("value");
    const status = statusSnapshot.val();
    console.log(status, eventStatus);

    // If the current timestamp for this data is newer than
    // the data that triggered this event, we exit this function.
    if (status.timestamp > eventStatus.timestamp) {
      return null;
    }

    // Otherwise, we convert the timestamp field to a Date
    eventStatus.timestamp = new Date(eventStatus.timestamp);

    // ... and write it to Firestore.
    await userStatusFirestoreRef.set(eventStatus);
  } catch (error) {
    console.error(error);
  }
}

import * as functions from "firebase-functions";

import md5 from "md5";

const { app_id, primary_certificate } = functions.config().agora;

export async function getAgoraSignalingTokenFunction(data, context) {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const expiredTime =
    parseInt((new Date().getTime() / 1000).toString()) + 3600 * 24;

  const account = context.auth.uid;

  const token_items = [];

  // append SDK VERSION
  token_items.push("1");

  // append appid
  token_items.push(app_id);

  // expired time
  token_items.push(expiredTime);

  // md5 account + appid + appcertificate + expiredtime
  token_items.push(md5(account + app_id + primary_certificate + expiredTime));

  return {
    token: token_items.join(":").toString(),
  };
}

import admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as publitioAPI from "publitio_js_sdk";

const { key, secret } = functions.config().publitio;
const publitio = new publitioAPI.default(key, secret);

export interface PublitioVideo {
  id: string;
  downloadUrl: string;
  thumbnailUrl: string;
  aspectRatio: Number;
}

export async function uploadVideoToPublitio(filePath: string) {
  const bucket = admin.storage().bucket();

  const videoFile = bucket.file(filePath);

  console.log(`uploading video file: ${videoFile.name}`);

  const expires = new Date();
  expires.setTime(expires.getTime() + 60 * 60 * 1000);

  const downloadUrlArray = await videoFile.getSignedUrl({
    action: "read",
    expires: expires,
  });

  const downloadUrl = downloadUrlArray[0];

  let data;

  try {
    data = await publitio.uploadRemoteFile({
      file_url: downloadUrl,
      privacy: 0,
      option_hls: 1,
    });

    console.log(`Uploading finished. Status code: ${data.code}`);
  } catch (error) {
    console.error("Uploading error.", error);
  }

  if (data.code === 201) {
    console.log(
      `Setting data in firestore doc: ${filePath} with publitioID: ${data.id}`
    );

    console.log("Deleting source file");

    await bucket.file(filePath).delete();

    console.log("Done");

    return {
      id: data.id,
      downloadUrl: data.url_download,
      thumbnailUrl: data.url_thumbnail,
      aspectRatio: data.width / data.height,
    } as PublitioVideo;
  } else {
    console.log("Upload status unsuccessful. Data:", data);
  }

  return null;
}

export async function deleteVideo(id: string) {
  console.log(`Deleting video with id: ${id}`);

  try {
    const result = await publitio.call(`/files/delete/${id}`, "DELETE");
    console.log("Delete complete.", result);
  } catch (error) {
    console.error("Delete error.", error);
  }
}

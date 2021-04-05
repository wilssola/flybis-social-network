import admin from "firebase-admin";
import * as functions from "firebase-functions";

import crypto from "crypto";
import * as blurHash from "blurhash";

import mkdirp from "mkdirp-promise";
import { execFile } from "child-process-promise";
import * as fetch from "node-fetch";

import os from "os";
import fs from "fs";
import path from "path";
import { Canvas, loadImage } from "canvas";

async function createTempDir(filePath: string) {
  const randomFileName =
    crypto.randomBytes(20).toString("hex") + path.extname(filePath);
  const tempLocalFile = path.join(os.tmpdir(), randomFileName);
  const tempLocalDir = path.dirname(tempLocalFile);

  // Create the temp directory where the storage file will be downloaded.
  await mkdirp(tempLocalDir);

  return tempLocalFile;
}

async function encodeImageToBlurHash(src: string) {
  const imageWidth = 512;
  const imageHeight = 512;

  const canvas = new Canvas(imageWidth, imageHeight);
  const context = canvas.getContext("2d");
  const myImg = await loadImage(src);
  context.drawImage(myImg, 0, 0);
  const imageData = context.getImageData(0, 0, imageWidth, imageHeight);

  const hash = blurHash.encode(imageData.data, imageWidth, imageHeight, 5, 5);

  return hash;
}

export async function encodeFromStorageFileImageToBlurHash(filePath: string) {
  try {
    const bucket = admin.storage().bucket();
    const file = bucket.file(filePath);

    const tempLocalFile = await createTempDir(filePath);

    // Download file from bucket.
    await file.download({ destination: tempLocalFile });

    // Get Dimensions of the image
    /*
    const { stdout } = await execFile(
      "identify",
      ["-format", "%wx%h", tempLocalFile],
      {
        capture: ["stdout", "stderr"],
      }
    );
    const [height, width] = stdout.split("x");
    console.log(`Height: ${height} Width: ${width}`);
    */

    const hash = await encodeImageToBlurHash(tempLocalFile);

    fs.unlinkSync(tempLocalFile);

    return hash;
  } catch (error) {
    console.error(error);

    return "";
  }
}

export async function encodeFromPublitioFileImageToBlurHash(fileUrl: string) {
  try {
    const response = await fetch(fileUrl);
    const buffer = await response.buffer();

    const filePath = fileUrl.split("?")[0];

    const tempLocalFile = await createTempDir(filePath);

    await fs.promises.writeFile(tempLocalFile, buffer);

    const hash = await encodeImageToBlurHash(tempLocalFile);

    fs.unlinkSync(tempLocalFile);

    return hash;
  } catch (error) {
    console.error(error);

    return "";
  }
}

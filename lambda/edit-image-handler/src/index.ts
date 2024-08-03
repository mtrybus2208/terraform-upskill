import { GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import Jimp from "jimp";
import type { Readable } from "stream";

import { getS3Client } from "./clients/s3-client";
import { ImageMetaDataItem } from "../../shared/types";

const processedBucket = process.env.PROCESSED_IMAGES_BUCKET || "";

export const handler = async (event: ImageMetaDataItem) => {
  try {
    const { imageBucket, imageKey } = event;

    const getObjectParams = {
      Bucket: imageBucket,
      Key: imageKey,
    };

    const s3Client = getS3Client();
    const getObjectCommand = new GetObjectCommand(getObjectParams);
    const s3Response = await s3Client.send(getObjectCommand);

    if (!s3Response.Body) {
      throw new Error("Failed to get image from S3");
    }

    const imageBuffer = await streamToBuffer(s3Response.Body as Readable);
    const resizedImageBuffer = await editImage(imageBuffer);

    const putObjectParams = {
      Bucket: processedBucket,
      Key: imageKey,
      Body: resizedImageBuffer,
      ContentType: s3Response.ContentType,
    };
    const putObjectCommand = new PutObjectCommand(putObjectParams);
    await s3Client.send(putObjectCommand);

    console.log(`Resized image saved to ${processedBucket}/${imageKey}`);

    return {
      ...event,
      processedBucket,
      processedKey: imageKey,
    };
  } catch (error) {
    throw new Error(`Error processing image: ${error}`);
  }
};

const editImage = async (imageBuffer: Buffer) => {
  const image = await Jimp.read(imageBuffer);
  image.greyscale();
  return image.getBufferAsync(Jimp.MIME_JPEG);
};

const streamToBuffer = (stream: Readable): Promise<Buffer> => {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    stream.on("data", (chunk) => chunks.push(chunk));
    stream.once("end", () => resolve(Buffer.concat(chunks)));
    stream.once("error", reject);
  });
};

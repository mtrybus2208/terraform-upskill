import { AttributeValue } from "@aws-sdk/client-dynamodb";
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const getImagesSignedUrls = async (
  imagesData: Record<string, AttributeValue>[],
  s3Client: S3Client,
  expiresIn = 60
) => {
  const urls = await Promise.all(
    imagesData.map(async (item) => {
      try {
        const bucket = item.imageBucket.S;
        const key = item.imageKey.S;
        const command = new GetObjectCommand({
          Bucket: bucket,
          Key: key,
        });
        const url = await getSignedUrl(s3Client, command, { expiresIn });
        return { imageId: item.imageId.S, url };
      } catch (error) {
        console.error("Error generating signed URL", error);
        return null;
      }
    })
  );

  return urls;
};

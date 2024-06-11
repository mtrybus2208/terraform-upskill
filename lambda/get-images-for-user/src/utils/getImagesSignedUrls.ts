import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

import { ImageMetaDataItem } from "../../../shared/types";
import { handleErrors } from "../../../shared/utils/handle-errors";

export const getImagesSignedUrls = async (
  imagesData: ImageMetaDataItem[],
  s3Client: S3Client,
  expiresIn = 60
) => {
  const urls = await Promise.all(
    imagesData.map(async (item) => {
      try {
        const command = new GetObjectCommand({
          Bucket: item.imageBucket,
          Key: item.imageKey,
        });

        const url = await getSignedUrl(s3Client, command, { expiresIn });

        return { imageId: item.imageId, url };
      } catch (error) {
        handleErrors(error);
      }
    })
  );

  return urls;
};

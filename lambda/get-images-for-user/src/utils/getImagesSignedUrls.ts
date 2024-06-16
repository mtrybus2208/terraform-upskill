import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

import { ImageMetaDataItem } from "../../../shared/types";
import { filterFulfilledPromises } from "../../../shared/utils/filter-fulfilled-promises";

export const getImagesSignedUrls = async (
  imagesData: ImageMetaDataItem[],
  s3Client: S3Client,
  expiresIn = 60
) => {
  const urls = await Promise.allSettled(
    imagesData.map(async (item) => {
      const command = new GetObjectCommand({
        Bucket: item.imageBucket,
        Key: item.imageKey,
      });

      const url = await getSignedUrl(s3Client, command, { expiresIn });

      return { imageId: item.imageId, url };
    })
  );

  return filterFulfilledPromises<{ imageId: string; url: string }>(urls);
};

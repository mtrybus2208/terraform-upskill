import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export const generatePresignedUrl = async (
  s3Client: S3Client,
  bucket: string,
  key: string,
  expiresIn = 60
) => {
  const getObjectCommand = new GetObjectCommand({
    Bucket: bucket,
    Key: key,
  });

  return getSignedUrl(s3Client, getObjectCommand, {
    expiresIn,
  });
};

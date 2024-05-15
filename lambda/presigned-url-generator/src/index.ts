import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export interface HttpError extends Error {
  status?: number;
}

export function handleErrors(error: unknown): APIGatewayProxyResult {
  const errorMessage =
    (error as HttpError)?.message ?? "Unknown lambda error occurred";
  const status = (error as HttpError)?.status ?? 500;

  const formattedMsg = `Message: ${errorMessage}, Status: ${status}`;

  console.error(formattedMsg);

  return {
    statusCode: status,
    body: JSON.stringify({ message: errorMessage }),
  };
}

const s3Client = new S3Client({ region: process.env.AWS_REGION });

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const bucketName = process.env.BUCKET_NAME;
  const requestBody = JSON.parse(event.body || "{}");
  const filename = requestBody.filename || `uploads/${Date.now()}`;

  try {
    const command = new PutObjectCommand({
      Bucket: bucketName,
      Key: filename,
    });
    const url = await getSignedUrl(s3Client, command, { expiresIn: 60 });
    return {
      statusCode: 200,
      body: JSON.stringify({ url, key: filename }),
    };
  } catch (error) {
    return handleErrors(error);
  }
};

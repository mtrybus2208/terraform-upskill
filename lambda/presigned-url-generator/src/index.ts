import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { handleErrors } from "../../shared/utils/handle-errors";

const s3Client = new S3Client({ region: process.env.AWS_REGION });

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const bucketName = process.env.BUCKET_NAME;
  const requestBody = JSON.parse(event.body || "{}");
  const filename = `uploads/${requestBody.filename || Date.now()}`;
  const userName = requestBody.userName;

  if (!userName) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing userName parameter - Presigned" }),
    };
  }

  try {
    const command = new PutObjectCommand({
      Bucket: bucketName,
      Key: filename,
      Metadata: {
        userName: userName,
      },
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

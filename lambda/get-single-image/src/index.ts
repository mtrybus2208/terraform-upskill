import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { S3Client } from "@aws-sdk/client-s3";
import { getImageData } from "./utils/get-image-data";
import { generatePresignedUrl } from "./utils/generate-presigned-url";
import { handleErrors } from "../../shared/utils/handle-errors";

const dynamoDBClient = new DynamoDBClient({});
const s3Client = new S3Client();

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const { imageId } = event.pathParameters || {};
  const userName = event?.requestContext?.authorizer?.claims?.username;

  if (!userName || !imageId) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing userName or imageId parameter" }),
    };
  }

  try {
    const imageData = await getImageData(dynamoDBClient, userName, imageId);
    if (!imageData) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "Image not found" }),
      };
    }

    const url = await generatePresignedUrl(
      s3Client,
      imageData.bucket || "",
      imageData.key || ""
    );

    return {
      statusCode: 200,

      body: JSON.stringify({
        userName,
        url,
        imageName: imageData.imageName,
      }),
    };
  } catch (error) {
    return handleErrors(error);
  }
};

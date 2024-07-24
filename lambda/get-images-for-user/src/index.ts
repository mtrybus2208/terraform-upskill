import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { QueryCommand, DynamoDBDocument } from "@aws-sdk/lib-dynamodb";
import { S3Client } from "@aws-sdk/client-s3";

import { getImagesSignedUrls } from "./utils/getImagesSignedUrls";
import { handleErrors } from "../../shared/utils/handle-errors";
import { ImageMetaDataItem } from "../../shared/types";

const dynamoDBClient = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocument.from(dynamoDBClient);
const s3Client = new S3Client();

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const userName = event?.requestContext?.authorizer?.claims?.username;

  if (!userName) {
    return {
      statusCode: 403,
      body: JSON.stringify({ error: "Missing userName parameter - get" }),
    };
  }

  try {
    const input = {
      TableName: process.env.DYNAMODB_TABLE_NAME || "",
      KeyConditionExpression: "userName = :userName",
      ExpressionAttributeValues: {
        ":userName": userName,
      },
      ConsistentRead: true,
    };

    const command = new QueryCommand(input);
    const response = await ddbDocClient.send(command);

    if (!response.Items?.length) {
      return {
        statusCode: 404,
        body: JSON.stringify({ error: "No items found" }),
      };
    }

    const urls = await getImagesSignedUrls(
      response.Items as ImageMetaDataItem[],
      s3Client
    );

    return {
      statusCode: 200,
      body: JSON.stringify({
        userName,
        urls,
      }),
    };
  } catch (error) {
    return handleErrors(error);
  }
};

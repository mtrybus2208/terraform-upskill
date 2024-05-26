import { SQSHandler } from "aws-lambda";
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";

const dynamoDBClient = new DynamoDBClient({});

export const handler: SQSHandler = async (event) => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const body = JSON.parse(record.body);
    const bucket = body.bucket;
    const key = body.key;

    const timestamp = Date.now();
    const imageId = `${key}-${timestamp}`;
    const imageName = key.split("/").pop();

    const params = {
      TableName: process.env.DYNAMODB_TABLE_NAME || "",
      Item: {
        imageId: { S: imageId },
        imageName: { S: imageName },
        bucket: { S: bucket },
        key: { S: key },
        timestamp: { N: timestamp.toString() },
      },
    };

    try {
      const command = new PutItemCommand(params);
      const result = await dynamoDBClient.send(command);
      console.log("Metadata saved to DynamoDB:", result);
    } catch (error) {
      console.error("Error saving metadata to DynamoDB:", error);
    }
  }
};

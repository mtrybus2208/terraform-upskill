import { SQSHandler } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocument } from "@aws-sdk/lib-dynamodb";
import { randomUUID } from "crypto";

import { handleErrors } from "../../shared/utils/handle-errors";

const dynamoDBClient = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocument.from(dynamoDBClient);

export const handler: SQSHandler = async (event) => {
  for (const record of event.Records) {
    const body = JSON.parse(record.body);

    try {
      const result = await ddbDocClient.put({
        TableName: process.env.DYNAMODB_TABLE_NAME || "",
        Item: {
          userName: body.userName,
          imageId: randomUUID(),
          imageName: body.key.split("/").pop(),
          imageBucket: body.bucket,
          imageKey: body.key,
          timestamp: Date.now(),
        },
      });

      console.log("Metadata saved to DynamoDB:");
      console.log("Message sent to SQS:", result.$metadata);
    } catch (error) {
      handleErrors(error);
    }
  }
};

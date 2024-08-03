import { SFNClient } from "@aws-sdk/client-sfn";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocument } from "@aws-sdk/lib-dynamodb";

let dynamoClient: DynamoDBDocument | undefined;

export const getDynamoClient = (): DynamoDBDocument => {
  if (!dynamoClient) {
    const dynamoDBClient = new DynamoDBClient({});
    dynamoClient = DynamoDBDocument.from(dynamoDBClient);
  }
  return dynamoClient;
};

import { randomUUID } from "crypto";

import { ImageMetaDataItem } from "../../shared/types";
import { getDynamoClient } from "./clients/dynamo-client";

export const handler = async (event: ImageMetaDataItem) => {
  const ddbDocClient = getDynamoClient();

  try {
    await ddbDocClient.put({
      TableName: process.env.DYNAMODB_TABLE_NAME || "",
      Item: {
        userName: event.userName,
        imageId: randomUUID(),
        imageName: event.imageKey.split("/").pop(),
        imageBucket: event.imageBucket,
        imageKey: event.imageKey,
        timestamp: Date.now(),
      },
    });
    return event;
  } catch (error) {
    throw new Error(`Error saving image metadata: ${error}`);
  }
};

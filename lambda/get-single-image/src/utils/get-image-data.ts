import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb";

export const getImageData = async (
  dynamoDBClient: DynamoDBClient,
  userName: string,
  imageId: string
) => {
  const input = {
    TableName: process.env.DYNAMODB_TABLE_NAME || "",
    Key: {
      userName: { S: userName },
      imageId: { S: imageId },
    },
  };

  const command = new GetItemCommand(input);
  const response = await dynamoDBClient.send(command);

  if (!response.Item) {
    return null;
  }

  return {
    bucket: response.Item.imageBucket.S,
    key: response.Item.imageKey.S,
    imageName: response.Item.imageName.S,
  };
};

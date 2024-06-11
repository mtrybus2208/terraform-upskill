import { DynamoDBStreamHandler } from "aws-lambda";
import { unmarshall } from "@aws-sdk/util-dynamodb";
import { AttributeValue } from "@aws-sdk/client-dynamodb";

import { publishToSns } from "./utils/sns-publish";
import { handleErrors } from "../../shared/utils/handle-errors";
import { SnsEventTypes, ImageMetaDataDto } from "../../shared/types";

export const handler: DynamoDBStreamHandler = async (event) => {
  for (const record of event.Records) {
    const recordImage = record.dynamodb?.NewImage;

    try {
      if (recordImage) {
        const data = unmarshall(
          recordImage as { [key: string]: AttributeValue }
        ) as ImageMetaDataDto;

        await publishToSns<SnsEventTypes, ImageMetaDataDto>(
          SnsEventTypes.IMAGE_CREATED,
          {
            userName: data.userName,
            imageKey: data.imageName,
            imageName: data.imageName,
          }
        );
      }
    } catch (error) {
      console.log({ error });
      handleErrors(error);
    }
  }
};

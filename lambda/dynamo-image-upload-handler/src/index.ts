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
          recordImage as Record<string, AttributeValue>
        ) as ImageMetaDataDto;

        await publishToSns<SnsEventTypes, ImageMetaDataDto>(
          SnsEventTypes.IMAGE_CREATED,
          data
        );
      }
    } catch (error) {
      handleErrors(error);
    }
  }
};

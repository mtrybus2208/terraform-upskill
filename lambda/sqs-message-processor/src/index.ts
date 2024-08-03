import { SFNClient, StartExecutionCommand } from "@aws-sdk/client-sfn";
import { SQSHandler } from "aws-lambda";

import { getSfnClient } from "./clients/sfn-client";
import { ImageMetaDataDto } from "../../shared/types";
import { handleErrors } from "../../shared/utils/handle-errors";

export const handler: SQSHandler = async (event) => {
  const records = event.Records;
  console.log(
    "Received events: ",
    records.map((record) => record.body)
  );

  const promises = [];
  const sfnClient = getSfnClient();

  for (const record of records) {
    const body: ImageMetaDataDto = JSON.parse(record.body);

    try {
      const startExecutionPromise = createStartExecutionCommand(
        sfnClient,
        body
      );
      promises.push(startExecutionPromise);
    } catch (error) {
      handleErrors(error);
    }

    await Promise.all(promises);
  }
};

const createStartExecutionCommand = (
  sfnClient: SFNClient,
  input: ImageMetaDataDto
) => {
  const startExecutionCommand = new StartExecutionCommand({
    stateMachineArn: process.env.STATE_MACHINE_ARN,
    input: JSON.stringify(input),
  });

  return sfnClient.send(startExecutionCommand);
};

import { SNSHandler } from "aws-lambda";

import { handleErrors } from "../../shared/utils/handle-errors";

export const handler: SNSHandler = async (event) => {
  for (const record of event.Records) {
    try {
      const msg = record.Sns.Message;

      console.log({ msg });
    } catch (error) {
      handleErrors(error);
    }
  }
};

import { SQSHandler } from "aws-lambda";

export const handler: SQSHandler = async (event) => {
  console.log("Received SQS event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const body = JSON.parse(record.body);
    const bucket = body.bucket;
    const key = body.key;

    console.log(`Processing file: ${key} from bucket: ${bucket}`);
  }
};

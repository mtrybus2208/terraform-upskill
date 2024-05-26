import { S3Handler } from "aws-lambda";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const sqsClient = new SQSClient({ region: process.env.AWS_REGION });
const queueUrl = process.env.SQS_QUEUE_URL || "";

export const handler: S3Handler = async (event) => {
  console.log("Received S3 event:", JSON.stringify(event, null, 2));

  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = record.s3.object.key;

    const deduplicationId = `${bucket}-${key}`;

    const params = {
      QueueUrl: queueUrl,
      MessageBody: JSON.stringify({ bucket, key }),
      MessageDeduplicationId: deduplicationId,
      MessageGroupId: "default",
    };

    try {
      const command = new SendMessageCommand(params);
      const result = await sqsClient.send(command);
      console.log("Message sent to SQS:", result.MessageId);
    } catch (error) {
      console.error("Error sending message to SQS:", error);
    }
  }
};

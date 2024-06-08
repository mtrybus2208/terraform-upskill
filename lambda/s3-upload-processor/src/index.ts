import { S3Handler } from "aws-lambda";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import { S3Client, HeadObjectCommand } from "@aws-sdk/client-s3";

const sqsClient = new SQSClient();
const s3Client = new S3Client();
const queueUrl = process.env.SQS_QUEUE_URL || "";

export const handler: S3Handler = async (event) => {
  for (const record of event.Records) {
    const bucket = record.s3.bucket.name;
    const key = record.s3.object.key;

    console.log(`Processing file from bucket: ${bucket}, key: ${key}`);

    try {
      const headObjectParams = {
        Bucket: bucket,
        Key: key,
      };
      const headObjectCommand = new HeadObjectCommand(headObjectParams);

      const response = await s3Client.send(headObjectCommand);

      const userName = response.Metadata?.username;

      if (!userName) {
        throw new Error("Missing userName in S3 object metadata");
      }

      const params = {
        QueueUrl: queueUrl,
        MessageBody: JSON.stringify({ bucket, key, userName }),
        MessageDeduplicationId: key,
        MessageGroupId: "default",
      };

      const command = new SendMessageCommand(params);
      const result = await sqsClient.send(command);
      console.log("Message sent to SQS:", result.MessageId);
    } catch (error) {
      console.error("Error processing file:", error);
    }
  }
};

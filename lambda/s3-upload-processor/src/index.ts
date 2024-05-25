import { S3Handler } from "aws-lambda";

export const handler: S3Handler = async (event) => {
  console.log("Received S3 event:", JSON.stringify(event, null, 2));
};

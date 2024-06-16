import { SNSClient } from "@aws-sdk/client-sns";

let snsClient: SNSClient | undefined;

export const getSNSClient = (): SNSClient => {
  if (!snsClient) {
    snsClient = new SNSClient({});
  }
  return snsClient;
};

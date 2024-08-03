import { SFNClient } from "@aws-sdk/client-sfn";

let sfnClient: SFNClient | undefined;

export const getSfnClient = (): SFNClient => {
  if (!sfnClient) {
    sfnClient = new SFNClient({});
  }
  return sfnClient;
};

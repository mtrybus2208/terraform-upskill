import { PublishCommand, PublishCommandInput } from "@aws-sdk/client-sns";

import { SnsEvent } from "../../../shared/types";
import { getSNSClient } from "../clients/sns-client";

export async function publishToSns<T, U>(
  eventType: T,
  data: U,
  topicArn = process.env.IMAGE_UPLOAD_TOPIC_ARN
) {
  const snsClient = getSNSClient();

  const message: SnsEvent<T, U> = {
    eventType,
    data,
    timestamp: Date.now(),
  };

  const params: PublishCommandInput = {
    TopicArn: topicArn,
    Message: JSON.stringify(message),
  };

  const result = await snsClient.send(new PublishCommand(params));

  console.info(`Event published to SNS: ${params.Message}`);
  return result;
}

import { APIGatewayRequestSimpleAuthorizerHandlerV2 } from "aws-lambda";

export const handler: APIGatewayRequestSimpleAuthorizerHandlerV2 = async (
  event
) => {
  const validTokenMock = process.env.VALID_TOKEN_MOCK;

  return {
    isAuthorized: event.headers?.authorization === validTokenMock,
  };
};

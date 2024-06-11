import { APIGatewayProxyResult } from "aws-lambda";

export interface HttpError extends Error {
  status?: number;
}

export function handleErrors(error: unknown): APIGatewayProxyResult {
  const errorMessage =
    (error as HttpError)?.message ?? "Unknown lambda error occurred";

  const status = (error as HttpError)?.status ?? 500;

  const formattedMsg = `Message: ${errorMessage}, Status: ${status}`;

  console.error(formattedMsg);

  return {
    statusCode: status,
    body: JSON.stringify({ message: errorMessage }),
  };
}

resource "aws_lambda_function" "presigned_url_generator" {
  function_name    = "${local.environment}-presigned-url-generator-handler"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.presigned_url_generator.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.logging_role.arn
  timeout          = 20
  source_code_hash = data.archive_file.presigned_url_generator.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_edit_lambda_bucket.bucket
      ENV         = local.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.logging_policy_attachment,
    aws_iam_role_policy_attachment.s3_access_policy_attachment
  ]
}


resource "aws_cloudwatch_log_group" "presigned_url_generator_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.presigned_url_generator.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_generator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.photo_api.execution_arn}/*/*"
}

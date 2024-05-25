resource "aws_lambda_function" "presigned_url_generator" {
  function_name    = "${local.environment}-presigned-url-generator-handler"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.presigned_url_generator.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.presigned_url_generator_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.presigned_url_generator.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_edit_lambda_bucket.bucket
      ENV         = local.environment
    }
  }
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

resource "aws_lambda_function" "s3_upload_processor" {
  function_name    = "${local.environment}-s3-upload-processor"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.s3_upload_processor.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.s3_upload_processor_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.s3_upload_processor.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.photo_edit_lambda_bucket.bucket
      ENV         = local.environment
    }
  }
}

resource "aws_cloudwatch_log_group" "s3_upload_processor_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.s3_upload_processor.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_upload_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.photo_edit_lambda_bucket.arn
}

# dynamo-image-upload-handler fn

resource "aws_lambda_function" "dynamo_image_upload_handler" {
  function_name    = "${var.environment}-dynamo-image-upload-handler"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.dynamo_image_upload_handler.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.dynamo_image_upload_handler_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.dynamo_image_upload_handler.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME            = var.photo_edit_lambda_bucket_name
      DYNAMODB_TABLE_NAME    = var.image_metadata_table_name
      REGION                 = var.region
      IMAGE_UPLOAD_TOPIC_ARN = aws_sns_topic.image_upload_notifications_topic.arn
    }
  }
}

resource "aws_lambda_event_source_mapping" "dynamo_stream_trigger" {
  event_source_arn  = var.image_metadata_table_stream_arn
  function_name     = aws_lambda_function.dynamo_image_upload_handler.arn
  batch_size        = 10
  enabled           = true
  starting_position = "LATEST"
}

resource "aws_cloudwatch_log_group" "dynamo_image_upload_handler_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.dynamo_image_upload_handler.function_name}"
  retention_in_days = 30
}

# sns_image_upload_handler fn

resource "aws_lambda_function" "sns_image_upload_handler" {
  function_name    = "${var.environment}-sns-image-upload-handler"
  s3_bucket        = var.photo_edit_lambda_bucket_id
  s3_key           = aws_s3_object.sns_image_upload_handler.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.sns_image_upload_handler_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.sns_image_upload_handler.output_base64sha256

  environment {
    variables = {
      REGION = var.region
    }
  }
}

resource "aws_cloudwatch_log_group" "sns_image_upload_handler_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sns_image_upload_handler.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "sns_lambda_permission" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_image_upload_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.image_upload_notifications_topic.arn
}

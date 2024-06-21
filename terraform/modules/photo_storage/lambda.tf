# s3_upload_processor

resource "aws_lambda_function" "s3_upload_processor" {
  function_name    = "${var.environment}-s3-upload-processor"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.s3_upload_processor.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.s3_upload_processor_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.s3_upload_processor.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME   = aws_s3_bucket.photo_edit_lambda_bucket.bucket
      ENV           = var.environment
      SQS_QUEUE_URL = aws_sqs_queue.sqs_queue.id

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


# sqs_message_processor
resource "aws_lambda_function" "sqs_message_processor" {
  function_name    = "${var.environment}-sqs-message-processor"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.sqs_message_processor.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.sqs_message_processor_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.sqs_message_processor.output_base64sha256

  environment {
    variables = {
      ENV                 = var.environment
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.image_metadata.name
    }
  }
}

resource "aws_cloudwatch_log_group" "sqs_message_processor_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.sqs_message_processor.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.sqs_queue.arn
  function_name    = aws_lambda_function.sqs_message_processor.arn
  batch_size       = 10
  enabled          = true
}
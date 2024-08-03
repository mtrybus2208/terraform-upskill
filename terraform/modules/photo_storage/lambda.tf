# s3_upload_processor

resource "aws_lambda_function" "s3_upload_processor" {
  function_name    = "${var.prefix}-s3-upload-processor"
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
  function_name    = "${var.prefix}-sqs-message-processor"
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
      STATE_MACHINE_ARN   = aws_sfn_state_machine.image_processing_state_machine.arn
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

# image_validation_handler = lambda to validate images

resource "aws_lambda_function" "image_validation_handler" {
  function_name    = "${var.prefix}-image-validation-handler"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.image_validation_handler.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.image_validation_handler_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.image_validation_handler.output_base64sha256

  environment {
    variables = {
      REGION = var.region
    }
  }
}

resource "aws_lambda_permission" "sns_image_validation_handler_permission" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_validation_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.image_upload_notifications_topic_arn
}
resource "aws_cloudwatch_log_group" "image_validation_handler_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.image_validation_handler.function_name}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "image_validation_handler_publish_sns_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      var.image_upload_notifications_topic_arn
    ]
  }
}

resource "aws_iam_policy" "image_validation_handler_publish_sns_policy" {
  name   = "${var.prefix}-image-validation-handler-publish-sns-policy"
  policy = data.aws_iam_policy_document.image_validation_handler_publish_sns_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "image_validation_handler_publish_sns_policy_attachment" {
  role       = aws_iam_role.image_validation_handler_role.name
  policy_arn = aws_iam_policy.image_validation_handler_publish_sns_policy.arn
}

# save_image_metadata_handler = lambda to save image metadata to dynamodb
resource "aws_lambda_function" "save_image_metadata_handler" {
  function_name    = "${var.prefix}-save-image-metadata-handler"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.save_image_metadata_handler.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.save_image_metadata_handler_role.arn
  timeout          = 5
  source_code_hash = data.archive_file.save_image_metadata_handler.output_base64sha256

  environment {
    variables = {
      ENV                 = var.environment
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.image_metadata.name
    }
  }
}

resource "aws_cloudwatch_log_group" "save_image_metadata_handler_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.save_image_metadata_handler.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "save_image_metadata_handler_role" {
  name               = "${var.prefix}-save-image-metadata-handler-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "save_image_metadata_handler_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.save_image_metadata_handler.function_name}:*"]
  }
}


resource "aws_iam_policy" "save_image_metadata_handler_logging_policy" {
  name   = "${var.prefix}-save_image_metadata_handler_logging_policy"
  policy = data.aws_iam_policy_document.save_image_metadata_handler_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "save_image_metadata_handler_logging_policy_attachment" {
  role       = aws_iam_role.save_image_metadata_handler_role.name
  policy_arn = aws_iam_policy.save_image_metadata_handler_logging_policy.arn
}


data "aws_iam_policy_document" "save_image_metadata_handler_dynamodb_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamodb_table.image_metadata.arn
    ]
  }
}
resource "aws_iam_policy" "save_image_metadata_handler_dynamodb_access_policy" {
  name   = "${var.prefix}-save-image-metadata-handler-dynamodb-access-policy"
  policy = data.aws_iam_policy_document.save_image_metadata_handler_dynamodb_access_policy.json
}

resource "aws_iam_role_policy_attachment" "save_image_metadata_handler_dynamodb_access_policy_attachment" {
  role       = aws_iam_role.save_image_metadata_handler_role.name
  policy_arn = aws_iam_policy.save_image_metadata_handler_dynamodb_access_policy.arn
}


# edit_image_handler = lambda to edit images 
resource "aws_lambda_function" "edit_image_handler" {
  function_name    = "${var.prefix}-edit-image-handler"
  s3_bucket        = aws_s3_bucket.photo_edit_lambda_bucket.id
  s3_key           = aws_s3_object.edit_image_handler.key
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.edit_image_handler_role.arn
  timeout          = 30
  source_code_hash = data.archive_file.edit_image_handler.output_base64sha256

  environment {
    variables = {
      ENV                     = var.environment
      PROCESSED_IMAGES_BUCKET = aws_s3_bucket.processed_images_bucket.bucket
    }
  }
}

resource "aws_cloudwatch_log_group" "edit_image_handler_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.edit_image_handler.function_name}"
  retention_in_days = 30
}


resource "aws_iam_role" "edit_image_handler_role" {
  name               = "${var.prefix}-edit-image-handler-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "edit_image_handler_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.edit_image_handler.function_name}:*"]
  }
}

resource "aws_iam_policy" "edit_image_handler_logging_policy" {
  name   = "${var.prefix}-edit_image_handler_logging_policy"
  policy = data.aws_iam_policy_document.edit_image_handler_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "edit_image_handler_logging_policy_attachment" {
  role       = aws_iam_role.edit_image_handler_role.name
  policy_arn = aws_iam_policy.edit_image_handler_logging_policy.arn
}

resource "aws_lambda_permission" "edit_image_handler_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.edit_image_handler.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.processed_images_bucket.arn
}

data "aws_iam_policy_document" "edit_image_handler_s3_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*",
      "${aws_s3_bucket.processed_images_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "edit_image_handler_s3_policy" {
  name   = "${var.prefix}-edit-image-handler-s3-policy"
  policy = data.aws_iam_policy_document.edit_image_handler_s3_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "edit_image_handler_s3_policy_attachment" {
  role       = aws_iam_role.edit_image_handler_role.name
  policy_arn = aws_iam_policy.edit_image_handler_s3_policy.arn
}
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "sqs_message_processor_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.sqs_message_processor.function_name}:*"]
  }
}

data "aws_iam_policy_document" "s3_upload_processor_sqs_send_message_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.sqs_queue.arn
    ]
  }
}


data "aws_iam_policy_document" "sqs_message_processor_sqs_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.sqs_queue.arn
    ]
  }
}

data "aws_iam_policy_document" "sqs_message_processor_dynamodb_access_policy" {
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


data "aws_iam_policy_document" "s3_upload_processor_get_object_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*"
    ]
  }
}

data "archive_file" "s3_upload_processor" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/s3-upload-processor/dist"
  output_path = "${path.root}/../lambda/s3-upload-processor/build/s3-upload-processor-handler.zip"
}

data "archive_file" "sqs_message_processor" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/sqs-message-processor/dist"
  output_path = "${path.root}/../lambda/sqs-message-processor/build/sqs-message-processor-handler.zip"
}

data "archive_file" "save_image_metadata_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/save-image-metadata-handler/dist"
  output_path = "${path.root}/../lambda/save-image-metadata-handler/build/save-image-metadata-handler.zip"
}

data "archive_file" "image_validation_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/image-validation-handler/dist"
  output_path = "${path.root}/../lambda/image-validation-handler/build/image-validation-handler.zip"
}

data "archive_file" "edit_image_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/edit-image-handler/dist"
  output_path = "${path.root}/../lambda/edit-image-handler/build/edit-image-handler.zip"
}
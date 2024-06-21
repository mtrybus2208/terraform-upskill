data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "dynamo_image_upload_handler_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.dynamo_image_upload_handler.function_name}:*"]
  }
}

data "aws_iam_policy_document" "dynamo_image_upload_handler_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
      "sns:Publish"
    ]
    resources = [
      var.image_metadata_table_stream_arn,
      aws_sns_topic.image_upload_notifications_topic.arn
    ]
  }
}

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

# sns_image_upload_handler fn

data "aws_iam_policy_document" "sns_image_upload_handler_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.sns_image_upload_handler.function_name}:*"]
  }
}


data "archive_file" "dynamo_image_upload_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/dynamo-image-upload-handler/dist"
  output_path = "${path.root}/../lambda/dynamo-image-upload-handler/build/dynamo-image-upload-handler.zip"
}

data "archive_file" "sns_image_upload_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/sns-image-upload-handler/dist"
  output_path = "${path.root}/../lambda/sns-image-upload-handler/build/sns-image-upload-handler.zip"
}

 
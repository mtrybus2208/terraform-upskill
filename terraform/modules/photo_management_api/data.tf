data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "logging_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.presigned_url_generator.function_name}:*"]
  }
}

data "aws_iam_policy_document" "photo_api_authorizer_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.photo_api_authorizer.function_name}:*"]
  }
}

data "aws_iam_policy_document" "get_single_image_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.get_single_image.function_name}:*"]
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

data "aws_iam_policy_document" "get_single_image_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "s3:GetObject"
    ]
    resources = [
      var.image_metadata_table_arn,
      "${var.image_metadata_table_arn}/*",
      "${var.photo_edit_lambda_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "get_images_for_user_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query",
      "s3:GetObject"
    ]
    resources = [
      var.image_metadata_table_arn,
      "${var.image_metadata_table_arn}/*",
      "${var.photo_edit_lambda_bucket_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "get_images_for_user_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

# archive_file lambda fn

data "archive_file" "get_images_for_user" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/get-images-for-user/dist"
  output_path = "${path.root}/../lambda/get-images-for-user/build/get-images-for-user-handler.zip"
}

data "archive_file" "get_single_image" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/get-single-image/dist"
  output_path = "${path.root}/../lambda/get-single-image/build/get-single-image-handler.zip"
}

data "archive_file" "presigned_url_generator" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/presigned-url-generator/dist"
  output_path = "${path.root}/../lambda/presigned-url-generator/build/presigned-url-generator-handler.zip"
}

data "archive_file" "photo_api_authorizer" {
  type        = "zip"
  source_dir  = "${path.root}/../lambda/photo-api-authorizer/dist"
  output_path = "${path.root}/../lambda/photo-api-authorizer/build/photo-api-authorizer.zip"
}
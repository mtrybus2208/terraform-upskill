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
resource "aws_iam_policy" "logging_policy" {
  description = "IAM policy allowing logging actions for Lambda functions."

  name   = "${local.environment}-logging-policy"
  policy = data.aws_iam_policy_document.logging_policy_doc.json
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

resource "aws_iam_role" "presigned_url_generator_role" {
  description = "IAM role for Lambda functions to allow logging actions."

  name               = "${local.environment}-logging-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "logging_policy_attachment" {
  role       = aws_iam_role.presigned_url_generator_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}
data "aws_iam_policy_document" "s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = [
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}",
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "${local.environment}-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.presigned_url_generator_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_role" "s3_upload_processor_role" {
  name               = "${local.environment}-s3-upload-processor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "s3_upload_processor_logging_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.s3_upload_processor.function_name}:*"]
  }
}

resource "aws_iam_policy" "s3_upload_processor_logging_policy" {
  name   = "${local.environment}-s3-upload-processor-logging-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_logging_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_logging_policy.arn
}
 
 
# sqs_message_processor
resource "aws_iam_role" "sqs_message_processor_role" {
  name               = "${local.environment}-sqs-message-processor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
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

resource "aws_iam_policy" "sqs_message_processor_logging_policy" {
  name   = "${local.environment}-sqs-message-processor-logging-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_logging_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_logging_policy.arn
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

resource "aws_iam_policy" "sqs_message_processor_sqs_access_policy" {
  name   = "${local.environment}-sqs-message-processor-sqs-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_sqs_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_sqs_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_sqs_access_policy.arn
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

resource "aws_iam_policy" "s3_upload_processor_sqs_send_message_policy" {
  name   = "${local.environment}-s3-upload-processor-sqs-send-message-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_sqs_send_message_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_sqs_send_message_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_sqs_send_message_policy.arn
}

# sqs_message_processor_dynamodb
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

resource "aws_iam_policy" "sqs_message_processor_dynamodb_access_policy" {
  name   = "${local.environment}-sqs-message-processor-dynamodb-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_dynamodb_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_dynamodb_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_dynamodb_access_policy.arn
}


# s3_upload_processor s3 role
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

resource "aws_iam_policy" "s3_upload_processor_get_object_policy" {
  name   = "${local.environment}-s3-upload-processor-get-object-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_get_object_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_get_object_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_get_object_policy.arn
}

# iam get_images_for_user lambda fn

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
data "aws_iam_policy_document" "get_images_for_user_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query",
      "s3:GetObject"
    ]
    resources = [
      aws_dynamodb_table.image_metadata.arn,
      "${aws_dynamodb_table.image_metadata.arn}/*",
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role" "get_images_for_user_role" {
  name               = "${local.environment}-get-images-for-user-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "get_images_for_user_policy" {
  name   = "${local.environment}-get-images-for-user-policy"
  policy = data.aws_iam_policy_document.get_images_for_user_policy_doc.json
}

resource "aws_iam_policy" "get_images_for_user_logging_policy" {
  name   = "${local.environment}-get-images-for-user-logging-policy"
  policy = data.aws_iam_policy_document.get_images_for_user_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "get_images_for_user_policy_attachment" {
  role       = aws_iam_role.get_images_for_user_role.name
  policy_arn = aws_iam_policy.get_images_for_user_policy.arn
}

resource "aws_iam_role_policy_attachment" "get_images_for_user_logging_policy_attachment" {
  role       = aws_iam_role.get_images_for_user_role.name
  policy_arn = aws_iam_policy.get_images_for_user_logging_policy.arn
}

# iam get_single_image lambda fn
resource "aws_iam_role" "get_single_image_role" {
  name               = "${local.environment}-get-single-image-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "get_single_image_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "s3:GetObject"
    ]
    resources = [
      aws_dynamodb_table.image_metadata.arn,
      "${aws_dynamodb_table.image_metadata.arn}/*",
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "get_single_image_policy" {
  name   = "${local.environment}-get-single-image-policy"
  policy = data.aws_iam_policy_document.get_single_image_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "get_single_image_policy_attachment" {
  role       = aws_iam_role.get_single_image_role.name
  policy_arn = aws_iam_policy.get_single_image_policy.arn
}

resource "aws_iam_role_policy_attachment" "get_single_image_logging_policy_attachment" {
  role       = aws_iam_role.get_single_image_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

# iam dynamo-image-upload-handler fn

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
      aws_dynamodb_table.image_metadata.stream_arn,
      aws_sns_topic.image_upload_notifications_topic.arn
    ]
  }
}

resource "aws_iam_policy" "dynamo_image_upload_handler_policy" {
  name   = "${local.environment}-dynamo-image-upload-handler-policy"
  policy = data.aws_iam_policy_document.dynamo_image_upload_handler_policy_doc.json
}

resource "aws_iam_policy" "dynamo_image_upload_handler_logging_policy" {
  description = "IAM policy allowing logging actions for dynamo_image_upload_handler lambda function."

  name   = "${local.environment}-dynamo-image-upload-handler-logging-policy"
  policy = data.aws_iam_policy_document.dynamo_image_upload_handler_logging_policy_doc.json
}

resource "aws_iam_role" "dynamo_image_upload_handler_role" {
  name               = "${local.environment}-dynamo-image-upload-handler"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "dynamo_image_upload_handler_attachment" {
  role       = aws_iam_role.dynamo_image_upload_handler_role.name
  policy_arn = aws_iam_policy.dynamo_image_upload_handler_policy.arn
}

resource "aws_iam_role_policy_attachment" "dynamo_image_upload_handler_logging_policy_attachment" {
  role       = aws_iam_role.dynamo_image_upload_handler_role.name
  policy_arn = aws_iam_policy.dynamo_image_upload_handler_logging_policy.arn
}

# iam photo_api_authorizer fn
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

resource "aws_iam_policy" "photo_api_authorizer_logging_policy" {
  description = "IAM policy allowing logging actions for photo_api_authorizer lambda function."

  name   = "${local.environment}-photo-api-authorizer-logging-policy"
  policy = data.aws_iam_policy_document.photo_api_authorizer_logging_policy_doc.json
}

resource "aws_iam_role" "photo_api_authorizer_role" {
  name               = "${local.environment}-photo-api-authorizer"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "photo_api_authorizer_logging_policy_attachment" {
  role       = aws_iam_role.photo_api_authorizer_role.name
  policy_arn = aws_iam_policy.photo_api_authorizer_logging_policy.arn
}
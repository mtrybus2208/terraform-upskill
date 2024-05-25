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
      "s3:ListBucket"
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

data "aws_iam_policy_document" "s3_upload_processor_s3_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}",
      "${aws_s3_bucket.photo_edit_lambda_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_upload_processor_s3_access_policy" {
  name   = "${local.environment}-s3-upload-processor-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_s3_access_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_s3_access_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_s3_access_policy.arn
}

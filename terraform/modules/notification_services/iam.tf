# iam dynamo-image-upload-handler fn

resource "aws_iam_policy" "dynamo_image_upload_handler_policy" {
  name   = "${var.environment}-dynamo-image-upload-handler-policy"
  policy = data.aws_iam_policy_document.dynamo_image_upload_handler_policy_doc.json
}

resource "aws_iam_policy" "dynamo_image_upload_handler_logging_policy" {
  description = "IAM policy allowing logging actions for dynamo_image_upload_handler lambda function."

  name   = "${var.environment}-dynamo-image-upload-handler-logging-policy"
  policy = data.aws_iam_policy_document.dynamo_image_upload_handler_logging_policy_doc.json
}

resource "aws_iam_role" "dynamo_image_upload_handler_role" {
  name               = "${var.environment}-dynamo-image-upload-handler"
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

# sns_image_upload_handler fn 

resource "aws_iam_policy" "sns_image_upload_handler_logging_policy" {
  description = "IAM policy allowing logging actions for sns_image_upload_handler lambda function."

  name   = "${var.environment}-sns-image-upload-handler-logging-policy"
  policy = data.aws_iam_policy_document.sns_image_upload_handler_logging_policy_doc.json
}


resource "aws_iam_role" "sns_image_upload_handler_role" {
  name               = "${var.environment}-sns-image-upload-handler"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "sns_image_upload_handler_logging_policy_attachment" {
  role       = aws_iam_role.sns_image_upload_handler_role.name
  policy_arn = aws_iam_policy.sns_image_upload_handler_logging_policy.arn
}
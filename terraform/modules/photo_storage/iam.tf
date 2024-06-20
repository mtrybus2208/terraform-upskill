# sqs_message_processor

resource "aws_iam_role" "sqs_message_processor_role" {
  name               = "${var.environment}-sqs-message-processor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_policy" "sqs_message_processor_logging_policy" {
  name   = "${var.environment}-sqs-message-processor-logging-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_logging_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_logging_policy.arn
}


resource "aws_iam_policy" "sqs_message_processor_sqs_access_policy" {
  name   = "${var.environment}-sqs-message-processor-sqs-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_sqs_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_sqs_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_sqs_access_policy.arn
}


# s3_upload_processor

resource "aws_iam_policy" "s3_upload_processor_sqs_send_message_policy" {
  name   = "${var.environment}-s3-upload-processor-sqs-send-message-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_sqs_send_message_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_sqs_send_message_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_sqs_send_message_policy.arn
}


resource "aws_iam_policy" "sqs_message_processor_dynamodb_access_policy" {
  name   = "${var.environment}-sqs-message-processor-dynamodb-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_dynamodb_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_dynamodb_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_dynamodb_access_policy.arn
}


resource "aws_iam_policy" "s3_upload_processor_get_object_policy" {
  name   = "${var.environment}-s3-upload-processor-get-object-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_get_object_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_get_object_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_get_object_policy.arn
}
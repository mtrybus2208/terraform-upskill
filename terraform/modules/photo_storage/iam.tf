# sqs_message_processor
resource "aws_iam_role" "sqs_message_processor_role" {
  name               = "${var.prefix}-sqs-message-processor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_policy" "sqs_message_processor_logging_policy" {
  name   = "${var.prefix}-sqs-message-processor-logging-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_logging_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_logging_policy.arn
}


resource "aws_iam_policy" "sqs_message_processor_sqs_access_policy" {
  name   = "${var.prefix}-sqs-message-processor-sqs-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_sqs_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_sqs_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_sqs_access_policy.arn
}
resource "aws_iam_policy" "sqs_message_processor_dynamodb_access_policy" {
  name   = "${var.prefix}-sqs-message-processor-dynamodb-access-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_dynamodb_access_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_dynamodb_access_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_dynamodb_access_policy.arn
}


resource "aws_iam_policy" "s3_upload_processor_get_object_policy" {
  name   = "${var.prefix}-s3-upload-processor-get-object-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_get_object_policy_doc.json
}

data "aws_iam_policy_document" "sqs_message_processor_step_functions_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.image_processing_state_machine.arn
    ]
  }
}

resource "aws_iam_policy" "sqs_message_processor_step_functions_policy" {
  name   = "${var.prefix}-sqs-message-processor-step-functions-policy"
  policy = data.aws_iam_policy_document.sqs_message_processor_step_functions_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "sqs_message_processor_step_functions_policy_attachment" {
  role       = aws_iam_role.sqs_message_processor_role.name
  policy_arn = aws_iam_policy.sqs_message_processor_step_functions_policy.arn
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
  name   = "${var.prefix}-s3_upload_processor-logging-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_logging_policy_doc.json
}

resource "aws_iam_role" "s3_upload_processor_role" {
  name               = "${var.prefix}-s3-upload-processor-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_logging_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_logging_policy.arn
}

resource "aws_iam_policy" "s3_upload_processor_sqs_send_message_policy" {
  name   = "${var.prefix}-s3-upload-processor-sqs-send-message-policy"
  policy = data.aws_iam_policy_document.s3_upload_processor_sqs_send_message_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_sqs_send_message_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_sqs_send_message_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_upload_processor_get_object_policy_attachment" {
  role       = aws_iam_role.s3_upload_processor_role.name
  policy_arn = aws_iam_policy.s3_upload_processor_get_object_policy.arn
}

# image_validation_handler
data "aws_iam_policy_document" "image_validation_handler_logging_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.image_validation_handler.function_name}:*"]
  }
}

resource "aws_iam_policy" "image_validation_handler_logging_policy" {

  name   = "${var.prefix}-image-validation-handler-logging-policy"
  policy = data.aws_iam_policy_document.image_validation_handler_logging_policy_doc.json
}

resource "aws_iam_role" "image_validation_handler_role" {
  name               = "${var.prefix}-image-validation-handler-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "image_validation_handler_logging_policy_attachment" {
  role       = aws_iam_role.image_validation_handler_role.name
  policy_arn = aws_iam_policy.image_validation_handler_logging_policy.arn
}
# data documents of the IAM role and policy.

data "aws_iam_policy_document" "image_processing_state_machine_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "image_processing_state_machine_invoke_lambda_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.image_validation_handler.arn,
      var.sns_image_upload_handler_arn,
      aws_lambda_function.save_image_metadata_handler.arn,
      aws_lambda_function.edit_image_handler.arn

    ]
  }
}

# IAM Role for Image Processing State Machine

resource "aws_iam_role" "image_processing_state_machine_role" {
  name               = "${var.prefix}-image-processing-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.image_processing_state_machine_policy_doc.json
}

resource "aws_iam_policy" "image_processing_state_machine_policy" {
  name   = "${var.prefix}-image-processing-state-machine-policy"
  policy = data.aws_iam_policy_document.image_processing_state_machine_invoke_lambda_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "image_processing_state_machine_policy_attachment" {
  role       = aws_iam_role.image_processing_state_machine_role.name
  policy_arn = aws_iam_policy.image_processing_state_machine_policy.arn
}

# State Machine for processing images
resource "aws_sfn_state_machine" "image_processing_state_machine" {
  name     = "${var.prefix}-image-processing-state-machine"
  role_arn = aws_iam_role.image_processing_state_machine_role.arn

  definition = <<EOF
{
  "Comment": "Image Processing State Machine",
  "StartAt": "ValidateImage",
  "States": {
    "ValidateImage": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.image_validation_handler.arn}",
      "ResultPath": "$.result",
      "Next": "IsImageValid"
    },
    "IsImageValid": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.result.validation.validationPassed",
          "BooleanEquals": true,
          "Next": "ParallelTasks"
        }
      ],
      "Default": "PublishValidationError"
    },
    "PublishValidationError": {
      "Type": "Task",
      "Resource": "${var.sns_image_upload_handler_arn}",
      "Parameters": {
        "userName.$": "$.result.metaData.userName",
        "message.$": "$.result.validation.message",
        "imageKey.$": "$.result.metaData.imageKey",
        "type.$": "$.result.validation.type"
      },
      "End": true
    },
    "ParallelTasks": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "SaveImageMetadata",
          "States": {
            "SaveImageMetadata": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.save_image_metadata_handler.arn}",
              "End": true
            }
          }
        },
        {
          "StartAt": "EditImage",
          "States": {
            "EditImage": {
              "Type": "Task",
              "Resource": "${aws_lambda_function.edit_image_handler.arn}",
              "End": true
            }
          }
        }
      ],
      "Next": "ExtractValues",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.errorInfo",
          "Next": "HandleError"
        }
      ]
    },
    "ExtractValues": {
      "Type": "Pass",
      "Parameters": {
        "userName.$": "$[0].result.metaData.userName",
        "message.$": "$[0].result.validation.message",
        "imageKey.$": "$[0].result.metaData.imageKey",
        "type": "IMAGE_CREATED"
      },
      "Next": "PublishImageCreated"
    },
    "PublishImageCreated": {
      "Type": "Task",
      "Resource": "${var.sns_image_upload_handler_arn}",
      "End": true
    },
    "HandleError": {
      "Type": "Pass",
      "Parameters": {
        "errorInfo.$": "$.errorInfo",
        "result.$": "$.result"
      },
      "Next": "PublishValidationError"
    }
  }
}
EOF
}

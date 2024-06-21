# photo_api_authorizer

resource "aws_iam_policy" "photo_api_authorizer_logging_policy" {
  description = "IAM policy allowing logging actions for photo_api_authorizer lambda function."

  name   = "${var.environment}-photo-api-authorizer-logging-policy"
  policy = data.aws_iam_policy_document.photo_api_authorizer_logging_policy_doc.json
}

resource "aws_iam_role" "photo_api_authorizer_role" {
  name               = "${var.environment}-photo-api-authorizer"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "photo_api_authorizer_logging_policy_attachment" {
  role       = aws_iam_role.photo_api_authorizer_role.name
  policy_arn = aws_iam_policy.photo_api_authorizer_logging_policy.arn
}


# get_images_for_user

resource "aws_iam_role" "get_images_for_user_role" {
  name               = "${var.environment}-get-images-for-user-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "get_images_for_user_policy" {
  name   = "${var.environment}-get-images-for-user-policy"
  policy = data.aws_iam_policy_document.get_images_for_user_policy_doc.json
}

resource "aws_iam_policy" "get_images_for_user_logging_policy" {
  name   = "${var.environment}-get-images-for-user-logging-policy"
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
  name               = "${var.environment}-get-single-image-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_policy" "get_single_image_policy" {
  name   = "${var.environment}-get-single-image-policy"
  policy = data.aws_iam_policy_document.get_single_image_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "get_single_image_policy_attachment" {
  role       = aws_iam_role.get_single_image_role.name
  policy_arn = aws_iam_policy.get_single_image_policy.arn
}

resource "aws_iam_policy" "get_single_image_logging_policy" {
  name   = "${var.environment}-get-single-image-logging-policy"
  policy = data.aws_iam_policy_document.get_single_image_logging_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "get_single_image_logging_policy_attachment" {
  role       = aws_iam_role.get_single_image_role.name
  policy_arn = aws_iam_policy.get_single_image_logging_policy.arn
}

# presigned_url_generator

resource "aws_iam_policy" "logging_policy" {
  description = "IAM policy allowing logging actions for Lambda functions."

  name   = "${var.environment}-logging-policy"
  policy = data.aws_iam_policy_document.logging_policy_doc.json
}

resource "aws_iam_role" "presigned_url_generator_role" {
  description = "IAM role for Lambda functions to allow logging actions."

  name               = "${var.environment}-logging-role"
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
      "${var.photo_edit_lambda_bucket_arn}",
      "${var.photo_edit_lambda_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name   = "${var.environment}-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.presigned_url_generator_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}
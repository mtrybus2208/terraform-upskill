resource "random_pet" "bucket_suffix" {
  length = 2

}
resource "aws_s3_bucket" "photo_edit_lambda_bucket" {
  bucket = "${local.environment}-lambda-photo-edit-handler-bucket-${random_pet.bucket_suffix.id}"

  force_destroy = true
  lifecycle {
    ignore_changes = [
      cors_rule
    ]
  }
}

resource "aws_s3_object" "presigned_url_generator" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "presigned-url-generator.zip"
  source = data.archive_file.presigned_url_generator.output_path
  etag   = filemd5(data.archive_file.presigned_url_generator.output_path)
}

resource "aws_s3_bucket_cors_configuration" "bucket_cors_null" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id

  cors_rule {
    allowed_methods = ["GET", "PUT"]
    allowed_origins = [var.allowed_origins]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "s3_upload_processor" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "s3-upload-processor.zip"
  source = data.archive_file.s3_upload_processor.output_path
  etag   = filemd5(data.archive_file.s3_upload_processor.output_path)
}

resource "aws_s3_bucket_notification" "photo_edit_lambda_bucket_notification" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_upload_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.s3_lambda_permission]
}

resource "aws_s3_object" "sqs_message_processor" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "sqs-message-processor.zip"
  source = data.archive_file.sqs_message_processor.output_path
  etag   = filemd5(data.archive_file.sqs_message_processor.output_path)
}

resource "aws_s3_object" "get_images_for_user" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "get-images-for-user.zip"
  source = data.archive_file.get_images_for_user.output_path
  etag   = filemd5(data.archive_file.get_images_for_user.output_path)
}


resource "aws_s3_object" "get_single_image" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "get-single-image.zip"
  source = data.archive_file.get_single_image.output_path
  etag   = filemd5(data.archive_file.get_single_image.output_path)
}

resource "aws_s3_object" "dynamo_image_upload_handler" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "dynamo-image-upload-handler.zip"
  source = data.archive_file.dynamo_image_upload_handler.output_path
  etag   = filemd5(data.archive_file.dynamo_image_upload_handler.output_path)
}

resource "aws_s3_object" "photo_api_authorizer" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "photo-api-authorizer.zip"
  source = data.archive_file.photo_api_authorizer.output_path
  etag   = filemd5(data.archive_file.photo_api_authorizer.output_path)
}

resource "aws_s3_object" "sns_image_upload_handler" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "sns-image-upload-handler.zip"
  source = data.archive_file.sns_image_upload_handler.output_path
  etag   = filemd5(data.archive_file.sns_image_upload_handler.output_path)
}


resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "photo_edit_lambda_bucket" {
  bucket = "${var.prefix}-lambda-photo-edit-handler-bucket-${random_pet.bucket_suffix.id}"

  force_destroy = true
  lifecycle {
    ignore_changes = [
      cors_rule
    ]
  }
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

resource "aws_s3_object" "image_validation_handler" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "image-validation-handler.zip"
  source = data.archive_file.image_validation_handler.output_path
  etag   = filemd5(data.archive_file.image_validation_handler.output_path)
}

resource "aws_s3_object" "save_image_metadata_handler" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "save-image-metadata-handler.zip"
  source = data.archive_file.save_image_metadata_handler.output_path
  etag   = filemd5(data.archive_file.save_image_metadata_handler.output_path)
}

resource "aws_s3_object" "edit_image_handler" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "edit-image-handler.zip"
  source = data.archive_file.edit_image_handler.output_path
  etag   = filemd5(data.archive_file.edit_image_handler.output_path)
}


# Bucket for storing processed images
resource "aws_s3_bucket" "processed_images_bucket" {
  bucket = "${var.prefix}-processed-images-bucket-${random_pet.bucket_suffix.id}"

  force_destroy = true
  lifecycle {
    ignore_changes = [
      cors_rule
    ]
  }
}

resource "aws_s3_bucket_cors_configuration" "processed_images_bucket_cors" {
  bucket = aws_s3_bucket.processed_images_bucket.id

  cors_rule {
    allowed_methods = ["GET", "PUT"]
    allowed_origins = [var.allowed_origins]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_object" "dynamo_image_upload_handler" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "dynamo-image-upload-handler.zip"
  source = data.archive_file.dynamo_image_upload_handler.output_path
  etag   = filemd5(data.archive_file.dynamo_image_upload_handler.output_path)
}

resource "aws_s3_object" "sns_image_upload_handler" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "sns-image-upload-handler.zip"
  source = data.archive_file.sns_image_upload_handler.output_path
  etag   = filemd5(data.archive_file.sns_image_upload_handler.output_path)
}

 
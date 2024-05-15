# Bucket creation and ownership controls
resource "aws_s3_bucket" "photo_edit_lambda_bucket" {
    bucket = "${local.environment}-lambda-photo-edit-handler-bucket"
    force_destroy = true
} 

resource "aws_s3_object" "presigned_url_generator" {
  bucket = aws_s3_bucket.photo_edit_lambda_bucket.id
  key    = "presigned-url-generator.zip"
  source = data.archive_file.presigned_url_generator.output_path
  etag   = filemd5(data.archive_file.presigned_url_generator.output_path)
}

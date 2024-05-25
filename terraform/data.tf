data "aws_caller_identity" "current" {}
data "archive_file" "presigned_url_generator" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/presigned-url-generator/dist"
  output_path = "${path.module}/../lambda/presigned-url-generator/build/presigned-url-generator-handler.zip"
}

data "archive_file" "s3_upload_processor" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/s3-upload-processor/dist"
  output_path = "${path.module}/../lambda/s3-upload-processor/build/s3-upload-processor-handler.zip"
}

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

data "archive_file" "sqs_message_processor" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/sqs-message-processor/dist"
  output_path = "${path.module}/../lambda/sqs-message-processor/build/sqs-message-processor-handler.zip"
}

data "archive_file" "get_images_for_user" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/get-images-for-user/dist"
  output_path = "${path.module}/../lambda/get-images-for-user/build/get-images-for-user-handler.zip"
}


data "archive_file" "get_single_image" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/get-single-image/dist"
  output_path = "${path.module}/../lambda/get-single-image/build/get-single-image-handler.zip"
}

data "archive_file" "dynamo_image_upload_handler" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/dynamo-image-upload-handler/dist"
  output_path = "${path.module}/../lambda/dynamo-image-upload-handler/build/dynamo-image-upload-handler.zip"
}

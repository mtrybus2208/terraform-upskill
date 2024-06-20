resource "aws_s3_object" "get_single_image" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "get-single-image.zip"
  source = data.archive_file.get_single_image.output_path
  etag   = filemd5(data.archive_file.get_single_image.output_path)
}

resource "aws_s3_object" "get_images_for_user" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "get-images-for-user.zip"
  source = data.archive_file.get_images_for_user.output_path
  etag   = filemd5(data.archive_file.get_images_for_user.output_path)
}

resource "aws_s3_object" "presigned_url_generator" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "presigned-url-generator.zip"
  source = data.archive_file.presigned_url_generator.output_path
  etag   = filemd5(data.archive_file.presigned_url_generator.output_path)
}

resource "aws_s3_object" "photo_api_authorizer" {
  bucket = var.photo_edit_lambda_bucket_id
  key    = "photo-api-authorizer.zip"
  source = data.archive_file.photo_api_authorizer.output_path
  etag   = filemd5(data.archive_file.photo_api_authorizer.output_path)
}

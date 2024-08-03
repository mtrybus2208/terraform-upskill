output "photo_edit_lambda_bucket_id" {
  value = aws_s3_bucket.photo_edit_lambda_bucket.id
}

output "photo_edit_lambda_bucket_name" {
  value = aws_s3_bucket.photo_edit_lambda_bucket.bucket
}

output "image_metadata_table_name" {
  value = aws_dynamodb_table.image_metadata.name
}

output "image_metadata_table_arn" {
  value = aws_dynamodb_table.image_metadata.arn
}

output "image_metadata_table_stream_arn" {
  value = aws_dynamodb_table.image_metadata.stream_arn
}

output "photo_edit_lambda_bucket_arn" {
  value = aws_s3_bucket.photo_edit_lambda_bucket.arn
}
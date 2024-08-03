output "image_upload_notifications_topic_arn" {
  value = aws_sns_topic.image_upload_notifications_topic.arn
}

output "sns_image_upload_handler_arn" {
  value = aws_lambda_function.sns_image_upload_handler.arn
}
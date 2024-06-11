resource "aws_sns_topic" "image_upload_notifications_topic" {
    name = "${local.environment}-image-upload-notifications-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.image_upload_notifications_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
resource "aws_sqs_queue" "sqs_queue" {
  name                        = "${local.environment}-sqs-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

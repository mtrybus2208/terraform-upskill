resource "aws_sqs_queue" "sqs_queue" {
  name                        = "${var.prefix}-sqs-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
}

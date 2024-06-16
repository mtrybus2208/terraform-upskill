resource "aws_dynamodb_table" "image_metadata" {
  name         = "${local.environment}-image-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userName"
  range_key    = "imageId"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "userName"
    type = "S"
  }

  attribute {
    name = "imageId"
    type = "S"
  }

  attribute {
    name = "imageName"
    type = "S"
  }

  local_secondary_index {
    name            = "IMAGE_NAME_LSI"
    projection_type = "ALL"
    range_key       = "imageName"
  }

  tags = {
    Environment = local.environment
  }
} 
resource "aws_dynamodb_table" "image_metadata" {
  name         = "${local.environment}-image-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "imageId"

  attribute {
    name = "imageId"
    type = "S"
  }

  attribute {
    name = "imageName"
    type = "S"
  }

global_secondary_index {
  name            = "IMAGE_NAME_GSI"
  hash_key        = "imageName"
  projection_type = "ALL"
}

  tags = {
    Environment = local.environment
  }
}

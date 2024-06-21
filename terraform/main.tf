
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner = local.prefix
      Name  = local.prefix
    }
  }
}

module "photo_management_api" {
  source = "./modules/photo_management_api"

  environment     = local.prefix
  allowed_origins = var.allowed_origins
  photo_edit_lambda_bucket_id   = module.photo_storage.photo_edit_lambda_bucket_id
  photo_edit_lambda_bucket_name = module.photo_storage.photo_edit_lambda_bucket_name
  image_metadata_table_name     = module.photo_storage.image_metadata_table_name
  image_metadata_table_arn      = module.photo_storage.image_metadata_table_arn
  photo_edit_lambda_bucket_arn  = module.photo_storage.photo_edit_lambda_bucket_arn
  stage           = var.environment
}

module "photo_storage" {
  source = "./modules/photo_storage"

  region          = var.region
  environment     = local.prefix
  allowed_origins = var.allowed_origins
 
}

module "notification_services" {
  source = "./modules/notification_services"

  region             = var.region
  environment        = local.prefix
  photo_edit_lambda_bucket_id   = module.photo_storage.photo_edit_lambda_bucket_id
  image_metadata_table_arn      = module.photo_storage.image_metadata_table_arn
  image_metadata_table_name     = module.photo_storage.image_metadata_table_name
  photo_edit_lambda_bucket_name = module.photo_storage.photo_edit_lambda_bucket_name
  image_metadata_table_stream_arn = module.photo_storage.image_metadata_table_stream_arn
}

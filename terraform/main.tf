
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

  environment                   = local.prefix
  allowed_origins               = var.allowed_origins
  photo_edit_lambda_bucket_id   = module.photo_storage.photo_edit_lambda_bucket_id
  photo_edit_lambda_bucket_name = module.photo_storage.photo_edit_lambda_bucket_name
  image_metadata_table_name     = module.photo_storage.image_metadata_table_name
  image_metadata_table_arn      = module.photo_storage.image_metadata_table_arn
  photo_edit_lambda_bucket_arn  = module.photo_storage.photo_edit_lambda_bucket_arn
  stage                         = var.environment
  user_pool_id                  = module.auth.user_pool_id
  user_pool_endpoint            = module.auth.user_pool_endpoint
  user_pool_client_id           = module.auth.user_pool_client_id
  prefix                        = local.prefix
}

module "photo_storage" {
  source = "./modules/photo_storage"

  region                               = var.region
  environment                          = local.prefix
  allowed_origins                      = var.allowed_origins
  prefix                               = local.prefix
  image_upload_notifications_topic_arn = module.notification_services.image_upload_notifications_topic_arn
  sns_image_upload_handler_arn         = module.notification_services.sns_image_upload_handler_arn

}

module "notification_services" {
  source = "./modules/notification_services"

  region                               = var.region
  environment                          = local.prefix
  photo_edit_lambda_bucket_id          = module.photo_storage.photo_edit_lambda_bucket_id
  image_metadata_table_arn             = module.photo_storage.image_metadata_table_arn
  image_metadata_table_name            = module.photo_storage.image_metadata_table_name
  photo_edit_lambda_bucket_name        = module.photo_storage.photo_edit_lambda_bucket_name
  image_metadata_table_stream_arn      = module.photo_storage.image_metadata_table_stream_arn
  prefix                               = local.prefix
  notification_email                   = var.notification_email
  image_upload_notifications_topic_arn = module.notification_services.image_upload_notifications_topic_arn

}

module "auth" {
  source = "./modules/auth"

  region               = var.region
  environment          = local.prefix
  callback_urls        = var.callback_urls
  logout_urls          = var.logout_urls
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  prefix               = local.prefix

}
variable "environment" {
  type = string
}

variable "prefix" {
  type = string
}


variable "allowed_origins" {
  description = "Allowed origins for CORS"
  type        = string
  default     = "*"
}

variable "region" {
  type        = string
  description = "AWS region identifier."
  default     = "us-east-2"
  validation {
    condition     = can(regex("^[a-z-]+-[0-9]$", var.region))
    error_message = "Must be a valid AWS region identifier."
  }
}

variable "valid_token_mock" {
  description = "Mocked value for auth token"
  type        = string
  default     = "secretToken"
}

variable "photo_edit_lambda_bucket_id" {
  description = "ID of the photo edit Lambda bucket"
  type        = string
}

variable "photo_edit_lambda_bucket_name" {
  description = "name of the photo edit Lambda bucket"
  type        = string
}

variable "image_metadata_table_name" {
  description = "image metadata table name"
  type        = string
}

variable "image_metadata_table_arn" {
  description = "image metadata table arn"
  type        = string
}

variable "photo_edit_lambda_bucket_arn" {
  description = "photo edit lambda bucket arn"
  type        = string
}

variable "stage" {
  type = string
}

variable "user_pool_id" {
  description = "user pool id"
  type        = string
}

variable "user_pool_endpoint" {
  description = "user pool endpoint"
  type        = string
}

variable "user_pool_client_id" {
  description = "user pool client id"
  type        = string
}

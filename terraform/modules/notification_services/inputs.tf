variable "environment" {
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

variable "notification_email" {
  description = "Email to sns image upload notofication"
  type        = string
  default     = "test123@gmail.com"
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

variable "image_metadata_table_stream_arn" {
  description = "image metadata table stream arn"
  type        = string
}

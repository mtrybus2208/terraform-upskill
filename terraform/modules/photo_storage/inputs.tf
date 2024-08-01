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

variable "image_upload_notifications_topic_arn" {
  description = "sns notification table arn"
  type        = string
}

variable "sns_image_upload_handler_arn" {
  description = "sns notidication lambda arn"
  type        = string
}
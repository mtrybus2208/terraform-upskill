variable "region" {
  type        = string
  description = "AWS region identifier."
  default     = "us-east-2"
  validation {
    condition     = can(regex("^[a-z-]+-[0-9]$", var.region))
    error_message = "Must be a valid AWS region identifier."
  }
}

variable "environment" {
  description = "The environment to deploy (dev or prod)"
  type        = string
  default     = "dev"
}

variable "allowed_origins" {
  description = "Allowed origins for CORS"
  type        = string
  default     = "*"
}

variable "callback_urls" {
  description = "List of callback URLs"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of logout URLs"
  type        = list(string)
}


variable "google_client_id" {
  description = "The client ID for Google OAuth"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "The client secret for Google OAuth"
  type        = string
  sensitive   = true
}

variable "notification_email" {
  description = "Email to sns image upload notofication"
  type        = string
  default     = "test123@gmail.com"
}
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

variable "notification_email" {
  description = "Email to sns image upload notofication"
  type        = string
  default     = "test123@gmail.com"
}

variable "valid_token_mock" {
  description = "Mocked value for auth token"
  type        = string
  default     = "secretToken"
}
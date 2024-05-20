variable "region" {
  type        = string
  description = "AWS region identifier."
  default     = "eu-west-1"
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


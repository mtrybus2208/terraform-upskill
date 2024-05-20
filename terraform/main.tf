
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner = local.environment
      Name  = local.environment
    }
  }
}

 

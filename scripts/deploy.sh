#!/bin/bash

# Check environment argument
if [ "$1" = "dev" ]; then
  export TF_VAR_FILE="../terraform/dev.tfvars"
elif [ "$1" = "prod" ]; then
  export TF_VAR_FILE="../terraform/prod.tfvars"
else
  echo "Usage: $0 {dev|prod}"
  exit 1
fi

# Build Lambda handlers
cd lambda/presigned-url-generator || exit
npm install
npm run build
cd ../../

# Initialize Terraform
cd terraform || exit
terraform init

# Apply Terraform configuration
terraform apply -var-file="${TF_VAR_FILE}"

# Return to the project root
cd ..

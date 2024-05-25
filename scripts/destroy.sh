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

# Destroy Terraform configuration
cd terraform || exit
terraform destroy -var-file="${TF_VAR_FILE}"

# Return to the project root
cd ..

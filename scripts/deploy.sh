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
for dir in lambda/*/; do
  # Skip the shared directory
  if [ "$dir" == "lambda/shared/" ]; then
    continue
  fi
  
  if [ -f "${dir}package.json" ]; then
    cd "$dir" || exit
    npm install
    npm run build
    cd - || exit
  fi
done

# Initialize Terraform
cd terraform || exit
terraform init

# Apply Terraform configuration
terraform apply -var-file="${TF_VAR_FILE}"

# Return to the project root
cd ..

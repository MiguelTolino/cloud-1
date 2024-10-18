#!/bin/bash

# Set the environment variable for GCP credentials
export GOOGLE_CLOUD_KEYFILE_JSON="cloud-1-key.json"

# Initialize Terraform
terraform init

# Plan the Terraform configuration
terraform plan

# Apply the Terraform configuration
terraform apply -auto-approve
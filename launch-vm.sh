#!/bin/bash
VM_NAME="cloud-1"
VM_ZONE="us-central1-c"

# Set the environment variable for GCP credentials
export GOOGLE_CLOUD_KEYFILE_JSON="cloud-1-key.json"

# Initialize Terraform
terraform init

# Plan the Terraform configuration
terraform plan

# Apply the Terraform configuration
terraform apply -auto-approve

gcloud compute instances add-metadata $VM_NAME \
  --zone=us-central1-c \
  --metadata-from-file startup-script=./startup.sh

# Wait for the VM to be ready
echo "Waiting for VM to be ready..."
while ! gcloud compute ssh $VM_NAME --zone=$VM_ZONE --command="echo VM is ready"; do
  echo "VM is not ready yet. Retrying in 10 seconds..."
  sleep 10
done

gcloud compute scp ./.env $VM_NAME:~/.env --zone $VM_ZONE
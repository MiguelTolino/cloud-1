#!/bin/bash

# Exit on error
set -e

VM_NAME="cloud-1"
VM_ZONE="us-central1-c"

# Set the environment variable for GCP credentials
export GOOGLE_CLOUD_KEYFILE_JSON="cloud-1-key.json"

# Check if .env exists before starting
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found. Please create it before running this script."
    exit 1
fi

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply the Terraform configuration
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Get the external IP from Terraform outputs
EXTERNAL_IP=$(terraform output -json instance_ips | jq -r '.[0]')

# Wait for the VM to be ready
echo "Waiting for VM ($VM_NAME at $EXTERNAL_IP) to be ready..."
sleep 5
while ! gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="echo VM is ready" --quiet; do
  echo "VM is not ready yet. Retrying in 10 seconds..."
  sleep 10
done

# Copy the .env file to the VM
echo "Copying .env file to VM..."
gcloud compute scp ./.env "$VM_NAME:~/.env" --zone "$VM_ZONE" --quiet

echo "VM is ready and .env file has been uploaded."
echo "You can check the startup script logs with:"
echo "gcloud compute ssh $VM_NAME --zone=$VM_ZONE --command='tail -f /var/log/startup-script.log'"
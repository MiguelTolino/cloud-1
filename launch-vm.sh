#!/bin/bash

# Exit on error
set -e

# VM_NAME="cloud-1" (Removed as we scale to multiple instances)
VM_ZONE="europe-west1-b"

# Set the environment variable for GCP credentials
export GOOGLE_CLOUD_KEYFILE_JSON="cloud-1-key.json"

# Check if required tools are installed
for tool in gcloud terraform jq; do
    if ! command -v "$tool" &> /dev/null; then
        echo "ERROR: $tool is not installed. Please install it before running this script."
        exit 1
    fi
done

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

# Get the external IPs from Terraform outputs
EXTERNAL_IPS=$(terraform output -json instance_ips | jq -r '.[]')

# Wait for all VMs to be ready
echo "Waiting for VMs to be ready..."
for IP in $EXTERNAL_IPS; do
    # Find the instance name for this IP
    VM_NAME=$(gcloud compute instances list --filter="networkInterfaces[0].accessConfigs[0].natIP=$IP" --format="get(name)")
    
    echo "Waiting for VM ($VM_NAME at $IP) to be ready..."
    sleep 5
    while ! gcloud compute ssh "$VM_NAME" --zone="$VM_ZONE" --command="echo VM is ready" --quiet; do
      echo "VM $VM_NAME is not ready yet. Retrying in 10 seconds..."
      sleep 10
    done
    echo "VM $VM_NAME is ready."
done

echo "All VMs are ready. The .env file has been automatically configured via instance metadata."
echo "External IPs:"
echo "$EXTERNAL_IPS"
echo ""
echo "You can check the startup script logs for each VM with:"
for IP in $EXTERNAL_IPS; do
    VM_NAME=$(gcloud compute instances list --filter="networkInterfaces[0].accessConfigs[0].natIP=$IP" --format="get(name)")
    echo "gcloud compute ssh $VM_NAME --zone=$VM_ZONE --command='tail -f /var/log/startup-script.log'"
done
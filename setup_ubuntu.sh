#!/bin/bash

# Exit on error, pipefail, and undefined variables
set -euo pipefail

# Make apt non-interactive
export DEBIAN_FRONTEND=noninteractive

echo "Starting installation of Terraform and Google Cloud CLI on Ubuntu..."

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Install required dependencies
echo "Installing required dependencies..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    jq \
    curl \
    gnupg \
    lsb-release \
    wget \
    unzip \
    software-properties-common

# --- Install Terraform (Manual - Official Binary) ---
if ! command -v terraform &> /dev/null; then
    echo "Installing Terraform using official binaries..."

    # Get latest Terraform version
    TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | \
        grep -oP '"current_version":"\K[^"]+')

    echo "Latest Terraform version: ${TERRAFORM_VERSION}"

    # Download Terraform binary
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

    # Unzip and install
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    sudo chmod +x /usr/local/bin/terraform

    # Cleanup
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

else
    echo "Terraform is already installed: $(terraform --version | head -n 1)"
fi

# --- Install Google Cloud CLI ---
if ! command -v gcloud &> /dev/null; then
    echo "Installing Google Cloud CLI..."

    # Add Google Cloud GPG key
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg --yes

    # Add Google Cloud repository
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

    # Update and install
    sudo apt-get update -y
    sudo apt-get install -y google-cloud-cli
else
    echo "Google Cloud CLI is already installed: $(gcloud --version | head -n 1)"
fi

# Verify installations
echo "--- Final Verification ---"
terraform --version
gcloud --version

echo "Installation completed successfully!"
echo "Next steps:"
echo "1. Run 'gcloud init' to initialize Google Cloud CLI"
echo "2. Authenticate with your Google Cloud account"
echo "3. Select your default project"


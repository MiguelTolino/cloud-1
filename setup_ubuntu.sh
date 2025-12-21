#!/bin/bash

# Exit on error
set -e

echo "Starting installation of Terraform and Google Cloud CLI on Ubuntu..."

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install required dependencies
echo "Installing required dependencies..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    software-properties-common

# Install Terraform
echo "Installing Terraform..."
# Add HashiCorp GPG key using modern method
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package list again
sudo apt-get update

# Install Terraform
sudo apt-get install -y terraform

# Install Google Cloud CLI
echo "Installing Google Cloud CLI..."
# Add Google Cloud GPG key using modern method
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add Google Cloud repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Update package list again
sudo apt-get update

# Install Google Cloud SDK
sudo apt-get install -y google-cloud-cli

# Verify installations
echo "Verifying installations..."
terraform --version
gcloud --version

echo "Installation completed successfully!"
echo "Next steps:"
echo "1. Run 'gcloud init' to initialize Google Cloud CLI"
echo "2. Authenticate with your Google Cloud account"
echo "3. Select your default project"
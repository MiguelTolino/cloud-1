#!/bin/bash

# Exit on error, pipefail, and undefined variables
set -euo pipefail

# Redirect all output to a log file for debugging
log_file="/var/log/startup-script.log"
exec > >(tee -a "$log_file") 2>&1

echo "--- Starting Startup Script: $(date) ---"

# Update package list and install packages
echo "Updating packages..."
apt-get update
apt-get install -y make docker.io docker-compose git

# Ensure Docker is running
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Define repository information
REPO_URL="https://github.com/MiguelTolino/inception.git"
REPO_DIR="/home/migueltolino/inception"

# Clone the repository if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning inception repository..."
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "Repository already exists at $REPO_DIR. Pulling latest changes..."
    cd "$REPO_DIR"
    git pull
fi

# Set ownership to the user
chown -R migueltolino:migueltolino "$REPO_DIR"

# Handle .env file
ENV_SRC="/home/migueltolino/.env"
ENV_DEST="$REPO_DIR/srcs/.env"

if [ -f "$ENV_SRC" ]; then
    echo "Moving .env to inception directory..."
    cp "$ENV_SRC" "$ENV_DEST"
    chown migueltolino:migueltolino "$ENV_DEST"
else
    echo "WARNING: .env file not found at $ENV_SRC. Make sure to upload it via SCP."
fi

# Build and run containers
echo "Starting Docker containers..."
cd "$REPO_DIR"
make all || echo "ERROR: 'make all' failed. Check logs."

echo "--- Startup Script Completed: $(date) ---"
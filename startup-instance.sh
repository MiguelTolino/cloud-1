#!/bin/bash

# Exit on error, pipefail, and undefined variables
set -euo pipefail

# Redirect all output to a log file for debugging
log_file="/var/log/startup-script.log"
exec > >(tee -a "$log_file") 2>&1

echo "--- Starting Startup Script: $(date) ---"

# Get the instance username
INSTANCE_USER="${USER:-$(whoami)}"

# Update package list and install prerequisites
echo "Updating packages..."
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    make \
    git

# --- Persistent Disk Setup ---
DISK_DEVICE="/dev/disk/by-id/google-data_disk"
# We'll use a standard data directory. Inception usually expects /home/$USER/data
# Since we are root here, we need to be careful. 
# Identifying the intended user (migueltolino?) is tricky if just 'root' runs this.
# Assuming INSTANCE_USER is correct or we use a fixed path.
DATA_DIR="/home/$INSTANCE_USER/data"

echo "Checking for persistent disk at $DISK_DEVICE..."
if [ -e "$DISK_DEVICE" ]; then
    echo "Found persistent disk."
    
    # Format if not formatted
    if ! blkid "$DISK_DEVICE"; then
        echo "Formatting disk as ext4..."
        mkfs.ext4 -F "$DISK_DEVICE"
    fi

    # Create mount point
    mkdir -p "$DATA_DIR"
    
    # Mount if not mounted
    if ! mountpoint -q "$DATA_DIR"; then
        echo "Mounting disk to $DATA_DIR..."
        mount "$DISK_DEVICE" "$DATA_DIR"
    fi
    
    # Set permissions
    chown -R "$INSTANCE_USER:$INSTANCE_USER" "$DATA_DIR"
    echo "Persistent disk mounted at $DATA_DIR"
else
    echo "WARNING: Persistent disk not found at $DISK_DEVICE"
fi
# -----------------------------

# Install Docker from official repository
echo "Installing Docker..."
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
fi

# Install Docker Engine and Docker Compose plugin
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ensure Docker is running
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group to run docker without sudo
echo "Adding user to docker group..."
sudo usermod -aG docker "$INSTANCE_USER"

# Verify docker-compose installation
echo "Verifying docker-compose installation..."
sudo docker compose version || echo "WARNING: docker compose command not available"

# Define repository information
REPO_URL="https://github.com/MiguelTolino/inception.git"
REPO_DIR="/home/$INSTANCE_USER/inception"

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
sudo chown -R "$INSTANCE_USER:$INSTANCE_USER" "$REPO_DIR"

# Ensure the srcs directory exists inside the inception repo
SRCS_DIR="$REPO_DIR/srcs"
if [ ! -d "$SRCS_DIR" ]; then
    echo "Creating srcs directory in inception repo..."
    mkdir -p "$SRCS_DIR"
    sudo chown "$INSTANCE_USER:$INSTANCE_USER" "$SRCS_DIR"
fi

# Handle .env file from instance metadata
# The .env file must be saved inside inception/srcs/.env
ENV_DEST="$SRCS_DIR/.env"

echo "Retrieving .env from instance metadata..."
ENV_CONTENT=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/attributes/env-file" -H "Metadata-Flavor: Google")

if [ -n "$ENV_CONTENT" ]; then
    echo "Creating .env file from metadata in inception/srcs/.env..."
    echo "$ENV_CONTENT" > "$ENV_DEST"
    sudo chown "$INSTANCE_USER:$INSTANCE_USER" "$ENV_DEST"
    sudo chmod 600 "$ENV_DEST"
    echo ".env file created successfully at $ENV_DEST (inside inception/srcs/)"
else
    echo "WARNING: .env content not found in metadata. Trying fallback from /home/$INSTANCE_USER/.env..."
    ENV_SRC="/home/$INSTANCE_USER/.env"
    if [ -f "$ENV_SRC" ]; then
        echo "Found .env at $ENV_SRC, copying to inception/srcs/.env..."
        cp "$ENV_SRC" "$ENV_DEST"
        sudo chown "$INSTANCE_USER:$INSTANCE_USER" "$ENV_DEST"
        sudo chmod 600 "$ENV_DEST"
        echo ".env file copied successfully to $ENV_DEST (inside inception/srcs/)"
    else
        echo "ERROR: .env file not found in metadata or at $ENV_SRC. Docker-compose may fail."
    fi
fi

# Build and run containers
echo "Starting Docker containers..."
cd "$REPO_DIR"
sudo -u "$INSTANCE_USER" make all || echo "ERROR: 'make all' failed. Check logs."

echo "--- Startup Script Completed: $(date) ---"
#!/bin/bash

# Update package list and install packages
sudo apt update
sudo apt install -y make docker.io docker-compose

# Reiniciar el servicio Docker
echo "Reiniciando el servicio Docker..."
sudo systemctl restart docker

# Clonar el repositorio de Inception
git clone https://github.com/MiguelTolino/inception.git

# Add .env inside the inception folder
cp home/migueltolino/.env inception/srcs/

# Build the Docker images and run the containers
cd inception
make all
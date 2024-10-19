#!/bin/bash

# Update package list and install packages
sudo apt update
sudo apt install -y make docker.io docker-compose

# Agregar el usuario actual al grupo docker
echo "Añadiendo el usuario $(whoami) al grupo 'docker'..."
sudo usermod -aG docker $USER

# Reiniciar el servicio Docker
echo "Reiniciando el servicio Docker..."
sudo systemctl restart docker

# Aplicar el grupo 'docker' sin cerrar sesión
echo "Aplicando el nuevo grupo 'docker' para el usuario actual..."
sudo newgrp docker

# Clonar el repositorio de Inception
git clone https://github.com/MiguelTolino/inception.git
cd inception

# Add .env inside the inception folder
cp ~/.env srcs/.env

# Build the Docker images
make all
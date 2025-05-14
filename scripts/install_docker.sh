#!/bin/bash

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER
sudo usermod -aG docker adminuser

# Buscar si existe el usuario jenkins o Jenkins
if id "jenkins" &>/dev/null; then
    user="jenkins"
elif id "Jenkins" &>/dev/null; then
    user="Jenkins"
else
    echo "❌ No se encontró el usuario 'jenkins' ni 'Jenkins'."
    exit 1
fi

# Agregar el usuario al grupo docker
echo "✅ Usuario encontrado: $user. Agregando al grupo docker..."
sudo usermod -aG docker "$user"

# Confirmación
echo "✅ Usuario '$user' agregado al grupo docker."

newgrp docker
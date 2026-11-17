#!/bin/bash
# Recibe la variable hostname definida en el templatefile de Terraform
HOSTNAME_INICIAL="${hostname}"

# 1. Configurar el Hostname del servidor
hostnamectl set-hostname $HOSTNAME_INICIAL
echo "127.0.0.1 $HOSTNAME_INICIAL" >> /etc/hosts

# 2. Configurar la zona horaria a Europe/Madrid[cite: 2]
timedatectl set-timezone Europe/Madrid

# 3. Actualizar el sistema e instalar Docker
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Añadir clave GPG oficial de Docker y repositorio
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# 4. Dar permisos al usuario ubuntu para usar docker sin sudo
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker
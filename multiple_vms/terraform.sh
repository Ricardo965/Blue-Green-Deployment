#!/bin/bash

set -e  # Detener ejecución si ocurre un error

# Ir al directorio del script
cd "$(dirname "$0")"

VAR_FILE="secrets.tfvars"

# Verificar si Terraform ya está inicializado
if [ ! -d ".terraform" ]; then
    echo "🔹 Inicializando Terraform..."
    terraform init
else
    echo "✅ Terraform ya está inicializado. Saltando init..."
fi

# Formatear código
echo "🔹 Ejecutando terraform fmt..."
terraform fmt

# Validar configuración
echo "🔹 Validando configuración..."
terraform validate

# Verificar si las máquinas ya están creadas
EXISTING_MACHINES=$(terraform state list | grep "azurerm_linux_virtual_machine.vm_devops" || true)

if [ -n "$EXISTING_MACHINES" ]; then
    echo "✅ Máquinas ya creadas. Saltando terraform apply..."
else
    # Mostrar el plan
    echo "🔹 Generando plan..."
    terraform plan -var-file="$VAR_FILE"

    # Aplicar cambios
    echo "🔹 Aplicando cambios..."
    terraform apply -auto-approve -var-file="$VAR_FILE"
fi

# Obtener y mostrar IPs y nombres de las máquinas
echo "🔹 Obteniendo IPs y nombres de las máquinas..."
terraform output -json ip_servers | jq -r '.[] | "\(.name | gsub("-machine"; "")): \(.ip)"' > ../vm_ips.txt

echo "✅ ¡Infraestructura lista!"


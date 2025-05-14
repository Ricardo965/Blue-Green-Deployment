#!/bin/bash

# Ruta base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_IP_FILE="$BASE_DIR/../vm_ips.txt"
SCRIPT_DIR="$BASE_DIR"
REMOTE_USER="adminuser" # Cambia si tu user no es ubuntu
SSH_KEY="$BASE_DIR/../cluster/devops-key.pem" # Si usas clave privada
USE_PASSWORD=true  # Cambiar a true si usas contraseña en lugar de clave

# Contraseña común (solo si USE_PASSWORD=true)
PASSWORD="SecretPassword1234!"

# Pares nombre_vm => scripts a ejecutar
declare -A SCRIPT_MAP
SCRIPT_MAP["jenkins"]="install_jenkins.sh install_docker.sh install_trivy.sh install_kubectl.sh"
SCRIPT_MAP["nexus"]="install_docker.sh run_nexus.sh"
SCRIPT_MAP["sonar"]="install_docker.sh run_sonar.sh"

# Función para ejecutar comandos remotamente
execute_remote() {
    local ip=$1
    local scripts=($2)

    echo "Conectando a $ip..."

    if [ "$USE_PASSWORD" = true ]; then
        for script in "${scripts[@]}"; do
            echo "Copiando $script a $ip..."
            sshpass -p "$PASSWORD" scp "$SCRIPT_DIR/$script" "$REMOTE_USER@$ip:/tmp"

            echo "Ejecutando $script en $ip..."
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$REMOTE_USER@$ip" "chmod +x /tmp/$script && sudo /tmp/$script"
        done
    else
        for script in "${scripts[@]}"; do
            echo "Copiando $script a $ip..."
            scp -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SCRIPT_DIR/$script" "$REMOTE_USER@$ip:/tmp"

            echo "Ejecutando $script en $ip..."
            ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$REMOTE_USER@$ip" "chmod +x /tmp/$script && sudo /tmp/$script"
        done
    fi
}

# Validación de herramientas requeridas
check_dependencies() {
    for tool in scp ssh; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool no está instalado."
            exit 1
        fi
    done

    if [ "$USE_PASSWORD" = true ] && ! command -v sshpass &> /dev/null; then
        echo "Error: sshpass es necesario para autenticación con contraseña."
        exit 1
    fi
}

main() {
    check_dependencies

    while IFS=: read -r name ip; do
        name=$(echo "$name" | xargs)  # eliminar espacios
        ip=$(echo "$ip" | xargs)

        if [[ -z "$name" || -z "$ip" ]]; then
            echo "Línea inválida en vm_ips.txt: $name:$ip"
            continue
        fi
        echo "Procesando VM: '$name' con IP: '$ip'"

        scripts="${SCRIPT_MAP[$name]}"
        if [ -z "$scripts" ]; then
            echo "No hay scripts definidos para '$name'"
            continue
        fi

        execute_remote "$ip" "$scripts"
    done < "$VM_IP_FILE"
}

main

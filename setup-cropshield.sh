#!/bin/bash

# Función para enviar 'yes' seguido de Enter automáticamente
send_yes() {
  echo "yes"
  sleep 1 # Opcional: agregar un breve retardo para asegurar que 'yes' se envíe correctamente
  echo ""
}

# Crear el directorio 'projects' y cambiar al directorio
mkdir -p projects
cd projects

# Clonar el repositorio de GitHub
git clone https://github.com/JordyV3/cropshield-api-ia.git

# Cambiar al directorio del proyecto clonado
cd cropshield-api-ia/

# Actualizar la lista de paquetes disponibles e instalar dependencias
send_yes | sudo apt update
send_yes | sudo apt install -y python3-pip python3-dev python3-setuptools python3-venv

# Crear y activar el entorno virtual
python3 -m venv env
source env/bin/activate

# Instalar las dependencias del proyecto
send_yes | pip install --upgrade pip
pip install -r requirements.txt

# Mostrar un mensaje al finalizar
echo "El entorno de desarrollo ha sido configurado correctamente."

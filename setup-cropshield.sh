#!/bin/bash

clear
#Bienvenida 

echo " #####                        #####                                    "
echo "#     # #####   ####  #####  #     # #    # # ###### #      #####     "
echo "#       #    # #    # #    # #       #    # # #      #      #    #    "
echo "#       #    # #    # #    #  #####  ###### # #####  #      #    #    "
echo "#       #####  #    # #####        # #    # # #      #      #    #    "
echo "#     # #   #  #    # #      #     # #    # # #      #      #    #    "
echo " #####  #    #  ####  #       #####  #    # # ###### ###### #####     "
echo "                                                                      "
echo "      #                               #     #                        "
echo "      #  ####  #####  #####  #   #    #     # ######  ####    ##     "
echo "      # #    # #    # #    #  # #     #     # #      #    #  #  #    "
echo "      # #    # #    # #    #   #      #     # #####  #      #    #   "
echo "#     # #    # #####  #    #   #       #   #  #      #  ### ######   "
echo "#     # #    # #   #  #    #   #        # #   #      #    # #    #   "
echo " #####   ####  #    # #####    #         #    ######  ####  #    #   "

echo "Presione enter para continuar"
read 

# Función para enviar 'yes' seguido de Enter automáticamente
send_yes() {
  echo "yes"
  sleep 1 # Opcional: agregar un breve retardo para asegurar que 'yes' se envíe correctamente
  echo ""
}

# Crear el directorio 'projects' y cambiar al directorio
cd
mkdir projects
cd projects

# Clonar el repositorio de GitHub
git clone https://github.com/JordyV3/cropshield-api-ia.git

# Cambiar al directorio del proyecto clonado
cd 

# Actualizar la lista de paquetes disponibles e instalar dependencias
send_yes | sudo apt update
send_yes | sudo apt install -y python3-pip python3-dev python3-setuptools python3-venv

# Crear y activar el entorno virtual
cd projects/
python3 -m venv env
source env/bin/activate

# Instalar las dependencias del proyecto
cd cropshield-api-ia/
send_yes | pip install --upgrade pip
pip install -r requirements.txt

# Instalar Nginx

send_yes | sudo apt install nginx

clear
# Crear Archivo de configuracion NginX
echo "***********************************************"
echo "Por favor, ingresa la dirección IP del droplet:"
read direccion_ip

# Generar el contenido del bloque de configuración con la dirección IP ingresada
configuracion="
server {
    server_name $direccion_ip;
    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:8000;
    }
}
"

# Crear el archivo en la ruta /etc/nginx/sites-available/cropshield-api con la configuración
echo "$configuracion" | sudo tee /etc/nginx/sites-available/cropshield-api

# Reiniciar Nginx para que los cambios surtan efecto
sudo service nginx restart

echo "La dirección IP del droplet se ha agregado correctamente en /etc/nginx/sites-available/cropshield-api"

sudo ln -s /etc/nginx/sites-available/cropshield-api /etc/nginx/sites-enabled

sudo systemctl restart nginx

# Generar el contenido del archivo cropshield.service
configuracion="
[Unit]
Description=api-cropshield projects

[Service]
WorkingDirectory=/root/projects/cropshield-api-ia
Environment=PATH=/root/projects/env/bin
ExecStart=/root/projects/env/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app

[Install]
WantedBy=multi-user.target
"

# Crear el archivo cropshield.service en la ruta /etc/systemd/system/
echo "$configuracion" | sudo tee /etc/systemd/system/cropshield.service

# Ajustar los permisos del archivo
sudo chmod 644 /etc/systemd/system/cropshield.service

# Recargar los servicios de systemd
sudo systemctl start cropshield

echo "El archivo /etc/systemd/system/cropshield.service se ha creado correctamente."

sudo systemctl start cropshield

cd

clear


# Mostrar un mensaje al finalizar
echo "***********************************************************"
echo "                                                           "
echo "El entorno de desarrollo ha sido configurado correctamente."
echo "                                                           "
echo "***********************************************************"

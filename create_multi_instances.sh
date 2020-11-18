#!/bin/bash

# Description: script criado para configurar várias máquinas semelhantes no compute engine
# Autor: Danilo Bastos
# Versão: Beta 1.0

# Variables
PROJECT=""
NAME_INSTANCE=""
ZONE=""
MACHINE_TYPE=""
SUBNET=""
PRIVATE_NETWORK_IPV4="" # ex.: 192.168.0
INIT_NETWORK= "" # ex.: 1
# choose PREMIUM or STANDARD
NETWORK_TIER="PREMIUM"
SERVICE_ACCOUNT=""
TAGS=""
IMAGE=""
IMAGE_PROJECT=""
SIZE_BOOT_DISK=""
BOOT_DISK_TYPE="" #
BOOT_DISK_NAME=""
NUM_INSTANCES=4
COUNT=0

# Validando instalação do gcloud localmente
GCLOUD_VERSION=$(gcloud --version | grep "Google Cloud SDK")

if [ $? -eq 1 ];
then
	echo "Instalando versão mais recente do SDK (gcloud)"
	
	# Add the Cloud SDK distribution URI as a package source
	echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a \
		/etc/apt/sources.list.d/google-cloud-sdk.list
	
	# Import the Google Cloud public key
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

	# Update the package list and install the Cloud SDK
	sudo apt-get update -y && sudo apt-get install google-cloud-sdk -y

	# Install beta component
	gcloud components install beta
fi

# Config project
while [[ $ACK != "y" || $ACK != "Y" || $ACK != "n" || $ACK != "N" ]]; do
echo "Deseja alterar a configuração do gcloud init?(y/Y for yes - N/n for no)"
read ACK
        if [[ $ACK = "y" || $ACK = "Y" ]];
        then
                gcloud init
                break
        elif [[ $ACK = "n" || $ACK = "N" ]];
        then
                echo "Configuração gcloud não alterada!"
                break
        fi

        echo "Digite uma opção válida!"
done

echo "---------------------------------------------------------------------------"
echo "criando $NUM_INSTANCES instancias no GCP..."
echo "---------------------------------------------------------------------------"

# Execution command for create instances
while [ $COUNT -lt $NUM_INSTANCES ]; do
	gcloud beta compute\
		--project=$PROJECT\
		instances create $NAME_INSTANCE-$COUNT\
		--zone=$ZONE\
		--machine-type=$MACHINE_TYPE\
		--subnet=$SUBNET\
		--private-network-ip=$PRIVATE_NETWORK_IPV4.$INIT_NETWORK\
		--network-tier=$NETWORK_TIER\
		--can-ip-forward\
		--maintenance-policy=MIGRATE\
		--service-account=$SERVICE_ACCOUNT\
		--scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append\
		--tags=$TAGS\
		--image=$IMAGE\
		--image-project=$IMAGE_PROJECT\
		--boot-disk-size=$SIZE_BOOT_DISK\
		--boot-disk-type=$BOOT_DISK_TYPE\
		--boot-disk-device-name=$BOOT_DISK_NAME-$COUNT\
		--no-shielded-secure-boot\
		--shielded-vtpm\
		--shielded-integrity-monitoring\
		--reservation-affinity=any
	
let "COUNT++"
let "INIT_NETWORK++"

done

echo "finalizado!"

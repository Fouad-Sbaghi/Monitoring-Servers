#!/bin/bash

MACHINE_LOCALE="fouad@10.126.7.28"
DOSSIER_LOCAL="/home/fouad/sauvegardes_projet"

scp ${MACHINE_LOCALE}:${DOSSIER_LOCAL}/monitoring.db.bak /home/fouad/projet_ams/monitoring.db

if [ $? -eq 0 ]; then
    echo "Restauration terminée."
else
    echo "Échec de la restauration."
fi

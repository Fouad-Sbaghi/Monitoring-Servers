#!/bin/bash

MACHINE_LOCALE="fouad@10.126.7.28"
DOSSIER_LOCAL="/home/fouad/sauvegardes_projet"

ssh ${MACHINE_LOCALE} "mkdir -p ${DOSSIER_LOCAL}"
scp /home/fouad/projet_ams/monitoring.db ${MACHINE_LOCALE}:${DOSSIER_LOCAL}/monitoring.db.bak

if [ $? -eq 0 ]; then
    echo "Sauvegarde terminée."
else
    echo "Échec de la sauvegarde."
fi
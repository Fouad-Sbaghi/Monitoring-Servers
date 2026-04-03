#!/bin/bash
DB_PATH="/home/fouad/projet_ams/monitoring.db"

if [ "$1" == "" ]; then
    echo "Usage: ./ajout_client.sh [add|del] [IP] [Utilisateur]"
    echo "Exemple: ./ajout_client.sh add 192.168.122.99 fouad"
    exit 1
fi

ACTION=$1
IP=$2
USER=$3

if [ "$ACTION" == "add" ]; then
    if [ "$USER" == "" ]; then
        echo "Erreur: Utilisateur manquant pour l'ajout."
        exit 1
    fi
    sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO hosts (ip, utilisateur) VALUES ('$IP', '$USER');"
    echo "L'hôte $IP ($USER) a été ajouté à la base de données."
elif [ "$ACTION" == "del" ]; then
    sqlite3 "$DB_PATH" "DELETE FROM hosts WHERE ip='$IP';"
    echo "L'hôte $IP a été supprimé de la base de données."
else
    echo "Action inconnue: $ACTION"
fi

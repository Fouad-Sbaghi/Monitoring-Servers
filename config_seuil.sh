#!/bin/bash
DB_PATH="/home/fouad/projet_ams/monitoring.db"

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "Usage: ./config_seuil.sh [Sonde] [Seuil_Max]"
    exit 1
fi

SONDE=$1
SEUIL=$2

if [ "$SONDE" == "list" ]; then
    sqlite3 "$DB_PATH" "SELECT sonde, seuil_max FROM alertes_config;"
    sqlite3 "$DB_PATH" "SELECT valeur FROM config WHERE cle='Historique_max';"
    exit 0
fi

if [ "$SONDE" == "Historique_max" ]; then
    sqlite3 "$DB_PATH" "INSERT INTO config (cle, valeur) VALUES ('Historique_max', '$SEUIL') ON CONFLICT(cle) DO UPDATE SET valeur='$SEUIL';"
else
    sqlite3 "$DB_PATH" "INSERT INTO alertes_config (sonde, seuil_max) VALUES ('$SONDE', $SEUIL) ON CONFLICT(sonde) DO UPDATE SET seuil_max=$SEUIL;"
fi

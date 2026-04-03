#!/bin/bash
DB_PATH="/home/fouad/projet_ams/monitoring.db"
TS_LIMITE=$(($(date +%s) - 300))

ALERTS=$(sqlite3 "$DB_PATH" "
    SELECT m.ip, m.sonde, m.valeur, c.seuil_max 
    FROM mesures m
    JOIN alertes_config c ON m.sonde = c.sonde
    WHERE m.timestamp >= $TS_LIMITE
    AND CAST(m.valeur AS REAL) > CAST(c.seuil_max AS REAL);
")

if [ -n "$ALERTS" ]; then
    echo "$ALERTS" | while IFS='|' read -r ip sonde valeur seuil; do
        python3 /home/fouad/projet_ams/envoi_mail.py "$ip" "$sonde" "$valeur" "$seuil"
    done
fi

INACTIFS=$(sqlite3 "$DB_PATH" "
    SELECT DISTINCT ip FROM mesures 
    WHERE timestamp >= $TS_LIMITE AND sonde = 'ETAT' AND valeur = -1;
")

if [ -n "$INACTIFS" ]; then
    echo "$INACTIFS" | while read -r ip; do
        if [ -n "$ip" ]; then
            python3 /home/fouad/projet_ams/envoi_mail.py "$ip" "ETAT" "Hors-ligne" "Actif"
        fi
    done
fi

#!/bin/bash

DB_PATH="/home/fouad/projet_ams/monitoring.db"
HOSTS=$(sqlite3 "$DB_PATH" "SELECT ip, utilisateur FROM hosts;")

if [ -z "$HOSTS" ]; then
    exit 1
fi

for host in $HOSTS; do
    ip=$(echo "$host" | cut -d'|' -f1)
    user=$(echo "$host" | cut -d'|' -f2)
    
    DATA=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$user@$ip" "python3 ~/projet_ams/sonde_cpu.py && python3 ~/projet_ams/sonde_ram.py && bash ~/projet_ams/sonde_disque.sh" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        TS_SUCCESS=$(date +%s)
        sqlite3 "$DB_PATH" "INSERT INTO mesures (timestamp, ip, sonde, valeur) VALUES ($TS_SUCCESS, '$ip', 'ETAT', 1);"
        
        echo "$DATA" | while IFS='|' read -r ts_part val_part; do
            if [[ "$ts_part" == TIMESTAMP:* ]]; then
                TS=$(echo "$ts_part" | cut -d':' -f2)
                SONDE=$(echo "$val_part" | cut -d':' -f1)
                VALEUR=$(echo "$val_part" | cut -d':' -f2 | tr -d '%')
                
                sqlite3 "$DB_PATH" "INSERT INTO mesures (timestamp, ip, sonde, valeur) VALUES ($TS, '$ip', '$SONDE', $VALEUR);"
            fi
        done
    else
        TS=$(date +%s)
        sqlite3 "$DB_PATH" "INSERT INTO mesures (timestamp, ip, sonde, valeur) VALUES ($TS, '$ip', 'ETAT', -1);"
    fi
done

HISTORIQUE_MAX=$(sqlite3 "$DB_PATH" "SELECT valeur FROM config WHERE cle='Historique_max';")
if [ -z "$HISTORIQUE_MAX" ]; then HISTORIQUE_MAX=86400; fi

sqlite3 "$DB_PATH" "DELETE FROM mesures WHERE timestamp < $(($(date +%s) - $HISTORIQUE_MAX));"
bash /home/fouad/projet_ams/alerte.sh
python3 /home/fouad/projet_ams/generer_graphiques.py
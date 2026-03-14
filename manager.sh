#!/bin/bash

VMS=("192.168.122.99" "192.168.122.237" "192.168.122.56")
USER="fouad"
MDP="azerty"
DB_PATH="/home/fouad/projet_ams/monitoring.db"

for ip in "${VMS[@]}"; do
    echo "Collecte sur $ip..."
    
    DATA=$(sshpass -p "$MDP" ssh -o StrictHostKeyChecking=no $USER@$ip \
    "bash ~/projet_ams/sonde_cpu.sh && bash ~/projet_ams/sonde_ram.sh && bash ~/projet_ams/sonde_disque.sh")
    
    if [ $? -eq 0 ]; then
        # Extraction des valeurs 
        CPU=$(echo "$DATA" | grep "CPU" | cut -d':' -f3 | tr -d '%')
        RAM=$(echo "$DATA" | grep "RAM" | cut -d':' -f3 | tr -d '%')
        DISK=$(echo "$DATA" | grep "DISK" | cut -d':' -f3 | tr -d '%')
        TS=$(date +%s)

        sqlite3 "$DB_PATH" "INSERT INTO mesures (timestamp, ip, cpu, ram, disk) VALUES ($TS, '$ip', $CPU, $RAM, $DISK);"
    else
        # Si vm éteinte
        sqlite3 "$DB_PATH" "INSERT INTO mesures (timestamp, ip, cpu, ram, disk) VALUES ($(date +%s), '$ip', -1, -1, -1);"
    fi
done

# Nettoyage des données de plus de 24h
sqlite3 "$DB_PATH" "DELETE FROM mesures WHERE timestamp < $(($(date +%s) - 86400));"
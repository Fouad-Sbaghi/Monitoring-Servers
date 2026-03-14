#!/bin/bash
DB_PATH="/home/fouad/projet_ams/monitoring.db"

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS mesures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    ip TEXT,
    cpu REAL,
    ram REAL,
    disk REAL
);
CREATE TABLE IF NOT EXISTS alertes_cert (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    titre TEXT
);
EOF
echo "Base de données initialisée via Bash."
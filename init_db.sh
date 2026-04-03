#!/bin/bash
DB_PATH="/home/fouad/projet_ams/monitoring.db"

sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS mesures (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    ip TEXT,
    sonde TEXT,
    valeur REAL
);
CREATE TABLE IF NOT EXISTS alertes_cert (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    titre TEXT
);
CREATE TABLE IF NOT EXISTS hosts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ip TEXT UNIQUE,
    utilisateur TEXT
);
CREATE TABLE IF NOT EXISTS config (
    cle TEXT PRIMARY KEY,
    valeur TEXT
);
CREATE TABLE IF NOT EXISTS alertes_config (
    sonde TEXT PRIMARY KEY,
    seuil_max REAL
);

INSERT OR IGNORE INTO config (cle, valeur) VALUES ('Historique_max', '86400');
INSERT OR IGNORE INTO alertes_config (sonde, seuil_max) VALUES ('CPU', 90);
INSERT OR IGNORE INTO alertes_config (sonde, seuil_max) VALUES ('RAM', 95);
EOF
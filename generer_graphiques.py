#!/usr/bin/env python3
import sqlite3
import pygal
import os

DB_PATH = "/home/fouad/projet_ams/monitoring.db"
OUTPUT_DIR = "/home/fouad/projet_ams/graphiques"

def creer_dossier():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

from datetime import datetime

def generer_graphique_ip(ip):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    line_chart = pygal.DateTimeLine(
        title=f"Evolution des Ressources - {ip}",
        x_label_rotation=35, truncate_label=-1,
        x_value_formatter=lambda dt: dt.strftime('%H:%M:%S')
    )

    sondes = ["CPU", "RAM", "DISK"]
    has_data = False
    
    for sonde in sondes:
        cursor.execute("SELECT timestamp, valeur FROM mesures WHERE ip=? AND sonde=? ORDER BY timestamp ASC", (ip, sonde))
        lignes = cursor.fetchall()
        if lignes:
            has_data = True
            donnees = []
            for (ts, val) in lignes:
                dt = datetime.fromtimestamp(ts)
                donnees.append((dt, float(val)))
            line_chart.add(sonde, donnees)

    conn.close()

    if has_data:
        line_chart.render_to_file(os.path.join(OUTPUT_DIR, f"{ip}_all.svg"))

if __name__ == "__main__":
    creer_dossier()
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT DISTINCT ip FROM hosts")
    ips = [row[0] for row in c.fetchall()]
    conn.close()

    for ip in ips:
        generer_graphique_ip(ip)

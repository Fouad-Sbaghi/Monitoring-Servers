from flask import Flask, render_template, send_from_directory
import sqlite3
import os
import datetime

app = Flask(__name__)
DB_PATH = "/home/fouad/projet_ams/monitoring.db"
GRAPHS_DIR = "/home/fouad/projet_ams/graphiques"

def get_db_info():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    cursor.execute("SELECT ip, utilisateur FROM hosts")
    hosts = cursor.fetchall()
    
    cursor.execute("SELECT timestamp, titre FROM alertes_cert ORDER BY timestamp DESC")
    rows_alertes = cursor.fetchall()
    
    alertes_cert = []
    for row in rows_alertes:
        dt = datetime.datetime.fromtimestamp(row[0]).strftime('%d/%m/%Y %H:%M')
        alertes_cert.append({
            "date": dt,
            "titre": row[1]
        })

    graphiques_par_ip = {}
    dernieres_valeurs = {}
    sondes = ["CPU", "RAM", "DISK", "ETAT"]
    
    for ip, _ in hosts:
        graphiques_par_ip[ip] = False
        if os.path.exists(os.path.join(GRAPHS_DIR, f"{ip}_all.svg")):
            graphiques_par_ip[ip] = True
            
        dernieres_valeurs[ip] = {}
        for s in sondes:
            cursor.execute("SELECT valeur, timestamp FROM mesures WHERE ip=? AND sonde=? ORDER BY timestamp DESC LIMIT 1", (ip, s))
            row_val = cursor.fetchone()
            if row_val:
                dt_val = datetime.datetime.fromtimestamp(row_val[1]).strftime('%H:%M:%S')
                dernieres_valeurs[ip][s] = {"valeur": row_val[0], "heure": dt_val}

    TS_LIMITE = int(datetime.datetime.now().timestamp()) - 3600
    cursor.execute("""
        SELECT m.ip, m.sonde, m.valeur, c.seuil_max, m.timestamp 
        FROM mesures m
        JOIN alertes_config c ON m.sonde = c.sonde
        WHERE m.timestamp >= ?
        AND CAST(m.valeur AS REAL) > CAST(c.seuil_max AS REAL)
        ORDER BY m.timestamp DESC
    """, (TS_LIMITE,))
    
    raw_alertes_sys = cursor.fetchall()
    alertes_systeme = []
    for a in raw_alertes_sys:
        dt_al = datetime.datetime.fromtimestamp(a[4]).strftime('%H:%M:%S')
        alertes_systeme.append({
            "ip": a[0], "sonde": a[1], "valeur": a[2], "seuil": a[3], "heure": dt_al
        })

    conn.close()
    return hosts, alertes_cert, graphiques_par_ip, dernieres_valeurs, alertes_systeme

@app.route('/')
def index():
    hosts, alertes_cert, graphiques, val_actuelles, alertes_sys = get_db_info()
    return render_template('index.html', hosts=hosts, alertes_cert=alertes_cert, graphiques=graphiques, dernieres_valeurs=val_actuelles, alertes_systeme=alertes_sys)

@app.route('/graphiques/<path:filename>')
def serve_graph(filename):
    return send_from_directory(GRAPHS_DIR, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import sqlite3
import time


DB_PATH = "/home/fouad/projet_ams/monitoring.db"

def recuperer_alerte_cert():
    url = "https://www.cert.ssi.gouv.fr/alerte/"
    
    try:
        reponse = requests.get(url, timeout=10)
        soup = BeautifulSoup(reponse.text, 'html.parser')
        article = soup.find('article')
        if article:
            titre = article.find('h3').text.strip()
            conn = sqlite3.connect(DB_PATH)
            cursor = conn.cursor()
            
            # éviter doublons
            cursor.execute("SELECT titre FROM alertes_cert WHERE titre = ?", (titre,))
            if not cursor.fetchone():
                cursor.execute("INSERT INTO alertes_cert (timestamp, titre) VALUES (?, ?)", 
                               (int(time.time()), titre))
                conn.commit()
                print(f"Nouvelle alerte enregistrée : {titre}")
            else:
                print("ℹL'alerte est déjà connue, rien à ajouter.")
                
            conn.close()
            
    except Exception as e:
        print(f"Erreur lors de la récupération : {e}")

if __name__ == "__main__":
    recuperer_cert_parser = recuperer_alerte_cert()
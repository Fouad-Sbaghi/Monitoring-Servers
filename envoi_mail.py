#!/usr/bin/env python3
import sys
import smtplib
from email.message import EmailMessage
import datetime

SMTP_SERVER = "localhost"
SMTP_PORT = 25
SMTP_USER = ""
SMTP_PASS = ""
DESTINATAIRE = "fouad.sbaghi7@gmail.com"
EXPEDITEUR = "monitoring@projet-ams.local"

if len(sys.argv) < 5:
    sys.exit(1)

host = sys.argv[1]
sonde = sys.argv[2]
valeur = sys.argv[3]
seuil = sys.argv[4]
date_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

sujet = f"Alerte de monitoring : {host}"
corps = f"""
Une alerte a ete declenchee sur la machine {host} ({date_str}).
Sonde : {sonde}
Valeur : {valeur} (Seuil : {seuil})
"""

msg = EmailMessage()
msg.set_content(corps)
msg['Subject'] = sujet
msg['From'] = EXPEDITEUR
msg['To'] = DESTINATAIRE

print("\n[+] DÉCLENCHEMENT DE L'ALERTE MAIL [+]")
print(f"➜ Destinataire : {DESTINATAIRE}")
print(f"➜ Sujet        : {sujet}")
print(f"➜ Contenu      : {corps.strip()}")
print("[+] ENVOI AU SERVEUR SMTP (localhost:25) [+]\n")

try:
    server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    server.send_message(msg)
    server.quit()
except Exception as e:
    pass

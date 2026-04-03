# Système de Monitoring de Parc Informatique (Projet L2S4 AMS)

Ce projet est une plateforme complète et automatisée de supervision système. Il permet de collecter, stocker, analyser et visualiser les données matérielles (CPU, RAM, Disque, État) d'un parc composé de plusieurs machines Linux distantes.

## Architecture du Projet

Le système est découpé en 5 modules répondant intégralement aux exigences du cahier des charges :
1. **La Collecte** : Sondes Python (`sonde_cpu.py`, `sonde_ram.py`) et Bash (`sonde_disque.sh`) s'exécutant sur les machines cibles.
2. **Le Stockage** : Base de données légère SQLite décentralisée, avec nettoyage intelligent de l'historique obsolète et parseur d'alertes mondiales de cybersécurité du CERT-FR (`cert_parser.py`).
3. **Le Détecteur de Crise** : Script de vigilance paramétrable (`alerte.sh`) déclenchant des notifications courriel SMTP automatisées (`envoi_mail.py`). Un module de graphisme Python `pygal` génère l'historique visuel (`generer_graphiques.py`).
4. **La Gestion de Parc** : Pilote central (`manager.sh`) gérant dynamiquement de nouveaux serveurs ajoutés en direct dans la base de données.
5. **Le Tableau de Bord Web** : Application Flask (`app.py`) affichant une interface de contrôle synthétique avec les alertes, statistiques temps-réel, et les courbes vectorielles (SVG).

## Prérequis

- **Python 3** (librairies: `flask`, `pygal`, `beautifulsoup4`, `psutil`, `requests`)
- **SQLite 3**
- Un accès **SSH par clé publique** correctement configuré pour éviter les mots de passe interactifs.

## Installation & Lancement

**1. Initialiser le projet et la base de données :**
```bash
bash init_db.sh
```

**2. Inscrire des serveurs dans la boucle de surveillance :**
```bash
./ajout_client.sh add 192.168.122.99 fouad
```

**3. Activer l'automatisation (via Crontab) :**
Ajouter ces lignes via `crontab -e` pour automatiser la collecte et l'actualisation des failles de sécurité :
```text
* * * * * bash /home/fouad/projet_ams/manager.sh
0 * * * * python3 /home/fouad/projet_ams/cert_parser.py
0 23 * * * bash /home/fouad/projet_ams/save.sh
```

**4. Démarrer le Serveur Web :**
```bash
python3 app.py
```
*Le tableau de bord interactif sera accessible via un navigateur sur `http://127.0.0.1:5000`.*

## Centre d'Administration

Le projet permet une gestion à chaud sans jamais modifier le code source. 

**Modifier la durée de rétention avant suppression des données (ex: 2 heures = 7200s) :**
```bash
./config_seuil.sh Historique_max 7200
```

**Définir l'urgence de seuil de déclenchement des mails de Crise :**
```bash
./config_seuil.sh CPU 85
```

**Lister les règles actives du parc :**
```bash
./config_seuil.sh list all
```
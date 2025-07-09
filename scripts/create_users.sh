#!/bin/bash

# Vérification si l'utilisateur est root
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root"
  exit 1
fi

echo "Entrez le nom d'utilisateur VPN :"
read USERNAME

# Création de l'utilisateur sans shell ni dossier personnel
useradd -M -s /usr/sbin/nologin $USERNAME

# Affecter un mot de passe (le mot de passe servira pour la connexion VPN)
echo "Définir le mot de passe pour $USERNAME :"
passwd $USERNAME

# (Optionnel) Google Authenticator
echo "Voulez-vous activer l'authentification à deux facteurs (2FA) avec Google Authenticator pour cet utilisateur ? [o/n]"
read USE_2FA

if [[ "$USE_2FA" == "o" || "$USE_2FA" == "O" ]]; then
	echo "Configuration de Google Authenticator pour $USERNAME"
	su - $USERNAME -s /bin/bash -c "google-authenticator -t -d -f -r 3 -R 30 -W"
	echo "Ne pas oublier d'installer Google Authenticator sur votre téléphone"
	echo "Le code QR ou la clé a été affiché pour l'utilisateur $USERNAME"
fi

echo "Utilisateur $USERNAME créé avec succès."

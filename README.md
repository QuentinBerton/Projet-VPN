# Projet VPN – Installation et Sécurisation d’un Serveur OpenVPN sous Debian

## Objectif

Ce projet consiste à installer, configurer et sécuriser un serveur **OpenVPN** sur une machine virtuelle Debian. Il permet la connexion de deux utilisateurs via un tunnel VPN sécurisé et comprend :
- La génération de certificats avec Easy-RSA
- La configuration du serveur et des clients
- La mise en place d’un pare-feu (UFW)
- Le démarrage automatique avec systemd
- L'ajout de l'authentification à deux facteurs (2FA)

---

## Technologies utilisées

- **Debian 11**
- **OpenVPN**
- **Easy-RSA**
- **UFW**
- **Google Authenticator**
- **Systemd**

---

## Étapes principales de l’installation

### 1. Installation des paquets
bash
apt update && apt upgrade -y
apt install -y openvpn easy-rsa curl ufw libpam-google-authenticator


### 2. Génération des clés et certificats (PKI)
bash
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
nano vars    # Configuration des infos de certificat
./easyrsa init-pki
./easyrsa build-ca
./easyrsa build-server-full server nopass
./easyrsa build-client-full client1 nopass
./easyrsa build-client-full client2 nopass
./easyrsa gen-dh
openvpn --genkey --secret ta.key


### 3. Copie des fichiers de sécurité vers OpenVPN
bash
cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key /etc/openvpn/


### 4. Configuration du serveur OpenVPN
Fichier : /etc/openvpn/server.conf

Paramètres clés :
Port : 1194 UDP
Protocole : UDP
Réseau VPN : 10.8.0.0/24
Chiffrement : AES-256-CBC + SHA256
Clé TLS : activée
DNS poussés : 1.1.1.1, 8.8.8.8
Utilisateur : nobody


### 5. Activation du routage IP
bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p


### 6. Configuration du pare-feu (UFW)
bash
ufw allow ssh
ufw allow 1194/udp
ufw enable
ufw route allow in on tun0 out on eth0 to any port 80 proto tcp
ufw route deny in on tun0 out on eth0


### 7. Démarrage automatique avec systemd
bash
systemctl start openvpn@server
systemctl enable openvpn@server


### 8. Création de profils clients

Chaque utilisateur a un fichier .ovpn avec les éléments suivants :

Certificat utilisateur (client1.crt)
Clé privée (client1.key)
Clé TLS
Certificat CA (ca.crt)
Adresse IP publique du serveur


### 9. Authentification à deux facteurs (2FA)

Installation de libpam-google-authenticator
Activation PAM dans /etc/pam.d/openvpn

bash
auth required pam_google_authenticator.so

Activation dans server.conf :

plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so openvpn
client-cert-not-required
username-as-common-name

Configuration des OTP pour chaque utilisateur :

su - vpnuser
google-authenticator

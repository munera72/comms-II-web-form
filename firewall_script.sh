#!/bin/bash

# Limpiar reglas existentes
iptables -F
iptables -X

# Política por defecto: denegar todo
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones ya establecidas o relacionadas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Rechazar paquetes inválidos
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Limitar nuevas conexiones por IP (máx 20 por minuto con ráfaga de 10)
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW \
    -m recent --name ddos --set
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW \
    -m recent --name ddos --update --seconds 60 --hitcount 20 -j DROP

# Limitar número de conexiones simultáneas por IP (máx 10)
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

# Aceptar conexiones web si no superan los límites anteriores
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Log de paquetes descartados (opcional)
iptables -A INPUT -j LOG --log-prefix "FIREWALL DROP: "

echo "Reglas de firewall aplicadas."

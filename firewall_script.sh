#!/bin/bash

# Borrar reglas existentes
iptables -F
iptables -X

# Política por defecto: aceptar todo inicialmente
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Permitir tráfico local (loopback)
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones ya establecidas y relacionadas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir conexiones SSH (opcional)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir HTTP y HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Mitigar ataques DoS: limitar conexiones por IP
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 20 -j DROP

# Limitar solicitudes por segundo (burst control)
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# Bloquear todo lo demás
iptables -A INPUT -j DROP

echo "Firewall activado para mitigar ataques DoS"

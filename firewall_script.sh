#!/bin/bash

echo "Configurando reglas fuertes contra DDoS con iptables..."

# Limpieza
iptables -F
iptables -X

# Políticas por defecto
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir localhost y conexiones establecidas
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Permitir HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# -------------------------
# Protección contra DDoS
# -------------------------

# Limitar nuevas conexiones HTTP por IP (20 por segundo, con burst de 40)
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -m hashlimit \
  --hashlimit 20/sec --hashlimit-burst 40 --hashlimit-mode srcip \
  --hashlimit-name http_limit -j ACCEPT

# Bloquear IP que exceda ese límite
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -j DROP

# Limitar conexiones simultáneas por IP
iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset

# Bloquear paquetes inválidos
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Protección básica contra spoofing
iptables -A INPUT -s 224.0.0.0/4 -j DROP
iptables -A INPUT -s 240.0.0.0/5 -j DROP
iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP
iptables -A INPUT -s 0.0.0.0/8 -j DROP

# Guardar reglas
iptables-save > /etc/sysconfig/iptables

echo "Reglas fuertes activadas."

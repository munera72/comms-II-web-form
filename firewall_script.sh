#!/bin/bash

# Script de iptables para proteger servidor web de ataques DoS y DDoS

echo "Aplicando reglas de protección web con iptables..."

# Limpia reglas actuales
iptables -F
iptables -X

# Política por defecto: todo denegado
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir tráfico local
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones ya establecidas y relacionadas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir tráfico SSH (puerto 22) si estás usando
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Permitir HTTP y HTTPS
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# Protección: Limitar conexiones simultáneas por IP
iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 20 -j REJECT --reject-with tcp-reset

# Protección: Limitar nuevos intentos de conexión por minuto (rate limit)
iptables -A INPUT -p tcp --dport 80 -m recent --name http-flood --set
iptables -A INPUT -p tcp --dport 80 -m recent --name http-flood --update --seconds 60 --hitcount 40 -j DROP

# Protección contra escaneos y paquetes inválidos
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Registro (opcional)
# iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTABLES DROPPED: " --log-level 7

# Guardar configuración
echo "Guardando reglas..."
iptables-save > /etc/sysconfig/iptables

echo "Reglas aplicadas y guardadas."

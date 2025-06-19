#!/bin/bash

# Flush existing rules
iptables -F
iptables -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established/related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Limit new HTTP connections (DDoS mitigation)
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -m limit --limit 10/minute --limit-burst 5 -j ACCEPT

iptables -A INPUT -p tcp --dport 80 -m connlimi-above 10 -j DROP
iptables -A INPUT -p tcp --dport 80 -m limit --limit 1/sec --limit-burst 5 -j ACCEPT

# Drop everything else
iptables -A INPUT -j DROP

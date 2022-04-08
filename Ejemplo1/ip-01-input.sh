#!/bin/bash
# ASIX M11-Seguretat i alta disponibilitat
# @edt 2022
# ========================================
# Activar si el host ha de fer de router
echo 1 > /proc/sys/net/ipv4/ip_forward

# Regles Flush: buidar les regles actuals
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Establir la política per defecte (ACCEPT o DROP)
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# Filtrar ports (personalitzar)  - - - - - - - - - - - - - - - - - - - - - - -
# ----------------------------------------------------------------------------
# Permetre totes les pròpies connexions via localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la pròpia ip(192.168.1.34))
iptables -A INPUT  -s 10.200.243.210 -j ACCEPT
iptables -A OUTPUT -d 10.200.243.210 -j ACCEPT

# Regles de Input
# Obrir port 80 a tothom
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Tancar el port 2080 a tothom
iptables -A INPUT -p tcp --dport 80 -j DROP

# Tancar el port 3080 a tothom excepte el i11 (del vei)
iptables -A INPUT -p tcp --dport 3080 -s 10.200.243.211 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j DROP # o REJECT

# Obert per tothom 4080, tancat par xarxa 2hisix, obert per el i25
iptables -A INPUT -p tcp --dport 4080 -s 10.200.243.225 -j ACCEPT
iptables -A INPUT -p tcp --dport 4080 -s 10.200.243.0/24 -j DROP
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT


#! /bin/bash

# ==============================================
# Activar si el host ha de fer de router
#echo 1 > /proc/sys/net/ipv4/ip_forward

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

# Filtrar ports (personalitzar) - - - - - - - - - - - - - - - - - - - - - - -
# ----------------------------------------------------------------------------
# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permetre tot el trafic de la pròpia ip(192.168.1.34))
iptables -A INPUT -s 10.200.243.224 -j ACCEPT
iptables -A OUTPUT -d 10.200.243.224 -j ACCEPT

# Output rules:
# Permetre accedir al prot 13 de qualsevol destí:
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT

# Poder accedir a qualsevol 2013 menys el del i25:
iptables -A OUTPUT -p tcp --dport 2013 -d 10.200.243.225 -j REJECT
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT

# Obert el 3013 a tothom, tancat a la xarxa 2HISX (10.200.243.0/24) i obert a i23:
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.223 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.0/24 -j REJECT
iptables -A OUTPUT -p tcp --dport 3013 -j ACCEPT

# Siguis d'on siguis, no pots accedir al port 80, 13 i 7:
iptables -A OUTPUT -p tcp --dport 80 -j REJECT
iptables -A OUTPUT -p tcp --dport 13 -j REJECT
iptables -A OUTPUT -p tcp --dport 7 -j REJECT

# No és pot accedir al i02 ni al i06:
iptables -A OUTPUT -d 10.200.243.202 -j REJECT
iptables -A OUTPUT -d 10.200.243.206 -j REJECT

# A la xarxa 2HISX (10.200.243.0/24) només és pot accedir per SSH:
iptables -A OUTPUT -p tcp --dport 22 -d 10.200.243.0/24 -j ACCEPT
iptables -A OUTPUT -p tcp -d 10.200.243.0/24 -j REJECT

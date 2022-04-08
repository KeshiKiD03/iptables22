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
# Aplicar altres regles per obrir i tancar ports
# ....
# Aplicar altres regles per permetre o no tipus de trafic
# ....
# ----------------------------------------------------------------------------
# Mostrar les regles generades
#iptables -L -t nat

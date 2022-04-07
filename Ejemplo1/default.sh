#!/bin/bash
# ==============================================
# Activar si el host ha de fer de router
#echo 1 > /proc/sys/net/ipv4/ip_forward
# Regles Flush: buidar les regles actuals
iptables -F # Flush
iptables -X # Delete chain
iptables -Z # 
iptables -t nat -F
# Establir la política per defecte (ACCEPT o DROP)
iptables -P INPUT ACCEPT # Per defecte
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
# Filtrar ports (personalitzar) - - - - - - - - - - - - - - - - - - - - - - -
# ----------------------------------------------------------------------------
# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT # TODO LO QUE ENTRE POR LOOPBACK ACEPTAS
iptables -A OUTPUT -o lo -j ACCEPT # TODO LO QUE SALGA DE LOOPBACK ACEPTAS
# Permetre tot el trafic de la pròpia ip(10.200.243.211))
iptables -A INPUT -s 10.200.243.211 -j ACCEPT # Todo el trafico de entrada que el SOURCE ES YO -s (source) - input - destinado a a mi - Source (YO)
iptables -A OUTPUT -d 10.200.243.211 -j ACCEPT # Todo el trafico de entrada que va destinado a mi mismo hace un ACCEPT
# Aplicar altres regles per obrir i tancar ports
# ....
# Aplicar altres regles per permetre o no tipus de trafic
# ....
# ----------------------------------------------------------------------------
# Mostrar les regles generades
iptables -L -t nat

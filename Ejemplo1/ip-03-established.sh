# ip-02-input.sh

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

# Exemples OUTPUT
# Permetre accedir al port 13 de qualsevol destí
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 13 -d 0.0.0.0 -j ACCEPT

# Accedir a qualsevol 2013 excepte el del i25
iptables -A OUTPUT -p tcp --dport 2013 -d 10.200.243.225 -j DROP
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT

# Obert el 3013 a tothom, tancat a 2hisix i obert a i25
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.225 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.0/24 -j DROP
iptables -A OUTPUT -p tcp --dport 3013 -j ACCEPT

# No es pot permés l'acces extern als ports 80,13,7
iptables -A OUTPUT -p tcp --dport 7 -j REJECT
iptables -A OUTPUT -p tcp --dport 13 -j REJECT
iptables -A OUTPUT -p tcp --dport 80 -j REJECT

# No es pot accedir cap mena d'acces als hosts i02 i i04
iptables -A OUTPUT -p tcp -d 10.200.243.202 -j DROP
iptables -A OUTPUT -p tcp -d 10.200.243.204 -j DROP

# A la xarxa 2hisix només s'hi pot accedir per ssh
iptables -A OUTPUT -p tcp --dport 22 -d 10.200.243.0/24 -j ACCEPT
iptables -A OUTPUT -p tcp -d 10.200.243.0/24 -j DROP

# Exemples de trafic related, established


# 3) - SOMOS UN SERVER WEB - permitir acceso a los clientes 
iptables -A INPUT -p tcp --sport 80 -m state --state RELATED, ESTABLISHED -j ACCEPT


# 2) Exemple ben fet
# permetem el retorn de les respostes
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m state \
          --state RELATED, ESTABLISHED -j ACCEPT
# Soc un firefox que em conecto a un servidor web, les respoestes son RELATED y ESTABLISHED. Dice que el trafico entrante de un servidor WEB siemrpe que sea respuesta a una petición nuestra la PERMITES. RELATED I ESTABLISHED.



# 1) Exemples accés a webs externes (mal fet)
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -j ACCEPT

## Ejemplo de matar moscas

# PARANOIC:
iptables -A INPUT -p tcp --sport 80 -j DROP

# Cualquiera que venga de fuera que yo no he iniciado la conexión - Haces un DROP.

#!/bin/bash
# ==============================================
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
# REGLES DE INPUT
# OBRIR PORT 80 A TOTHOM
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# REJECT - TANCA EL PORT 2080 A TOTHOM
#iptables -A INPUT -p tcp --dport 2080 -j REJECT

# DROP - SENSE RESPOSTA DEL PORT 2080 A TOTHOM
iptables -A INPUT -p tcp --dport 2080 -j DROP

# Tancat 3080 a tothom excepte el i10 (delVEI)
iptables -A INPUT -p tcp --dport 3080 -s 10.200.243.210 -j ACCEPT
iptables -A INPUT -p tcp --dport 3080 -j REJECT
#iptables -A INPUT -p tcp --dport 3080 -j DROP

# Mostrar reglas generadas
iptables -L -t nat

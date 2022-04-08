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

# Exemples de tràfic related, established:
# 4) El mateix que "3" però "i25" no podrà accedir:
iptables -A INPUT -p tcp --dpot 80 -s 10.200.223.225 -j REJECT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sprot 80 -m tcp -m state \
        --state RELATED,ESTABLISHED -j ACCEPT

# 3) Som un servidor web, permetem accés als clients i només permetem respostes relacionades amb les preguntes que ens han fet:
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sprot 80 -m tcp -m state \
	--state RELATED,ESTABLISHED -j ACCEPT

# 2) Exemple "1" ben fet, accedim a webs externes i permetem el retorn de les respostes (podem navegar):
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m tcp -m state \
	--state RELATED,ESTABLISHED -j ACCEPT		# Sempre que sigui resposta a una petició nostra, ho permetem (RELATED,ESTABLISHED)
iptables -A INPUT -p tcp --sport 80 -j DROP 	# paranòic

# Som un client amb un 'Firefox' i ens connectem a un servidor web, podem connectarnos a tots els servidors webs perquè tenim 'via libre' de sortida, de cara al nostre PC només permetem l'entrada que provingui del port 80 si el seu estat eś 'RELTAED,ESTABLISHED'

# 1) Permetre accés a web externes (mal fet) (--sport = source port | --dport = destination port):
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT	# El meu PC pot anar a qualsevol port 80 de sortida
iptables -A INPUT -p tcp --sport 80 -j ACCEPT   # To tràfic que vingui d'un servidor web, deixes que torni --> Està malament perquè no ens garanteix que la resposta sigui la que nosaltres volem

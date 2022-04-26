#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-2019
# iptables

# Importante

echo 1 > /proc/sys/net/ipv4/ip_forward

# Regles flush
iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# Polítiques per defecte: 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# obrir el localhost
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# obrir la nostra ip
iptables -A INPUT -s 10.200.243.211 -j ACCEPT
iptables -A OUTPUT -d 10.200.243.211 -j ACCEPT

# Fer NAT per les xarxes internes:
# - 172.21.0.0/16
# - 172.22.0.0/16

# Todo lo que venga por la interficie / Enmascara

iptables -t nat -A POSTROUTING -s 172.21.0.0/16 -o eno1 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 172.22.0.0/16 -o eno1 -j MASQUERADE


# Exemples forward
# A1 no pot accedir a red de B1

#iptables -A FORWARD -s 172.21.0.3 -d 172.22.0.2 -j DROP

# Prohibeixi navegar a internet

#iptables -A FORWARD -s 172.21.0.3 -p tcp -o eno1 --dport 80 -j DROP
#iptables -A FORWARD -i eno1 -p tcp --sport 80 -d 172.21.0.3 -j DROP


# Xarxa A només pot navegar per Internet, cap altre accés a Internet.

# Habilitar DNS
# IDA
#iptables -A FORWARD -s 172.21.0.0/16 -p udp -o eno1 --dport 53 -j ACCEPT
# Vuelta
#iptables -A FORWARD -i enoi -p udp -d 172.21.0.0/16 --sport 53 -j ACCEPT

# IDA
#iptables -A FORWARD -s 172.21.0.0/16 -p tcp -o eno1 --dport 80 -j ACCEPT
# Vuelta
#iptables -A  FORWARD -i eno1 -p tcp --sport 80 -d 172.21.0.0/16 \
#	-m state --state ESTABLISHED,RELATED -j ACCEPT

#iptables -A FORWARD -s 172.21.0.0/16 -o eno1 -j DROP
#iptables -A FORWARD -d 172.21.0.0/16 -i eno1 -j DROP


# Obrir el port 5001 --> A1:13
iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 5001 -j DNAT --to 172.21.0.3:13

# APACHE2 port 80
#iptables -t nat -A PREROUTING -i eno1 -p tcp --dport 5001 -j DNAT --to 172.21.0.3:80


# DROP trafic forward que vaya al puerto 13
iptables -A FORWARD -d 172.21.0.3 -p tcp --dport 13 -j DROP

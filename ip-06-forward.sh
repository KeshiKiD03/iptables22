#! /bin/bash
# @edt ASIX M11-SAD Curs 2018-2019
# iptables

#echo 1 > /proc/sys/ipv4/ip_forward

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
iptables -A INPUT -s 10.200.243.207 -j ACCEPT
iptables -A OUTPUT -d 10.200.243.207 -j ACCEPT

# Fer NAT per les xarxes internes:
# - 192.168.12.0/24
# - 192.168.13.0/24
iptables -t nat -A POSTROUTING -s 192.168.12.0/24 -o eno1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 192.168.13.0/24 -o eno1 -j MASQUERADE

# FORWARD
# Habilitar DNS
# IDA
#iptables -A FORWARD -s 192.168.12.0/24 -p udp -o eno1 --dport 53 -j ACCEPT
# Vuelta
#iptables -A FORWARD -i eno1 -p udp -d 192.168.12.0/24 --sport 53 -j ACCEPT

# Denegar navegar a Internet

#iptables -A FORWARD -s 192.168.12.0/24 -p tcp -o eno1 --dport 80 -j ACCEPT
#iptables -A FORWARD -i eno1 -p tcp --sport 80 -d 192.168.12.0/24 -j ACCEPT

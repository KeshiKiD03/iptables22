# IPTABLES 2021-2022
## Aaron Andal ASIX M11 2021-2022

# Exercici(s) fet(s) a classe:

## Exercici 1 (Política per defecte):
* $ vim ip-defaults.sh --> Fabriquem fitxer per posar regles d'IP tables.

```
#! /bin/bash
# ==============================================
# Activar si el host ha de fer de router
#echo 1 > /proc/sys/net/ipv4/ip_forward

# Regles Flush: buidar les regles actuals
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
# Establir la política per defecte (ACCEPT o DROP).
# Si la política per defecte és 'ACCEPT', haurem d'escriure les regles que tanquen (DROP).
# Tot el que se'ns ovlidi de tancar, estarà obert per defecte.
# Si la polítia per defecte és 'DROP', haurem d'escriure les regles que obren (ACCEPT).
# Tot el que se'ns ovlidi d'obir, estarà tancat per defecte, encara això, és mes segur aquesta política per defecte, però sń MOLT MÉS EXIGENTS A L'HORA D'ADMINISTRAR.
iptables -P INPUT ACCEPT		# REGLES PER DEFECTE, SI NO S'APLICA CAP, PER DEFECTE, ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT

# Filtrar ports (personalitzar) - - - - - - - - - - - - - - - - - - - - - - -
# ----------------------------------------------------------------------------
# Permetre totes les pròpies connexions via localhost
iptables -A INPUT -i lo -j ACCEPT		# Tot el tràfic que entri pel 'loopback', l'acceptes
iptables -A OUTPUT -o lo -j ACCEPT		# Tot el tràfic que surti pel 'loopback', l'acceptes

# Permetre tot el trafic de la pròpia ip(192.168.1.34))
iptables -A INPUT -s 10.200.243.224 -j ACCEPT	

# Tot el tràfic d'entrada dirigit al meu PC, l'acceptes, '-s' source --> jo mateix

iptables -A OUTPUT -d 10.200.243.224 -j ACCEPT

# Tot el tràfic de sortida dirigit al meu PC, l'acceptes, '-d' destination --> jo mateix

# RESUM: TOT EL TRÀFIC D'ENTRADA I SORTIDA QUE FACI JO PER LA MEVA INTERFÍCIE, L'ACCEPTES!
```

**Provem les regles a mà (qualsevol dubte 'man iptables':**

* $ sudo iptables -F --> Eliminem totes les regles.
* $ sudo iptables -L --> Llistem regles actuals.
* $ sudo iptables -L -t nat --> Llistem regles per veure si estàn fent 'NAT'.
* $ sudo bash ip-default.sh --> Executem el fitxer amb les regles.
* $ sudo iptables -L --> Llistem les regles que tenim ara després d'executar el fitxer.

```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  i24.informatica.escoladeltreball.org  anywhere            

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             i24.informatica.escoladeltreball.org 
```

* $ cd /tmp
* $ git clone https://github.com/edtasixm11/iptables18.git
* $ sudo apt update
* $ sudo apt install xinetd
* $ sudo cp /tmp/iptables18/xinetd/\* /etc/xinetd.d/
* $ ls /etc/xinetd.d/

```
chargen         daytime-3  daytime-dgram   discard-udp  httpd-3  servers        time-udp
chargen-dgram   daytime-4  daytime-stream  echo         httpd-4  services
chargen-stream  daytime-5  daytime-udp     echo-dgram   httpd-5  tcpmux-server
chargen-udp     daytime-6  discard         echo-stream  httpd-6  time
daytime         daytime-7  discard-dgram   echo-udp     httpd-7  time-dgram
daytime-2       daytime-8  discard-stream  httpd-2      httpd-8  time-stream
```

* $ cat /etc/xinetd.d/httpd-2

**Contingut d'un fitxer que hem construit per fer proves:**

```
service http-2
{
  disable = no
  type = UNLISTED
  socket_type = stream
  protocol = tcp
  wait = no
  redirect = localhost 80	# TOT EL QUE ENVIEM AL PORT 80, HO REDIGIRÀ AL PORT 2080
  bind = 0.0.0.0		# ESCOLTA PER TOTES LES INTERFÍCIES D'AQUESTA XARXA
  port = 2080			# ESCOLATE PER EL PORT 2080
  user = nobody
}
```

* $ sudo systemctl stop xinetd
* $ sudo systemctl start xinetd
* $ vim /var/www/html/index.html --> Posem qualsevol cosa
* $ nmap localhost --> Comprovem que tenim + ports oberts

```
Starting Nmap 7.80 ( https://nmap.org ) at 2022-04-07 13:33 CEST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00012s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 987 closed ports
PORT     STATE SERVICE
7/tcp    open  echo
13/tcp   open  daytime
19/tcp   open  chargen
37/tcp   open  time
80/tcp   open  http
111/tcp  open  rpcbind
631/tcp  open  ipp
2013/tcp open  raid-am
3013/tcp open  gilatskysurfer
3306/tcp open  mysql
5080/tcp open  onscreen
5432/tcp open  postgresql
8080/tcp open  http-proxy

Nmap done: 1 IP address (1 host up) scanned in 0.03 seconds
```

* $ sudo wget i24:2080 --> Comprovem que el port funciona correctament. (Genera fitxers si anem descarregant, no els sobreescribeix)

```
--2022-04-07 13:33:57--  http://i24:2080/
Resolving i24 (i24)... 127.0.1.1
Connecting to i24 (i24)|127.0.1.1|:2080... connected.
HTTP request sent, awaiting response... 200 OK
Length: 146 [text/html]
Saving to: ‘index.html’

index.html                100%[=====================================>]     146  --.-KB/s    in 0s      

2022-04-07 13:33:57 (63.2 MB/s) - ‘index.html’ saved [146/146]
```

* $ cp ip-default.sh ip-01-input.sh
* $ vim ip-01-input.sh --> AFEGIM EL SEGÜENT:

```
# REGLES D'INPUT:
## Obrir el port 80 a tothom: (-p: protocol, --dport (destination port): 80, -j (acció a fer):
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Tancar el port 2080 a tothom (Si no posem el protocol (-p), no ens deixarà posar '--dport'):
iptables -A INPUT -p tcp --dport 2080 -j REJECT
```

* $ sudo wget i24:[80/2080] --> Comprovem que funciona abans d'executar l'script
* $ sudo bash ip-01-input.sh
* $ sudo iptables -L

```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  i24.informatica.escoladeltreball.org  anywhere            
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
REJECT     tcp  --  anywhere             anywhere             tcp dpt:2080 reject-with icmp-port-unreachable

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             i24.informatica.escoladeltreball.org 
```

* $ sudo wget i24:[80/2080] --> Encara ens deixa perquè abans tenim posat 'ACCEPT' tant a INPUT com a OUTPUT cap a 'localhost'

* $ sudo wget 10.200.243.225:80

```
--2022-04-07 13:44:06--  http://10.200.243.225/
Connecting to 10.200.243.225:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 50 [text/html]
Saving to: ‘index.html.5’

index.html.5              100%[=====================================>]      50  --.-KB/s    in 0s      

2022-04-07 13:44:06 (22.1 MB/s) - ‘index.html.5’ saved [50/50]
```

* $ sudo wget 10.200.243.225:2080

```
--2022-04-07 13:44:09--  http://10.200.243.225:2080/
Connecting to 10.200.243.225:2080... failed: Connection refused.
```

* $ vim ip-01-input.sh --> Canviem 'REJECT' per 'DROP'

```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  i24.informatica.escoladeltreball.org  anywhere            
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
DROP       tcp  --  anywhere             anywhere             tcp dpt:2080

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             i24.informatica.escoladeltreball.org 
```

* $ sudo bash ip-01-input.sh
* $ sudo iptables -L

```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  i24.informatica.escoladeltreball.org  anywhere            
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:http
DROP       tcp  --  anywhere             anywhere             tcp dpt:2080

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  anywhere             anywhere            
ACCEPT     all  --  anywhere             i24.informatica.escoladeltreball.org 
```

**Ara no ens surtirà l'error com amb el 'REJECT', és quedarà penjat**

**Pràctica: tancar el port 3080 a tothom excepte al veí (i23):**

* $ vim ip-01-input.sh --> Configurem de la següent manera:

```
## Obrir el port 3080 a i23: (-p: protocol, --dport (destination port): 80, -j (acció a fer):
iptables -A INPUT -p tcp --dport 3080 -s 10.200.243.223 -j ACCEPT

# Tancar el port 3080 a tothom (Si no posem el protocol (-p), no ens deixarà posar '--dport'):
iptables -A INPUT -p tcp --dport 3080 -j REJECT
```

**Des d'altra ordinador diferent al i23...**

* $ wget 10.200.243.224:3080 --> Amb aquest no ens deixa

**Des de l'ordinador i23...**

* $ wget 10.200.243.224:3080 --> Amb aquest sí que ens deixa

* $ vim ip-01-input.sh

```
## Obrir el port 4080 a i25:
iptables -A INPUT -p tcp --dport 4080 -s 10.200.243.225 -j ACCEPT

# Tancar el port 4080 a tothom de la xarxa 10.200.243.0:
iptables -A INPUT -p tcp --dport 4080 -s 10.200.243.0/24 -j REJECT

# Obrir el port 4080 per tots els demés
iptables -A INPUT -p tcp --dport 4080 -j ACCEPT
```

**Per comprobar que tenim obert un port:**

* $ wget localhost:4080

* $ sudo bash ip-01-input.sh

* $ wget 10.200.243.225:4080 --> NO ENS DEIXA, ÉS QUEDA PENJAT

## Exercici 2 (Exercicis OUTPUT):
* $ cp ip-default.sh ip-02-output.sh
* $ vim ip-02-output.sh

```
# Output rules:
# Permetre accedir al prot 13 de qualsevol destí:
iptables -A OUTPUT -p tcp --dport 13 -j ACCEPT
# iptables -A OUTPUT -p tcp --dport 13 -d 0.0.0.0 -j ACCEPT --> ÉS EL MATEIX QUE LA D'ADALT
```

* $ bash ip-02-output.sh
* $ wget 10.200.243.223:13 --> Ens deixa
* $ vim ip-02-output.sh

```
# Poder accedir a qualsevol 2013 menys el del i25:
iptables -A OUTPUT -p tcp --dport 2013 -d 10.200.243.225 -j REJECT
iptables -A OUTPUT -p tcp --dport 2013 -j ACCEPT
```

* $ wget 10.200.243.223:2013 / telnet 10.200.243.223 2013 --> Ens deixa
* $ wget 10.200.243.225:2013 / telnet 10.200.243.225 2013 --> NO ens deixa
* $ vim ip-02-output.sh

```
# Obert el 3013 a tothom, tancat a la xarxa 2HISX (10.200.243.0/24) i obert a i23:
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.223 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3013 -d 10.200.243.0/24 -j REJECT
iptables -A OUTPUT -p tcp --dport 3013 -j ACCEPT
```

* $ sudo bash ip-default.sh --> Netejem regles
* $ sudo bash ip-02-output.sh
* $ wget 10.200.243.223:2013 / telnet 10.200.243.223 2013 --> Ens deixa
* $ wget 10.200.243.225:2013 / telnet 10.200.243.225 2013 --> NO ens deixa
* $ vim ip-02-output.sh

```
# Siguis d'on siguis, no pots accedir al port 80, 13 i 7:
iptables -A OUTPUT -p tcp --dport 80 -j REJECT
iptables -A OUTPUT -p tcp --dport 13 -j REJECT
iptables -A OUTPUT -p tcp --dport 7 -j REJECT
```

* $ sudo bash ip-default.sh --> Netejem regles
* $ sudo bash ip-02-output.sh
* $ wget 10.200.243.223:[80/13/7] / telnet 10.200.243.223 [80/13/7] --> No ens deixa però amb el 13 sí perquè més adalt tenim una regla que si ens deixa
* $ vim ip-02-output.sh

```
# No és pot accedir al i02 ni al i06:
iptables -A OUTPUT -d 10.200.243.202 -j REJECT		# No posem '-p' perquè xapem TOT
iptables -A OUTPUT -d 10.200.243.206 -j REJECT
```

* $ sudo bash ip-default.sh
* $ sudo bash ip-02-output.sh
* $ wget 10.200.243.[202/206] / telnet 10.200.243.[202/206] --> No ens deixa

## Exercici 3 (established):

* **Documentació al fitxer 'ip-03-established.sh'**

## Exercici 4 (icmp):

* $ vim ip-04...

```
# 3) Volem rebre pings i fer pings (icmp type 8 (rebre) | icmp type 0 (respondre --> ping)):
#iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
#iptables -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT

# 2) Permetem fer pings i rebre pings de tot tipus:
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# 1) Volem fer ping i rebre resposta (depen de la politica per defecte) | (icmp type 8 (petició) | icmp type 0 (resposta)):
#iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
#iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
```

* $ sudo iptables -L
* $ sudo bash ip-default.sh
* $ sudo bash ip-04...
* $ ping i03... --> si que deixa
* $ vim ip-04...

```
# 4) Volem fer pings i no rebre resposta (icmp type 8 (petició) | icmp type 0 (resposta)):
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT

# 2) Permetem fer pings i no rebre pings de cap tipus:
iptables -A OUTPUT -p icmp -j DROP
iptables -A INPUT -p icmp -j DROP
```

* $ sudo bash ip-04...
* $ ping i03... --> no deixa
* $ vim ip-05-nat.sh

```
# 1) Fer NAT per les xarxes internes:
#       - 172.19.0.0/24
#       - 172.20.0.0/24
# MASQUERADE (Enganyar)
# Tot el que s'emmascara de sortida quan torna ja està desenmascarat, per tant, no cal dir-li res de sor
tida
# POSTROUTING --> Quan el paquet arribi al router, aquest decidirà per quina interfície enviar-ho, abans d'enviar-ho, canvia la IP!
iptables -t nat -A POSTROUTING -s 172.19.0.0/24 -o enp6s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.0.0/24 -o enp6s0 -j MASQUERADE
```

* $ sudo bash ip-05...
* $ vim ip-06...

```
# 4) Evitar que es falsifiqui la ip de origen: SPOOFING (interfície 'br..' = bridge)
iptable -A FORWARD ! -s 172.19.0.0/24 -i br-7d521247ea41 -j DROP
iptable -A FORWARD ! -s 172.20.0.0/24 -i br-7d521247ea41 -j DROP

# 3) El Router ha de xapar la connexió entre Xarxa A i Xarxa B:
# NO POT!

# 2) Xarxa A permetre navegar per internet però res més a l'exterior (docker0 = interfície de la xarxa a | eth0 = interfície del router:
iptables -A FORWARD -s 172.19.0.0/24 -d 0.0.0.0/0 -p tcp --dport 80 -j ACCEPT
#iptables -A FORWARD -i docker0 -o eth0 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 0.0.0.0/24 -p tcp --sport 80 -d 172.19.0.0/24 \
            -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i eth0 -p tcp --sport 80 -o docker0 \
            -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 172.19.0.0/24 -d 0.0.0.0/0 -j REJECT
#iptables -A FORWARD -i docker0 -o eth0 -j REJECT      
iptables -A FORWARD -s 0.0.0.0/0 -o 172.19.0.0/24 -j REJECT
#iptables -A FORWARD -i eth0 -o docker0 -j REJECT
```

* $ sudo bash ip-06...
* $ sudo systemctl stop docker --> Si fem 'iptables -L', veiem que hi ha regles per xapar docker
* $ sudo systemctl start docker
* $ docker run --rm --name a1 -h a1 --net 2hisix -d edtasixm11/net18:nethost
* $ docker run --rm --name a2 -h a2 --net 2hisix -d edtasixm11/net18:nethost --> a2 és veurà amb a1 perquè estàn a la mateixa xarxa
* $ docker network list
* $ docker network create xarxab
* $ docker run --rm --name b1 -h b1 --net xarxab -d edtasixm11/net18:nethost
* $ docker exec -it a1 /bin/bash
* a1$ nmap [a1/a2] --> respon
* a1$ nmap b1 --> no respon
* $ docker network inspect xarxab
* $ iptables -L --> docker ens ha posat un mun de regles

**Si ens carreguem aquestes regles, els containers és podràn veure entre ells?**

* $ sudo bash ip-04... --> Ens carreguem totes les regles de docker
* a1$ nmap 172.20.0.2
```
Starting Nmap 7.60 ( https://nmap.org ) at 2022-04-21 11:56 UTC
Nmap scan report for 172.20.0.2
Host is up (0.000012s latency).
Not shown: 984 closed ports
PORT     STATE SERVICE
7/tcp    open  echo
13/tcp   open  daytime
19/tcp   open  chargen
21/tcp   open  ftp
22/tcp   open  ssh
37/tcp   open  time
80/tcp   open  http
110/tcp  open  pop3
143/tcp  open  imap
993/tcp  open  imaps
995/tcp  open  pop3s
2013/tcp open  raid-am
2022/tcp open  down
3013/tcp open  gilatskysurfer
5080/tcp open  onscreen
8080/tcp open  http-proxy
```

**RESPOSTA:** Sí

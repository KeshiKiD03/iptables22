#firewall21

**HowTo-ASIX-Firewalls:**

https://gitlab.com/edtasixm11/m11-sad/-/blob/master/UF3_Tallafocs_i_servidors_intermediaris/HowTo-ASIX-Firewalls.pdf

##Apunts generals:
Només podem accedir al 'loopback' desde el propi ordinador, qui vingui per fora, atacarà la nostra interfície de cara a l'exetior (**EX: enp1s0**)

**Firewall:** Funcionen gràcies a regles ACL (Access Control List)
* Regles amb precedència (**SI una FA 'MATCH' S'APLICA I NO CONTINÚA, SEMPRE S'EVALUA DE LA PRIMERA FINS L'ÚLTIMA**)
* Primer **posar les regles específiques**, després **posar les generals**. (EX: Primer deixar a un alumne sortir, i després que ningú pugui entrar, si ho fem al revés, l'alumne no podrà sortir)
* Accions: **Accept (Permetem el tràfic)**, **Reject (És rebutja però s'informa del rebuig (s'envia un paquet ICMP (igual que 'ping') que ens informa: 'Not Avaliable'))**, **Drop (És rebutja el paquet i no es diu res!)**

##OUTPUT:
Podem posar regles que filtrin el tràfic cap a fora **originat** pel host (**Regles output**)

Podem posar regles contra: **TOTHOM, UNA PETITA XARXA O ORDINADOR/S EN CONCRETS.**

Podem filtrar segons: **Host/Xarxa destí, Port/Servei destí, Host/Xarxa destí + Port/Servei destí o Port orígen**

##INPUT:
Podem posar regles que filtrin el tràfic cap a dins, tràfic destinat al host (**Regles input**)

Podem filtrar el tràfic en funció de l'orígen (**EX: IP/Xarxa/Port orígen o Port on va dirigit (interficie) --> Deixem que entri tràfic per el port 21 però no pel 22**)

##Apunts generals:
Perque un Kernel enruti hem de posar '1' al **/ip/forward**

DNAT (Destination NAT): Canviar contingut del paquet abans de que s'enruti (Hi ha 2 generalment, PRE-PROCESSAMENT I POST-PROCESSAMENT)

Si el paquet va cap al propi ordinador nostre --> **INPUT** --> Des del propi ordinador ens volem connectar cap a fora... --> S'envia cap a OUTPUT per processar la sortida.

Si el paquet no va cap al propi ordinador nostre --> **FORWARD** --> Va cap a la sortida.

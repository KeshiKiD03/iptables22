🔥 CAPÍTULO — IPTABLES (Firewall clásico de Linux)

Control total del tráfico de red a nivel de kernel

🧱 1. ¿Qué es iptables?

iptables es una herramienta que permite gestionar las reglas del firewall del kernel de Linux (Netfilter).

Sirve para:

Permitir tráfico

Bloquear tráfico

Redirigir puertos

Hacer NAT

Filtrar paquetes por IP, puerto, protocolo, interfaz…

👉 Idea clave: iptables controla qué entra, qué sale y qué se reenvía en tu máquina.

🧩 2. Las 3 tablas principales

Iptables tiene varias tablas, pero las importantes son:

🟦 filter (la tabla por defecto)

Controla el tráfico normal.

Cadenas:

INPUT → tráfico que entra al sistema

OUTPUT → tráfico que sale del sistema

FORWARD → tráfico que pasa a través del sistema (routers)

🟩 nat

Para traducción de direcciones (NAT).

Cadenas:

PREROUTING

POSTROUTING

OUTPUT

🟧 mangle

Para modificar paquetes (TTL, QoS, marcas).

👉 Idea clave: 90% del trabajo se hace en filter y nat.

🧱 3. Cadenas y políticas por defecto

Cada cadena tiene una política por defecto:

Ejemplo:

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

👉 Idea clave: Política DROP + reglas explícitas = firewall seguro.

🛠️ 4. Comandos esenciales

🔍 Ver reglas

iptables -L -n -v

➕ Añadir regla

iptables -A INPUT -p tcp --dport 22 -j ACCEPT

➖ Eliminar regla

iptables -D INPUT 1

🔄 Guardar reglas (depende de distro)

Debian/Ubuntu:

iptables-save > /etc/iptables/rules.v4

CentOS/RHEL:

service iptables save

👉 Idea clave: si no guardas las reglas, se pierden al reiniciar.

🧬 5. Ejemplos prácticos (lo que realmente se usa)

🟦 Permitir SSH

iptables -A INPUT -p tcp --dport 22 -j ACCEPT

🟩 Permitir HTTP/HTTPS

iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

🟥 Bloquear una IP

iptables -A INPUT -s 192.168.1.50 -j DROP

🟧 Permitir solo una IP

iptables -A INPUT -p tcp --dport 22 -s 203.0.113.10 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j DROP

🟨 Permitir ping

iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

🟫 Bloquear ping

iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

🌐 6. NAT con iptables (muy importante)

🟦 Masquerade (salida a Internet)

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

🟩 Port forwarding (redirección de puertos)

Ejemplo: redirigir puerto 80 externo → 8080 interno

iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 \
  -j DNAT --to-destination 192.168.1.10:8080

👉 Idea clave: iptables puede convertir tu Linux en un router/firewall completo.

🧱 7. Orden de las reglas (crítico)

Iptables evalúa reglas de arriba hacia abajo.

Ejemplo:

iptables -A INPUT -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

Resultado: SSH queda bloqueado, porque la regla DROP se ejecuta antes.

👉 Idea clave: el orden de las reglas lo es todo.

🛡️ 8. Buenas prácticas de seguridad

Política por defecto: DROP

Permitir solo lo necesario

Registrar intentos sospechosos

No permitir SSH desde cualquier sitio

Usar -m state --state ESTABLISHED,RELATED

Guardar reglas

Documentar reglas complejas

Ejemplo de regla segura:

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

🧪 9. Ejemplo de firewall completo (muy típico en ASIR/ASIX)

iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir loopback
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones establecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# HTTP/HTTPS
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# Ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

👉 Idea clave: este es el firewall base de cualquier servidor Linux.

🧩 10. iptables vs nftables (actualidad)

Hoy en día, muchas distros usan nftables como reemplazo moderno.

Pero:

iptables sigue funcionando

iptables-nft actúa como compatibilidad

En ASIR/ASIX se sigue enseñando iptables

👉 Idea clave: saber iptables te permite entender nftables.

🎯 ¿Cómo quieres seguir?

Puedo ayudarte a:

Crear un firewall completo para un servidor real

Hacer NAT avanzado

Configurar iptables como router

Integrarlo con Docker (muy importante)

Migrar reglas de iptables → nftables

Simular ataques y bloquearlos con iptables

¿Quieres que pasemos a ejercicios prácticos, NAT avanzado, o prefieres seguir con otro tema del índice?

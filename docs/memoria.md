# Memoria del Laboratorio — Failover Routing

**Grupo:** 7  
**Materia:** Gestión Operativa y Seguridad en Redes (GOYS)

## Integrantes y roles

| Integrante | Roles asignados |
|---|---|
| Martina Castellani | R1 — Líder / Edge-WAN + R5 — Hosts / QA / Operación |
| Tomás Terruli | R2 — Proveedores |
| Pilar Giannelli | R3 — Core + R4 — Distribución |

> Debido a que el Grupo 7 está conformado por tres integrantes, se distribuyen
> entre ellos las responsabilidades de los cinco roles definidos en la consigna.

---

# 1. Diseño (F0)

## 1.1 Corrección del diagrama

A partir del análisis del diagrama original "Enterprise Network Design (Cisco)",
se identificaron los siguientes problemas y se definieron las correcciones
correspondientes.

| # | Defecto detectado | Corrección aplicada | Justificación |
|---|---|---|---|
| 1 | Firewall único, generando un punto único de falla (SPOF) | En un entorno productivo se utilizaría un par de firewalls en alta disponibilidad | Si el único firewall falla, se pierde la conectividad. La redundancia permite mantener el servicio ante la falla de uno de ellos. |
| 2 | Existencia de subredes solapadas | Se diseña un esquema de direccionamiento donde cada enlace y cada LAN posee una subred diferente | Evita ambigüedades de enrutamiento y permite identificar claramente cada segmento de la red. |
| 3 | No existe un enlace entre los dos routers del core | Se incorpora el enlace CORE-1 ↔ CORE-2 | Permite disponer de un camino alternativo y elimina una debilidad del diseño original. |
| 4 | El protocolo de redundancia de gateway se encuentra en el core | VRRP se implementará en la capa de distribución | El core se mantiene como una capa de tránsito, mientras que la distribución proporciona los gateways redundantes a las LAN. |
| 5 | Route Reflector iBGP incorrectamente ubicado | Se utilizará eBGP entre EDGE e ISP-1/ISP-2, sin Route Reflector | El escenario utiliza multihoming hacia dos sistemas autónomos externos, por lo que corresponde utilizar eBGP. |

---

## 1.2 Plan de direccionamiento (IPAM)

Se utilizarán subredes /30 para los enlaces punto a punto y redes /24 para las
LAN. Cada segmento utiliza una red diferente para evitar solapamientos.

| Enlace / Red | Subred | Dispositivo A | Dispositivo B |
|---|---|---|---|
| ISP-1 ↔ EDGE | 10.0.0.0/30 | ISP-1: 10.0.0.1 | EDGE: 10.0.0.2 |
| ISP-2 ↔ EDGE | 10.0.0.4/30 | ISP-2: 10.0.0.5 | EDGE: 10.0.0.6 |
| EDGE ↔ CORE-1 | 10.0.0.8/30 | EDGE: 10.0.0.9 | CORE-1: 10.0.0.10 |
| EDGE ↔ CORE-2 | 10.0.0.12/30 | EDGE: 10.0.0.13 | CORE-2: 10.0.0.14 |
| CORE-1 ↔ CORE-2 | 10.0.0.16/30 | CORE-1: 10.0.0.17 | CORE-2: 10.0.0.18 |
| CORE-1 ↔ DIST-1 | 10.0.0.20/30 | CORE-1: 10.0.0.21 | DIST-1: 10.0.0.22 |
| CORE-2 ↔ DIST-1 | 10.0.0.24/30 | CORE-2: 10.0.0.25 | DIST-1: 10.0.0.26 |
| CORE-1 ↔ DIST-2 | 10.0.0.28/30 | CORE-1: 10.0.0.29 | DIST-2: 10.0.0.30 |
| CORE-2 ↔ DIST-2 | 10.0.0.32/30 | CORE-2: 10.0.0.33 | DIST-2: 10.0.0.34 |
| USERS | 192.168.10.0/24 | DIST-1: 192.168.10.2 | DIST-2: 192.168.10.3 |
| SERVERS | 192.168.20.0/24 | DIST-1: 192.168.20.2 | DIST-2: 192.168.20.3 |

### VRRP

| Grupo | VRID | Master | Priority | IP virtual |
|---|---:|---|---:|---|
| USERS | 10 | DIST-1 | 150 | 192.168.10.1 |
| SERVERS | 20 | DIST-2 | 150 | 192.168.20.1 |

Esto permite realizar load-sharing: DIST-1 será el master para USERS y DIST-2
será el master para SERVERS.

### Hosts

| Host | Dirección IP | Gateway |
|---|---|---|
| PC-USER | 192.168.10.100/24 | 192.168.10.1 |
| SRV | 192.168.20.100/24 | 192.168.20.1 |

### Router-IDs

| Router | Router-ID |
|---|---|
| ISP-1 | 1.1.1.1 |
| ISP-2 | 2.2.2.2 |
| EDGE | 3.3.3.3 |
| CORE-1 | 4.4.4.4 |
| CORE-2 | 5.5.5.5 |
| DIST-1 | 6.6.6.6 |
| DIST-2 | 7.7.7.7 |

---

## 1.3 Política de seguridad

### Usuarios y privilegios

Se utilizará una cuenta administrativa protegida con contraseña segura para
realizar cambios de configuración.

Además, se creará un usuario `monitor` con permisos mínimos necesarios para
tareas de monitoreo, evitando utilizar privilegios administrativos cuando no
sean necesarios.

### Servicios a deshabilitar

En los routers se deshabilitarán los servicios que no sean necesarios para el
laboratorio, reduciendo la superficie de ataque.

Entre ellos se considerarán:

- Telnet
- FTP
- API
- API-SSL

Los servicios de administración que permanezcan habilitados se limitarán a las
redes desde las cuales sea necesario administrarlos.

### Autenticación del plano de control

Se utilizarán mecanismos de autenticación en los protocolos de enrutamiento y
redundancia:

- OSPF: autenticación MD5.
- BGP: TCP-MD5.
- VRRP: autenticación según lo requerido por el laboratorio.

Las claves utilizadas no serán publicadas en la documentación ni almacenadas
en texto plano en el repositorio público.

---

## 1.4 Política de operación

### Change log

Todo cambio realizado sobre la red deberá quedar documentado.

Se utilizará el siguiente formato:

| Fecha | Responsable | Cambio | Motivo | Cómo se revierte |
|---|---|---|---|---|
| 02/10/2026 | Martina Castellani (R1) | Creación del repositorio, README con integrantes y roles (`12badac`, `120dc01`) | Disponer del repositorio de trabajo del grupo | `git revert` de los commits indicados |
| 02/10/2026 | Martina Castellani (R1) | Estructura de carpetas `backups/`, `capturas/`, `configs/`, `docs/`, `runbooks/` (`ebf8ed3` a `0909bf6`) | Cumplir la estructura de repositorio exigida por la consigna | `git revert` de los commits indicados |
| 02/10/2026 | Grupo 7 | Diseño F0: corrección del diagrama, IPAM, política de seguridad y de operación en la memoria (`bff9d75`) | Definir el diseño antes de la implementación | `git revert bff9d75` |
| 02/10/2026 | Grupo 7 | Backlog inicial y cierre de tareas F0 (`1a80ac8`, `6656623`) | Planificar las fases F0–F5 y registrar avance | `git revert` de los commits indicados |
| 08/10/2026 | Grupo 7 | F1 en GNS3: 7 routers CHR, 2 switches, 2 hosts, IPs de enlace y loopbacks según IPAM | Implementar la topología diseñada en F0 | Restaurar snapshot previo de GNS3 |
| 08/10/2026 | Grupo 7 | F1 hardening: usuario `monitor` (grupo read), contraseña de admin, servicios FTP, Telnet, WWW, API y API-SSL deshabilitados en los 7 routers | Reducir la superficie de ataque (política 1.3) | `/ip service enable` de cada servicio y `/user remove monitor` |
| 08/10/2026 | Martina Castellani (R1) | Exports `/export` de los 7 routers en `backups/*-F1.rsc` (`b863fc5` a `4e580c7`; actualizados en `c067670` a `8d53a9e`, sin cliente DHCP) | Backup posterior a F1 (política de backup) | `git revert` de los commits indicados |
| 08/10/2026 | Martina Castellani (R1/R5) | Capturas de F1 y memoria F1 (`50b87eb`, `04d4825`, `b3a4dad`, `0b249c6`); backlog F1 completado (`3f6c859`) | Evidencia y documentación de F1 | `git revert` de los commits indicados |
| 16/10/2026 | Martina Castellani (R1/R5) | Capturas de F1 movidas a `capturas/f1/` y numeradas 01–05 (`34f6337`, `356ea45`) | Corrección F1: capturas organizadas y numeradas | `git revert 356ea45 34f6337` |
| 16/10/2026 | Pilar Giannelli (R3/R4) | Recarga de F1 en los 7 routers desde `backups/*-F1.rsc` en la PC de Pilar (los nodos arrancaron de fábrica) | Corrección F1: prueba de restore desde backups | Restaurar snapshot `BASE-F1-RESTAURADO` |
| 16/10/2026 | Martina Castellani (R1/R5) | Evidencia del restore de EDGE (antes/después) y de los hosts (`a7d48c9`) | Corrección F1: restore verificado | `git revert a7d48c9` |
| 16/10/2026 | Tomás Terruli (R2) | Evidencia del restore y hardening de ISP-1 e ISP-2 (`97a88ea`) | Corrección F1: restore verificado | `git revert 97a88ea` |
| 16/10/2026 | Pilar Giannelli (R3/R4) | Evidencia del restore de CORE-1, CORE-2, DIST-1 y DIST-2 (`42d78a8`) | Corrección F1: restore verificado | `git revert 42d78a8` |
| 16/10/2026 | Tomás Terruli (R2) | Change log completado con el historial real de commits | Corrección F1: change log coherente con los commits | `git revert` de este commit |

El historial del change log deberá ser coherente con los commits realizados
en el repositorio.

Los commits utilizarán la convención:

`tipo(alcance): descripción breve`

Ejemplos:

`docs(memoria): completo diseño F0`

`feat(configs): agrego configuracion VRRP`

`ops(backup): agrego backup posterior a F2`

### Política de backup

Se realizará un backup:

- Antes de realizar cambios importantes.
- Después de completar cada fase.
- Antes de ejecutar pruebas de failover.
- Antes de realizar modificaciones que puedan afectar la conectividad.

Se conservarán los `/export` de los routers dentro de la carpeta `backups/`
del repositorio.

También se realizarán backups de RouterOS cuando corresponda y se documentará
posteriormente una prueba de restauración.


# 2. F1 — Topología, hardening y backup

## 2.1 Implementación

Se implementó en GNS3 2.2.61 la topología del laboratorio con siete routers MikroTik CHR (RouterOS 7.21.5), dos switches Ethernet (SW-USERS y SW-SERVERS) y dos hosts VPCS (PC-USER y SRV), cableados según el plan de direccionamiento de la sección 1.2.

| Router | ether1 | ether2 | ether3 | ether4 | Loopback |
|---|---|---|---|---|---|
| ISP-1 | 10.0.0.1/30 → EDGE | — | — | — | 1.1.1.1 |
| ISP-2 | 10.0.0.5/30 → EDGE | — | — | — | 2.2.2.2 |
| EDGE | 10.0.0.2/30 → ISP-1 | 10.0.0.6/30 → ISP-2 | 10.0.0.9/30 → CORE-1 | 10.0.0.13/30 → CORE-2 | 3.3.3.3 |
| CORE-1 | 10.0.0.10/30 → EDGE | 10.0.0.17/30 → CORE-2 | 10.0.0.21/30 → DIST-1 | 10.0.0.29/30 → DIST-2 | 4.4.4.4 |
| CORE-2 | 10.0.0.14/30 → EDGE | 10.0.0.18/30 → CORE-1 | 10.0.0.25/30 → DIST-1 | 10.0.0.33/30 → DIST-2 | 5.5.5.5 |
| DIST-1 | 10.0.0.22/30 → CORE-1 | 10.0.0.26/30 → CORE-2 | 192.168.10.2/24 → USERS | 192.168.20.2/24 → SERVERS | 6.6.6.6 |
| DIST-2 | 10.0.0.30/30 → CORE-1 | 10.0.0.34/30 → CORE-2 | 192.168.10.3/24 → USERS | 192.168.20.3/24 → SERVERS | 7.7.7.7 |

Hardening aplicado en los siete routers, según la política 1.3:

- Contraseña de administrador en el usuario `admin`.
- Usuario `monitor` con grupo `read`.
- Servicios deshabilitados: FTP, Telnet, WWW, API y API-SSL. Quedan habilitados SSH y Winbox para administración.
- Cliente DHCP eliminado de las interfaces.

Las contraseñas no se publican en el repositorio.

## 2.2 Verificación

| # | Prueba | Origen → destino | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|---|
| 1 | Topología completa | GNS3 | 11 nodos cableados según IPAM | OK | `capturas/f1/01-topologia.png` |
| 2 | Enlace EDGE ↔ CORE-1 | EDGE → 10.0.0.10 | 0 % pérdida | OK | `capturas/f1/02-ping-EDGE-CORE1.png` |
| 3 | Host USERS a su distribución | PC-USER → 192.168.10.2 / .3 | 0 % pérdida | OK | `capturas/f1/03-ping-PC-USER.png` |
| 4 | Host SERVERS a su distribución | SRV → 192.168.20.2 / .3 | 0 % pérdida | OK | `capturas/f1/04-ping-SRV.png` |
| 5 | Usuario de monitoreo | `/user print` | `monitor` en grupo `read` | OK | `capturas/f1/05-usuario-monitor.png` |

## 2.3 Backup

Se exportó la configuración de cada router con `/export` y se guardó en el repositorio:

| Router | Archivo |
|---|---|
| ISP-1 | `backups/ISP-1-F1.rsc` |
| ISP-2 | `backups/ISP-2-F1.rsc` |
| EDGE | `backups/EDGE-F1.rsc` |
| CORE-1 | `backups/CORE-1-F1.rsc` |
| CORE-2 | `backups/CORE-2-F1.rsc` |
| DIST-1 | `backups/DIST-1-F1.rsc` |
| DIST-2 | `backups/DIST-2-F1.rsc` |

`/export` no incluye usuarios ni contraseñas, por lo que el usuario `monitor` y la contraseña de `admin` se documentan como pasos adicionales del procedimiento de restore.

## 2.4 Prueba de restore (corrección F1)

**Contexto.** Al importar el proyecto GNS3 en la PC de Pilar Giannelli, los siete routers arrancaron con la configuración de fábrica: el prompt mostraba `[admin@MikroTik]`, `/ip address print` no devolvía direcciones y RouterOS pedía aceptar la licencia y cambiar la contraseña. Los intentos de ingreso con la contraseña de F1 fallaron, lo que confirma que la configuración no estaba presente. Esta situación se usó como prueba real de restore desde los backups del repositorio.

**Procedimiento aplicado en cada router:**

1. Ingresar con `admin` (sin contraseña) y aceptar el primer arranque.
2. Aplicar el contenido de `backups/<ROUTER>-F1.rsc`: identidad, eliminación del cliente DHCP, bridge `loopback`, `disable-running-check=no` en ether1–ether4, direcciones IP y servicios deshabilitados.
3. Recrear lo que `/export` no incluye: contraseña de `admin` y usuario `monitor` (grupo `read`).
4. Verificar con `/user print`, `/ip address print`, `/ip service print` y ping a los vecinos directos.
5. Configurar los hosts VPCS (`ip ... ` y `save`) y verificar ping a ambas distribuciones.

**Resultados:**

| # | Equipo | Verificación | Resultado | Evidencia |
|---|---|---|---|---|
| 1 | EDGE (antes) | Router de fábrica, sin IPs | Confirmado vacío | `capturas/f1-correccion/01-restore-antes-EDGE.png` |
| 2 | EDGE | Usuarios, 5 IPs, servicios, ping a ISP-1 (10.0.0.1) | OK, 0 % pérdida | `capturas/f1-correccion/02-restore-despues-EDGE.png` |
| 3 | ISP-1 | Usuarios, IPs, servicios, ping a EDGE (10.0.0.2) | OK, 0 % pérdida | `capturas/f1-correccion/03-ISP1-hardening.png` |
| 4 | ISP-2 | Usuarios, IPs, servicios, ping a EDGE (10.0.0.6) | OK, 0 % pérdida | `capturas/f1-correccion/04-ISP2-hardening.png` |
| 5 | CORE-1 | Usuarios, IPs, servicios, ping a EDGE (10.0.0.9) | OK, 0 % pérdida | `capturas/f1-correccion/05-restore-CORE1.png` |
| 6 | CORE-2 | Ping a EDGE (10.0.0.13) y a CORE-1 por el enlace core–core (10.0.0.17) | OK, 0 % pérdida | `capturas/f1-correccion/06-restore-CORE2.png` |
| 7 | DIST-1 | Ping a CORE-1 (10.0.0.21) y CORE-2 (10.0.0.25) | OK, 0 % pérdida | `capturas/f1-correccion/07-restore-DIST1.png` |
| 8 | DIST-2 | Ping a CORE-1 (10.0.0.29), CORE-2 (10.0.0.33), DIST-1 por USERS (192.168.10.2) y por SERVERS (192.168.20.2) | OK, 0 % pérdida | `capturas/f1-correccion/08-restore-DIST2.png` |
| 9 | PC-USER | Ping a 192.168.10.2 y 192.168.10.3 | OK | `capturas/f1-correccion/09-restore-PC-USER.png` |
| 10 | SRV | Ping a 192.168.20.2 y 192.168.20.3 | OK | `capturas/f1-correccion/10-restore-SRV.png` |

Una vez verificado el restore se guardó el snapshot `BASE-F1-RESTAURADO` en GNS3, punto de partida de F2.

## 2.5 Qué funcionó y qué no

**Funcionó:**

- Los exports de `backups/` permitieron reconstruir los siete routers sin información adicional sobre direcciones ni interfaces.
- El enlace CORE-1 ↔ CORE-2 (defecto 3 de F0) quedó operativo y verificado.

**No funcionó / lecciones aprendidas:**

- El proyecto GNS3 compartido no incluía la imagen `chr-7.21.5.img` ni los discos de los routers, por lo que en otra PC los nodos arrancaron vacíos. Se descargó la imagen de la misma versión desde MikroTik y se restauró desde los exports.
- GNS3 en Windows sin HAXM no iniciaba los nodos. Se resolvió deshabilitando la aceleración por hardware de QEMU en las preferencias.
- `/export` no incluye usuarios ni contraseñas: el procedimiento de restore debe recrearlos manualmente. Se incorpora este paso al procedimiento.
- Al pegar un bloque dos veces, RouterOS responde `failure: already have ...` y no modifica la configuración. El estado final se valida siempre con los comandos `print`.

**Resultado:** F1 restaurada y verificada en los siete routers y en los dos hosts, con evidencia en `capturas/f1-correccion/`.



# 3. F2 — OSPF y VRRP

## 3.1 Qué hicimos con OSPF

Configuramos OSPF en un solo área (la 0, backbone) en los cinco routers de adentro: EDGE, los dos CORE y las dos distribuciones. Los ISP quedaron afuera a propósito: son otros sistemas autónomos y con ellos hablamos BGP en F3.

| Router | Router-ID | Interfaces donde forma vecinos | Interfaces pasivas |
|---|---|---|---|
| EDGE | 3.3.3.3 | ether3 (CORE-1), ether4 (CORE-2) | loopback |
| CORE-1 | 4.4.4.4 | ether1 (EDGE), ether2 (CORE-2), ether3 (DIST-1), ether4 (DIST-2) | loopback |
| CORE-2 | 5.5.5.5 | ether1 (EDGE), ether2 (CORE-1), ether3 (DIST-1), ether4 (DIST-2) | loopback |
| DIST-1 | 6.6.6.6 | ether1 (CORE-1), ether2 (CORE-2) | loopback, ether3 (USERS), ether4 (SERVERS) |
| DIST-2 | 7.7.7.7 | ether1 (CORE-1), ether2 (CORE-2) | loopback, ether3 (USERS), ether4 (SERVERS) |

Algunas decisiones que tomamos:

- Pusimos los enlaces /30 como punto a punto (`type=ptp`). Como cada enlace une solo dos routers, no tiene sentido elegir DR/BDR, y la adyacencia sube más rápido.
- Usamos autenticación MD5 con la misma clave en los cinco routers, como habíamos definido en la política de seguridad (1.3). La clave no está en el repo: el `/export` la oculta.
- Las LAN y las loopbacks van como pasivas. Así OSPF anuncia esas redes, pero no manda paquetes hacia los hosts.
- El enlace entre CORE-1 y CORE-2, que agregamos al corregir el diagrama en F0, también forma vecindad. Si se cae un camino, el núcleo tiene otro.

## 3.2 Qué hicimos con VRRP

VRRP lo pusimos en la distribución (corrección 4 de F0) y repartimos la carga: cada distribución es la principal de una LAN y la de respaldo de la otra.

| Grupo | Interfaz | Gateway virtual | DIST-1 | DIST-2 | MAC virtual |
|---|---|---|---|---|---|
| vrid 10 — USERS | ether3 | 192.168.10.1 | Master (prioridad 150) | Backup (100) | 00:00:5E:00:01:0A |
| vrid 20 — SERVERS | ether4 | 192.168.20.1 | Backup (100) | Master (prioridad 150) | 00:00:5E:00:01:14 |

Usamos VRRP versión 2 porque en RouterOS 7 es la única que permite autenticación (en la versión 3 está deprecada). Al backup le dejamos la prioridad por defecto, 100.

## 3.3 Cómo lo verificamos

| # | Qué probamos | Qué esperábamos | Qué obtuvimos | Evidencia |
|---|---|---|---|---|
| P1 | Vecinos OSPF | 7 adyacencias en Full | Bien: los dos CORE con 4 vecinos Full cada uno y EDGE, DIST-1 y DIST-2 con 2 | `capturas/f2/p1-ospf-vecinos-CORE1.png`, `p1-ospf-vecinos-CORE2.png`, `config-ospf-EDGE.png`, `config-ospf-DIST1.png`, `config-ospf-DIST2.png` |
| P2 | Autenticación OSPF | `auth=md5` en los templates | Bien | `capturas/f2/config-ospf-*.png` |
| P2b | Rutas que aprendió EDGE | Las LAN, las loopbacks y los /30 de adentro | Bien, y las LAN aparecen por los dos CORE a la vez (ECMP) | `capturas/f2/p2-ospf-rutas-EDGE.png` |
| P3 | Estado de VRRP | DIST-1 master en vrrp10 y backup en vrrp20; DIST-2 al revés | Bien | `capturas/f2/p3-vrrp-DIST1.png`, `p3-vrrp-DIST2.png`, `config-vrrp-DIST1.png`, `config-vrrp-DIST2.png` |
| P4 | Autenticación VRRP | Versión 2 con autenticación simple | Bien; también se ve en `configs/DIST-1.rsc` y `DIST-2.rsc` | `capturas/f2/config-vrrp-DIST*.png` |
| P5 | Gateway virtual desde los hosts | Que respondan al .1 con la MAC virtual | Bien: PC-USER ve 00:00:5e:00:01:0a y SRV ve 00:00:5e:00:01:14 | `capturas/f2/p5-gateway-PC-USER.png`, `p5-gateway-SRV.png` |
| P6 | Tráfico entre LAN | Que PC-USER llegue a SRV | Bien: el trace pasa primero por 192.168.10.2, que es DIST-1, el master de USERS | `capturas/f2/p6-inter-LAN.png` |

## 3.4 Configuración y backup

Exportamos la configuración de cada router y la subimos a `configs/` (CORE-1, CORE-2, DIST-1, DIST-2 y EDGE). Antes de empezar F3 sacamos el snapshot `BASE-F2` en GNS3, y los exports de los siete routers al terminar F2 están en `backups/post-F2/`.

## 3.5 Qué funcionó y qué no

**Lo que funcionó:**

- Las siete adyacencias subieron a Full. Además, cada CORE instaló dos caminos de igual costo hacia cada LAN, que es justamente la redundancia que buscábamos con el diseño.
- VRRP eligió master y backup según las prioridades, y los hosts usan la MAC virtual como gateway.

**Lo que no funcionó y cómo lo resolvimos:**

- En EDGE y en DIST-1 cargamos el template de OSPF con las cuatro interfaces (`ether1,ether2,ether3,ether4`), porque copiamos la línea de los CORE sin adaptarla. En EDGE eso mandaba OSPF hacia los ISP y en DIST-1 hacia las LAN. Lo detectamos con `interface-template print` y lo corregimos con `/routing ospf interface-template set 0 interfaces=...`, sin que se cayeran los vecinos. Aprendimos a revisar cada bloque antes de pegarlo.
- RouterOS oculta en pantalla las líneas que llevan claves, así que si una de esas líneas falla no se nota. Por eso, después de cada bloque, verificamos con `print`.
- Una vez el pegado se cortó y la clave de VRRP quedó visible en la consola. No usamos esa pantalla como evidencia.

**Resultado:** OSPF y VRRP funcionando con autenticación, y el gateway redundante repartiendo la carga entre las dos distribuciones.

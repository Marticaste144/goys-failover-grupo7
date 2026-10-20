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

| 16/10/2026 | Pilar Giannelli (R3) | OSPF área 0 con MD5 en CORE-1 y CORE-2, incluido el enlace entre ellos (`766d4fc`) | F2: ruteo interno | `/routing ospf instance remove ospf-1` |

| 16/10/2026 | Pilar Giannelli (R4) | OSPF con MD5 y VRRP versión 2 con autenticación en DIST-1 y DIST-2; DIST-1 master de USERS y DIST-2 master de SERVERS (`4b68245`) | F2: gateway redundante repartiendo la carga | `/interface vrrp remove vrrp10,vrrp20` y sacar las IP virtuales |

| 16/10/2026 | Martina Castellani (R1) | OSPF con MD5 en EDGE, solo hacia el core (ether3 y ether4) (`a609e3d`) | F2: sumar el borde al ruteo interno | `/routing ospf instance remove ospf-1` |

| 16/10/2026 | Grupo 7 | Corregimos el template OSPF de EDGE y DIST-1, que habíamos cargado con ether1 a ether4 | No mandar OSPF hacia los ISP ni hacia las LAN | `/routing ospf interface-template set 0 interfaces=...` |

| 16/10/2026 | Martina Castellani (R1/R5) y Pilar Giannelli (R3/R4) | Capturas de F2 (`4ecbc43`, `d38b004`) | Evidencia de F2 | `git revert` de esos commits |

| 16/10/2026 | Tomás Terruli (R2) | eBGP con TCP-MD5 y ruta por defecto en ISP-1 (AS 65001) e ISP-2 (AS 65002) (`7de021b`) | F3: proveedores | `/routing bgp connection remove a-EDGE` |

| 16/10/2026 | Martina Castellani (R1) | eBGP hacia los dos ISP, filtro `ospf-a-bgp` y ruta por defecto hacia adentro en EDGE (`a154842`) | F3: salida por dos proveedores | `/routing bgp connection remove a-ISP1,a-ISP2` |

| 16/10/2026 | Tomás Terruli (R2) | Firewall de entrada y de tránsito en EDGE; administración solo desde 192.168.10.0/24 (`9d76e61`) | F3: proteger el borde | `/ip firewall filter remove [find comment~"F3"]` |

| 17/10/2026 | Martina Castellani y Tomás Terruli | Capturas de F3 (`3994bfa`, `d8840fd`) y corrección del nombre de una captura (`2544d04`) | Evidencia de F3 | `git revert` de esos commits |

| 17/10/2026 | Pilar Giannelli y Tomás Terruli | Memoria de F2 (OSPF y VRRP) y de F3 (BGP y firewall) | Documentar las fases | `git revert` de esos commits |

| 19/10/2026 | Pilar Giannelli (R3/R4) | Snapshot `BASE-F4` en GNS3 antes de los drills; los exports de `backups/post-F3/` quedan como backup previo a F4 | Política de backup: respaldo antes de las pruebas de failover | Restaurar snapshot `BASE-F4` |

| 19/10/2026 | Tomás Terruli (R2) | Reexport de ISP-1 e ISP-2 con la configuración BGP en `configs/` y `backups/post-F3/` (`fix(configs): reexporto ISP-1 e ISP-2 con la configuracion BGP`) | El export de F3 se había hecho antes de configurar BGP | `git revert` de ese commit |

| 19/10/2026 | Pilar Giannelli (R3/R4) | SNMPv3 (usuario `monitor-g7`, solo lectura, desde 192.168.10.0/24) y `public` deshabilitada en CORE-1, CORE-2, DIST-1 y DIST-2 (`feat(configs): agrego SNMP en CORE-1, CORE-2, DIST-1 y DIST-2`) | F4: monitoreo | `/snmp set enabled=no` y `/snmp community remove [find name=monitor-g7]` |

| 19/10/2026 | Tomás Terruli (R1, rotación F4) | SNMPv3, regla de firewall `F4 SNMP desde gestion` y cuatro netwatch en EDGE (`feat(configs): agrego SNMP, netwatch y regla de firewall en EDGE`) | F4: monitoreo y detección de fallas | `/ip firewall filter remove [find comment~"F4 SNMP"]`, `/tool netwatch remove [find comment~"F4"]` y `/snmp set enabled=no` |

| 19/10/2026 | Martina Castellani (R2, rotación F4) | SNMPv3 en ISP-1 e ISP-2 (`feat(configs): agrego SNMP y destino de prueba en ISP-1 e ISP-2`) | F4: monitoreo | `/snmp set enabled=no` y `/snmp community remove [find name=monitor-g7]` |

| 20/10/2026 | Pilar Giannelli (R3/R4) | Drills 1 (VRRP), 2 (OSPF) y 5 (load-sharing): capturas y runbooks | F4: drills de failover | `git revert` de esos commits |

| 20/10/2026 | Martina Castellani (R2, rotación F4) | 8.8.8.8/32 en la loopback de ISP-1 e ISP-2 como destino de Internet simulado | Probar la conmutación de la ruta por defecto en los drills 3 y 4 | `/ip address remove [find comment~"F4 destino"]` |

| 20/10/2026 | Martina Castellani (R2, rotación F4) | Drill 3 (BGP): capturas y runbook | F4: drills de failover | `git revert` de esos commits |

| 20/10/2026 | Tomás Terruli (R1, rotación F4) | Drill 4: dos rutas estáticas con `check-gateway=ping` en EDGE, agregadas para el drill y quitadas al terminar; capturas y runbook | F4: drills de failover | `/ip route remove [find comment~"F4 drill4"]` (ya aplicado) |

| 20/10/2026 | Pilar Giannelli (R3/R4) | Prueba de clave OSPF incorrecta en DIST-2 y restauración de la clave correcta | F4: verificación de seguridad | Volver a cargar la clave correcta en el template de OSPF |

| 20/10/2026 | Tomás Terruli (R1, rotación F4) | Prueba de TCP-MD5 incorrecto en la sesión EDGE↔ISP-2 y restauración de la clave correcta | F4: verificación de seguridad | Volver a cargar la clave correcta en la conexión `a-ISP2` |

| 20/10/2026 | Martina Castellani (R5) | Exports post-F4 de los siete routers en `backups/post-F4/` y snapshot `BASE-F4-FINAL` | Política de backup: respaldo al terminar la fase | Restaurar snapshot `BASE-F4-FINAL` |

| 20/10/2026 | Grupo 7 | Memoria de F4 (secciones 5.1 a 5.13), runbooks y cierre del epic F4 en el backlog | Documentar la fase | `git revert` de esos commits |

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

# 4. F3 — BGP y firewall

## 4.1 Qué hicimos con BGP

Armamos eBGP entre EDGE y los dos proveedores. Cada router tiene su propio sistema autónomo:

| Router | AS | Instancia BGP | Vecino | Qué anuncia |

|---|---|---|---|---|

| ISP-1 | 65001 | `bgp-isp1` (router-id 1.1.1.1) | EDGE (10.0.0.2) | Su loopback 1.1.1.1 y una ruta por defecto |

| ISP-2 | 65002 | `bgp-isp2` (router-id 2.2.2.2) | EDGE (10.0.0.6) | Su loopback 2.2.2.2 y una ruta por defecto |

| EDGE | 65000 | `bgp-edge` (router-id 3.3.3.3) | ISP-1 (10.0.0.1) e ISP-2 (10.0.0.5) | Las dos LAN: 192.168.10.0/24 y 192.168.20.0/24 |

Cómo lo resolvimos:

- Las sesiones usan TCP-MD5, con una clave distinta para cada proveedor. Las claves no están en el repo: el `/export` las oculta.

- En los ISP, la loopback hace de "Internet". La anunciamos con una lista (`anuncio-isp`) y además cada ISP le manda a EDGE una ruta por defecto (`default-originate`).

- EDGE toma las rutas de OSPF y las pasa a BGP, pero con un filtro (`ospf-a-bgp`) que deja salir solo las dos LAN. No queríamos que los proveedores vieran nuestros enlaces internos ni las loopbacks.

- Para que los hosts puedan salir, EDGE reparte la ruta por defecto hacia adentro por OSPF (`originate-default=if-installed`). Lo hace solo mientras tenga una ruta por defecto aprendida de algún ISP; si se caen los dos, deja de anunciarla.

## 4.2 Qué hicimos con el firewall de EDGE

| # | Cadena | Acción | Qué deja pasar o bloquea | Para qué |

|---|---|---|---|---|

| 0 | input | accept | Conexiones establecidas o relacionadas | Las respuestas |

| 1 | input | drop | Paquetes inválidos | Limpiar basura |

| 2 | input | accept | ICMP | Poder hacer ping para diagnosticar |

| 3 | input | accept | BGP (TCP 179) desde 10.0.0.1 | Sesión con ISP-1 |

| 4 | input | accept | BGP (TCP 179) desde 10.0.0.5 | Sesión con ISP-2 |

| 5 | input | accept | OSPF desde ether3 y ether4 (lista INTERNAS) | OSPF solo hacia el core |

| 6 | input | accept | SSH y WinBox desde 192.168.10.0/24 (lista GESTION) | Administrar EDGE solo desde la red de gestión |

| 7 | input | drop | Todo lo demás | Que nadie más llegue al router |

| 8 | forward | accept | Conexiones establecidas o relacionadas | Que vuelvan las respuestas al tráfico que sale |

| 9 | forward | drop | Paquetes inválidos | Limpiar basura |

| 10 | forward | drop | Conexiones nuevas desde ether1 y ether2 (lista WAN) | Que desde los ISP no se pueda iniciar nada hacia adentro |

Como red de gestión elegimos USERS (192.168.10.0/24). La política 1.3 decía que la administración tenía que quedar limitada a las redes necesarias, y USERS es donde está la PC desde la que se administra.

## 4.3 Cómo lo verificamos

| # | Qué probamos | Qué esperábamos | Qué obtuvimos | Evidencia |

|---|---|---|---|---|

| P7 | Sesiones BGP | Dos sesiones establecidas en EDGE | Bien: a-ISP1-1 (AS 65001) y a-ISP2-1 (AS 65002) | `capturas/f3/p7-bgp-EDGE.png`, `config-bgp-EDGE.png`, `config-bgp-ISP1.png`, `config-bgp-ISP1-b.png`, `config-bgp-ISP2.png` |

| P8 | Rutas BGP | Los ISP ven solo las dos LAN; EDGE recibe la ruta por defecto y las loopbacks | Bien. De las dos rutas por defecto queda activa la de ISP-1 y la de ISP-2 queda de reserva | `capturas/f3/p8-rutas-ISP1.png`, `p8-rutas-ISP2.png`, `p8-rutas-bgp-EDGE.png`, `config-ospf-default-EDGE.png` |

| P9 | Salida a Internet | Que los hosts lleguen a 1.1.1.1 y a 2.2.2.2 | Bien. PC-USER sale por DIST-1 → CORE-1 → EDGE → ISP-1. SRV sale por DIST-2 → CORE-2 → EDGE → ISP-2 | `capturas/f3/p9-internet-PC-USER.png`, `p9-internet-SRV.png` |

| P10 | Que el firewall no rompa nada | OSPF en Full, BGP establecido y los hosts saliendo | Bien | `capturas/f3/p10-firewall-sesiones-F3-EDGE.png`, `p10-firewall-F3-PC-USER.png`, `p10-firewall-stats-F3-EDGE.png` |

| P11 | Gestión protegida | Que un SSH desde ISP-1 hacia EDGE no conecte | Bien: no conectó, y el contador de la regla 7 pasó de 72 a 114 paquetes | `capturas/f3/p11-gestion-bloqueada-F3-ISP1.png` |

La configuración del firewall está en `capturas/f3/EDGE-F3-firewall.png` (las listas de interfaces y de gestión), `config-firewall-EDGE-F3-2.png` (reglas de input) y `config-firewall-EDGE-F3-3.png` (reglas de forward).

## 4.4 Configuración y backup

Las configuraciones están en `configs/ISP-1.rsc`, `configs/ISP-2.rsc` y `configs/EDGE.rsc`. EDGE quedó con su versión final (OSPF, BGP y firewall); las versiones anteriores se pueden ver en el historial de commits. Al terminar sacamos el snapshot `BASE-F3` en GNS3, y los exports de los siete routers están en `backups/post-F3/`.

## 4.5 Qué funcionó y qué no

**Lo que funcionó:**

- Las dos sesiones BGP levantaron con TCP-MD5. Si la clave no coincide, la sesión directamente no levanta.

- El filtro hace que hacia afuera salgan solo las LAN, y la ruta por defecto llega a toda la red por OSPF.

- El firewall no cortó OSPF, BGP ni la salida de los hosts, y bloquea la administración desde los ISP.

**Lo que no funcionó y cómo lo resolvimos:**

- En RouterOS 7.21 no se puede poner el `router-id` dentro de la conexión BGP: nos dio error. Hubo que crear primero una instancia BGP con el AS y el router-id (`/routing bgp instance add ...`) y después asociar la conexión a esa instancia.

- En ISP-1 la instancia nos quedó duplicada. Al borrar la copia, sin darnos cuenta borramos la que usaba la conexión, y la sesión con EDGE no levantaba. Revisando con `connection print` vimos que apuntaba a una instancia que ya no existía (`instance=*2`). Lo arreglamos con `set a-EDGE instance=bgp-isp1`.

- Las reglas de BGP del firewall (la 3 y la 4) quedaron con 0 paquetes. Tiene sentido: las sesiones ya estaban levantadas antes de poner el firewall, así que su tráfico entra por la regla de respuestas. Esas reglas se van a usar cuando un ISP tenga que volver a abrir la sesión, y lo vamos a probar en los drills de F4.

**Resultado:** salida a Internet por los dos proveedores con BGP autenticado, y el borde protegido por el firewall.

# 5. F4 — Drills, monitoreo y verificación de seguridad

## 5.1 Cómo organizamos la fase

Ejecutamos los cinco drills sobre el proyecto GNS3 de la PC de Pilar, el mismo que usamos desde la corrección de F1. Siguiendo la consigna, en esta fase rotamos los roles R1 y R2: Tomás operó EDGE y Martina operó los ISP. Cada drill tiene su runbook en `runbooks/` con la secuencia detección → respuesta → recuperación, el tiempo medido y el post-mortem.

Antes de empezar sacamos el snapshot `BASE-F4` en GNS3. Como CORE, DIST y EDGE no habían cambiado desde F3, usamos los exports de `backups/post-F3/` como backup previo a los drills.

**Cómo medimos.** Dejamos un ping continuo desde el host (`ping -t` en el VPCS) mientras provocábamos la falla y contamos los paquetes perdidos: cada `timeout` equivale a un segundo aproximado de corte. Para saber cuándo detectó la falla cada router usamos los logs. Los routers tienen el reloj en UTC, tres horas más que la hora de Argentina; los tiempos que informamos son diferencias entre líneas del mismo log, así que no los afecta.

**Cómo provocamos las fallas.** Para la caída de un router usamos Stop sobre el nodo. Para la caída de un enlace, Suspend sobre el cable en GNS3.

## 5.2 Drill 1 — VRRP: se cae el gateway

Apagamos DIST-1, master del grupo de USERS, con un ping continuo desde PC-USER hacia Internet.

| Detección | Respuesta | Recuperación | Tiempo medido |

|---|---|---|---|

| DIST-2 deja de recibir los anuncios de DIST-1 y se declara master de vrid 10 (`master down timer`, 02:44:19) | DIST-2 atiende las dos LAN. PC-USER sigue usando la misma MAC virtual (00:00:5e:00:01:0a) | Al volver DIST-1, primero forma OSPF (02:52:52) y después recupera el gateway por prioridad (02:52:58) | 14 pings perdidos, ≈ 14 s |

**Post-mortem.** El failover funcionó porque los dos DIST comparten la IP y la MAC virtual, así que el cambio de router es transparente para el host. VRRP en sí detecta en unos 3,6 s, pero el corte que vio el host fue de 14 s; no coincide con el dead interval de OSPF (CORE-1 dio de baja a DIST-1 recién a las 02:44:54, cuando el ping ya había vuelto), así que no pudimos atribuir la diferencia a un solo factor. Queda como mejora registrar la hora exacta del corte para medir contra el log. El failback salió en el orden correcto: DIST-1 tuvo rutas antes de volver a atender a los hosts.

Durante el drill tuvimos dos incidentes con GNS3: el puerto de consola de DIST-1 (5012) quedó tomado por el servidor de GNS3 y, al cambiar el tipo de consola, el nodo se reinició dos veces más. En cada reinicio la red repitió el mismo failover y failback sin pérdida de configuración.

Runbook: `runbooks/drill-1-vrrp.md`. Capturas: `capturas/f4/d1-*.png`.

## 5.3 Drill 2 — OSPF: se corta el camino interno

Suspendimos el enlace EDGE↔CORE-1 con un ping continuo desde PC-USER.

| Detección | Respuesta | Recuperación | Tiempo medido |

|---|---|---|---|

| CORE-1 registra `ether1 link down` (03:40:44) y baja el vecino EDGE 2 s después. El netwatch de EDGE marca `CORE-1 DOWN` (03:40:49) | DIST-1 pasa a salir por CORE-2 (10.0.0.25) | Con Resume, la adyacencia EDGE↔CORE-1 vuelve a Full | 0 pings perdidos (un pico de 143 ms) |

**Post-mortem.** No se perdió ningún paquete por dos razones: el CHR detecta la caída del enlace al instante (las interfaces tienen `disable-running-check=no`), así que OSPF no esperó los 40 s del dead interval; y DIST-1 ya tenía un segundo camino de igual costo por CORE-2, gracias a que cada distribución está conectada a los dos núcleos. Después del Resume el tráfico siguió por CORE-2: con dos caminos de igual costo no hay uno principal al que volver. Si la falla hubiera sido un router colgado sin caída de enlace, la detección habría dependido del dead interval; bajar los timers o usar BFD lo acortaría.

Runbook: `runbooks/drill-2-ospf.md`. Capturas: `capturas/f4/d2-*.png`.

## 5.4 Drill 5 — Load-sharing VRRP: ambos DIST activos

Verificamos el estado normal de operación desde los dos hosts.

| Host | Gateway que usa | Camino |

|---|---|---|

| PC-USER | 192.168.10.2 — DIST-1 (master de vrid 10) | DIST-1 → CORE-1 → EDGE |

| SRV | 192.168.20.3 — DIST-2 (master de vrid 20) | DIST-2 → CORE-2 → EDGE |

DIST-1 quedó con vrrp10 en master (prioridad 150) y vrrp20 en backup, y DIST-2 al revés.

**Post-mortem.** Con las prioridades cruzadas, los dos DIST llevan tráfico al mismo tiempo y cada uno es el respaldo del otro, así que no hay un router ocioso. El reparto es por LAN completa: si una LAN tuviera mucho más tráfico que la otra, quedaría desbalanceado.

Runbook: `runbooks/drill-5-load-sharing.md`. Capturas: `capturas/f4/d5-*.png`.

## 5.5 Verificación de seguridad — OSPF con clave incorrecta

En DIST-2 cambiamos la clave MD5 del template de OSPF por una incorrecta:

```

/routing ospf interface-template set [find auth=md5] auth-key=claveINCORRECTA

```

| Qué esperábamos | Qué obtuvimos | Evidencia |

|---|---|---|

| Que los CORE descarten los hellos de DIST-2 y la adyacencia se caiga | Al vencer el dead interval, los vecinos 5.5.5.5 (15:46:21) y 4.4.4.4 (15:46:23) pasaron de Full a Down y `neighbor print` quedó vacío | `capturas/f4/seg-01-ospf-clave-mala-DIST2.png` |

| Que SERVERS pierda la salida, porque su gateway queda sin rutas | Desde SRV, `ping 8.8.8.8` recibe `Destination network unreachable` de 192.168.20.3 (DIST-2) | `capturas/f4/seg-01b-impacto-SRV.png` |

| Que todo vuelva al restaurar la clave | Los dos vecinos volvieron a Full | `capturas/f4/seg-02-ospf-restaurado-DIST2.png` |

**Conclusión.** Con la clave incorrecta la adyacencia **falla**: un router que no conoce la clave no puede formar vecindad ni inyectar rutas. La prueba también muestra el costo operativo: un error de tipeo en la clave deja aislada una LAN entera, así que cualquier cambio de claves tiene que ir con su plan de reversión en el change log.

## 5.6 Drill 4 — check-gateway: failover estático de enlace

En EDGE agregamos dos rutas por defecto estáticas con `check-gateway=ping`: una primaria hacia ISP-1 (distance 1) y una de respaldo hacia ISP-2 (distance 2). Con esas distancias le ganan a las rutas de BGP (distance 20), así que durante el drill el failover dependió solo de las estáticas. Después suspendimos el enlace EDGE↔ISP-1 con un ping continuo desde PC-USER hacia 8.8.8.8.

| Detección | Respuesta | Recuperación | Tiempo medido |

|---|---|---|---|

| El netwatch de EDGE marca `ISP-1 DOWN` (13:42:11). La estática a 10.0.0.1 pasa a inactiva | La estática a 10.0.0.5 queda activa y el tráfico sale por ISP-2 | Con Resume, la primaria vuelve a quedar activa (`ISP-1 UP`, 13:49:19). Al final quitamos las estáticas y EDGE volvió a BGP | 0 pings perdidos, tanto en el corte como en la vuelta |

**Post-mortem.** El failover funcionó porque RouterOS activa la ruta de menor distancia que tenga el gateway disponible. Como el enlace se cayó físicamente, la ruta primaria se desactivó al instante, antes de que `check-gateway` llegara a fallar. El aporte real de `check-gateway=ping` es el caso en que el enlace sigue arriba pero el gateway no responde: ahí lo detecta con dos pings fallidos, unos 10 a 20 s. Comparado con BGP es mucho más simple, pero solo verifica el próximo salto y no le avisa al proveedor por dónde volver. En este laboratorio la vuelta igual la resolvió BGP.

Runbook: `runbooks/drill-4-check-gateway.md`. Capturas: `capturas/f4/d4-*.png`.

## 5.7 Verificación de seguridad — BGP con TCP-MD5 incorrecto

En EDGE cambiamos la clave TCP-MD5 de la sesión con ISP-2 por una incorrecta:

```

/routing bgp connection set [find name=a-ISP2] tcp-md5-key=claveINCORRECTA

```

| Qué esperábamos | Qué obtuvimos | Evidencia |

|---|---|---|

| Que la sesión con ISP-2 no pueda establecerse | La sesión a-ISP2-1 pasó a Idle (16:16:06), quedó sin la marca E y con 0 prefijos, y no volvió a levantar | `capturas/f4/seg-03-bgp-clave-mala-EDGE.png` |

| Que la sesión con ISP-1 no se vea afectada | a-ISP1-1 siguió establecida y la salida a Internet no se cortó | `capturas/f4/seg-03-bgp-clave-mala-EDGE.png` |

| Que todo vuelva al restaurar la clave | a-ISP2-1 volvió a Established (16:18:10) | `capturas/f4/seg-04-bgp-restaurado-EDGE.png` |

**Conclusión.** Con la clave incorrecta la sesión **falla**: ISP-2 descarta los segmentos TCP firmados con otra clave, así que no se puede armar la sesión ni inyectar rutas. Como cada proveedor tiene su propia clave, el problema quedó limitado a una sola sesión y la otra siguió funcionando.

## 5.8 Monitoreo en EDGE

En EDGE, además del SNMP que configuramos en los siete routers (ver 5.9), agregamos:

- **Regla de firewall** `F4 SNMP desde gestion`: acepta UDP 161 solo desde la lista GESTION (192.168.10.0/24). Va justo antes de la regla que descarta todo lo demás; si no, el firewall de F3 bloqueaba las consultas SNMP.

- **Chequeos con netwatch** hacia los próximos saltos de los dos ISP y de los dos CORE, cada 5 s con 1 s de timeout. Cada cambio de estado deja una línea en el log (`NETWATCH <equipo> DOWN` / `UP`).

| Host vigilado | Equipo |

|---|---|

| 10.0.0.1 | ISP-1 |

| 10.0.0.5 | ISP-2 |

| 10.0.0.10 | CORE-1 |

| 10.0.0.14 | CORE-2 |

Los netwatch fueron la primera señal de detección en los drills 2, 3 y 4: registraron cada caída y cada vuelta con la hora exacta, y esas líneas son las que usamos para medir los tiempos.

Capturas: `capturas/f4/mon-01-snmp-EDGE.png`, `mon-02-firewall-netwatch-EDGE.png`.

## 5.9 Monitoreo con SNMP

En los siete routers habilitamos SNMP versión 3 con estas decisiones:

| Parámetro | Valor | Por qué |

|---|---|---|

| Comunidad `public` | Deshabilitada | Es la que viene por defecto y la que cualquiera prueba primero |

| Usuario | `monitor-g7` | Uno solo, igual en todos los routers |

| Seguridad | `private` (autenticación SHA1 y cifrado AES) | SNMPv3 autentica y cifra; v1 y v2c mandan la comunidad en texto plano |

| Permisos | Solo lectura | El monitoreo no tiene por qué cambiar la configuración (mínimo privilegio, política 1.3) |

| Desde dónde | 192.168.10.0/24 (red de gestión) | La misma red desde la que se administra EDGE |

| Contacto y ubicación | `Grupo 7` / `GNS3 <router>` | Para identificar cada equipo desde el gestor |

Las claves de autenticación y cifrado no están en el repo: el `/export` las oculta.

Qué se puede monitorear con esto: el estado de las interfaces (enlaces arriba o abajo), los contadores de tráfico y errores, y el estado general de cada router. Los vecinos OSPF, las sesiones BGP y el estado de VRRP los seguimos con los logs y con los netwatch de EDGE (5.8), que son los que usamos como detección en los drills.

La configuración la verificamos en cada router con `/snmp print` y `/snmp community print`. No llegamos a hacer una consulta desde un gestor SNMP, porque los hosts del laboratorio son VPCS y no tienen cliente SNMP; queda como pendiente sumar un gestor (por ejemplo, un contenedor con `snmpwalk` o Zabbix) en la red de gestión.

Capturas: `capturas/f4/mon-03a` a `mon-03d` (CORE y DIST), `mon-04a-snmp-ISP1.png`, `mon-04b-snmp-ISP2.png`.

## 5.10 Drill 3 — BGP: se cae el proveedor

Para probar de verdad la ruta por defecto agregamos 8.8.8.8/32 en la loopback de los dos ISP como "destino de Internet". Esa dirección no se anuncia por BGP, así que los hosts solo llegan a ella por la default: con ISP-1 arriba responde ISP-1, y si se cae, responde ISP-2. Después suspendimos el enlace EDGE↔ISP-1 con un ping continuo desde PC-USER hacia 8.8.8.8.

| Detección | Respuesta | Recuperación | Tiempo medido |

|---|---|---|---|

| El netwatch de EDGE marca `ISP-1 DOWN` (13:27:01). La default por 10.0.0.1 queda inactiva. BGP recién baja la sesión al vencer el hold timer (13:29:33) | La default por ISP-2 queda activa. ISP-2 tiene las dos LAN por 10.0.0.6, así que devuelve el tráfico | Con Resume, la sesión con ISP-1 se restablece (13:35:19) y su default vuelve a ser la activa | 1 ping perdido (≈ 1 s) en el corte; 0 en la vuelta |

**Post-mortem.** El corte fue de un segundo porque la conmutación no la hizo BGP: al caer el enlace, la default aprendida de ISP-1 se quedó sin próximo salto alcanzable y RouterOS la desactivó en el momento. BGP siguió considerando viva la sesión 2 min 32 s más, hasta que venció el hold timer (3 min desde el último keepalive). Si la falla hubiera sido dentro del proveedor, con el enlace arriba, el corte habría durado hasta el hold timer. Para eso, la mejora es bajar el hold time y el keepalive, o usar BFD. La vuelta a ISP-1 fue automática y sin pérdidas.

Runbook: `runbooks/drill-3-bgp.md`. Capturas: `capturas/f4/d3-*.png`.

## 5.11 Resumen de los drills

| Drill | Falla provocada | Mecanismo que respondió | Tiempo de corte medido | ¿Cumplió? |

|---|---|---|---|---|

| 1 — VRRP | Cae DIST-1 (gateway de USERS) | VRRP: DIST-2 toma vrid 10 | ≈ 14 s (14 pings) | Sí |

| 2 — OSPF | Se corta EDGE↔CORE-1 | OSPF: DIST-1 sale por CORE-2 | 0 s | Sí |

| 3 — BGP | Se corta EDGE↔ISP-1 | Default de ISP-2 | ≈ 1 s (1 ping) | Sí |

| 4 — check-gateway | Se corta EDGE↔ISP-1 | Estática de respaldo (distance 2) | 0 s | Sí |

| 5 — Load-sharing | — (operación normal) | VRRP con masters cruzados | No aplica | Sí |

| Prueba de seguridad | Resultado |

|---|---|

| OSPF con clave incorrecta en DIST-2 | La adyacencia falla; SERVERS se queda sin salida hasta restaurar la clave |

| BGP con TCP-MD5 incorrecto en EDGE↔ISP-2 | La sesión no levanta; la sesión con ISP-1 sigue funcionando |

## 5.12 Configuración y backup

Las configuraciones finales están en `configs/` y los exports de los siete routers al terminar F4 en `backups/post-F4/`. Al cerrar la fase sacamos el snapshot `BASE-F4-FINAL` en GNS3. Respecto de F3, los cambios que quedan en la configuración son: SNMP en los siete routers, la regla de firewall para SNMP y los netwatch en EDGE, y la dirección 8.8.8.8 en la loopback de los ISP. Las rutas estáticas del drill 4 las quitamos al terminar.

## 5.13 Qué funcionó y qué no

**Lo que funcionó:**

- Los cinco drills cumplieron: en ninguna falla la red quedó sin salida, y la vuelta al estado normal fue automática en todos los casos.

- La detección por caída de enlace hizo que OSPF y la ruta por defecto conmutaran en segundos, sin esperar los timers de los protocolos.

- Las dos pruebas de seguridad dieron el resultado esperado: con una clave incorrecta, ni OSPF ni BGP aceptan al vecino.

- Los netwatch dieron la hora exacta de cada caída y cada vuelta, y fueron la base para medir los tiempos.

**Lo que no funcionó y cómo lo resolvimos:**

- Al preparar F4 encontramos que los exports de ISP-1 e ISP-2 de F3 no incluían la configuración BGP: se habían exportado antes de configurarla. Los volvimos a exportar y corregimos `configs/` y `backups/post-F3/`.

- Al configurar SNMP, la línea con las claves quedó a la vista en tres capturas. Las rehicimos limpiando la pantalla antes de verificar (Ctrl+L) y no usamos las originales.

- GNS3 no pudo abrir la consola de DIST-1 porque el puerto seguía tomado. Lo resolvimos cambiando el tipo de consola con el nodo detenido. En el medio, cerrar la ventana de consola alternativa apagó el nodo; la red hizo failover y no se perdió configuración.

- La PC donde corre el laboratorio se reinició dos veces en medio de la prueba de seguridad de OSPF. Como la configuración se guarda en el disco de cada router, al volver a arrancar el estado era el mismo y seguimos desde el paso en que estábamos.

- En el drill 1 el corte medido (14 s) fue mayor que el tiempo teórico de VRRP y no pudimos explicar la diferencia con los datos que teníamos. Queda como mejora registrar la hora exacta en que se provoca la falla.

**Mejoras que surgen de los drills:**

- Bajar los timers de OSPF y BGP, o usar BFD, para detectar en segundos las fallas que no tiran el enlace.

- Definir la preferencia por ISP-1 con local-preference en lugar de depender del desempate de BGP.

- Sumar un gestor SNMP real en la red de gestión.

**Resultado:** la red sobrevive a la caída de un gateway, de un camino interno y de un proveedor; el monitoreo detecta cada falla, y la autenticación del plano de control rechaza a vecinos con clave incorrecta.
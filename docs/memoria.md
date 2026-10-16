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


## F1 — Topología, configuración inicial y seguridad

Se implementó en GNS3 la topología del laboratorio Failover Routing, compuesta por siete routers MikroTik CHR, dos switches Ethernet y dos hosts VPCS.

Se configuraron las direcciones IP de los enlaces punto a punto, las redes USERS y SERVERS y las interfaces loopback de los routers.

Se establecieron contraseñas de administración, se creó un usuario de monitoreo con permisos de lectura y se deshabilitaron los servicios FTP, Telnet, WWW, API y API-SSL.

Se verificó mediante pruebas de ping la conectividad entre routers vecinos y entre los hosts y sus routers de distribución, obteniendo respuestas satisfactorias.

Se creó el snapshot BASE-F1 en GNS3 y se almacenaron siete exports de configuración RouterOS en el directorio `backups/` del repositorio.

**Resultado:** configuración inicial y pruebas de conectividad de F1 completadas.

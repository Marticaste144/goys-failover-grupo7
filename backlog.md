# Backlog — Laboratorio Failover Routing

**Grupo:** 7  
**Integrantes:** Martina Castellani, Tomás Terruli, Pilar Giannelli  
**Vencimiento final:** viernes 23/10/2026

> El Grupo 7 está conformado por 3 integrantes. Debido a que la consigna
> define 5 roles, las responsabilidades de R1 a R5 se distribuyen entre
> los integrantes del grupo.

## Leyenda de estado

- `[ ]` pendiente
- `[~]` en curso
- `[x]` hecho
- "Hecho" significa que se cumplió el criterio de aceptación correspondiente.

---

## Epic F0 — Diseño y gestión de cambio
**Vencimiento: viernes 2/10**

### IPAM / direccionamiento
- [ ] [R1/R3/R4] Diseñar el direccionamiento de todos los enlaces
- [ ] [R4] Definir las redes LAN USERS y SERVERS
- [ ] [R4] Definir los gateways virtuales VRRP
- [ ] [R3] Definir los router-ids
- [ ] [R5] Verificar que no existan subredes solapadas

### Corrección del diagrama
- [ ] [R1] Identificar los defectos del diseño original
- [ ] [R3/R4] Documentar las correcciones aplicadas
- [ ] [R5] Justificar al menos tres correcciones

### Política de seguridad
- [ ] [R1] Definir usuarios y privilegios
- [ ] [R2] Definir los servicios que se deshabilitarán
- [ ] [R1/R3/R4] Definir autenticación para BGP, OSPF y VRRP

### Política de operación
- [ ] [R5] Definir el formato del change log
- [ ] [R5] Definir la política de backups

### Repositorio Git
- [x] Crear el repositorio del Grupo 7
- [x] Crear README e identificar integrantes y roles
- [ ] Crear la estructura de carpetas requerida
- [ ] Completar la documentación correspondiente a F0

---

## Epic F1 — Topología + hardening + backup
**Vencimiento: viernes 9/10**

### Despliegue
- [ ] Levantar 7 routers CHR
- [ ] Incorporar 2 switches
- [ ] Incorporar 2 hosts
- [ ] Cablear los nodos según el diseño aprobado

### IPs de enlace + loopbacks
- [ ] Configurar las IPs definidas en F0
- [ ] Configurar loopbacks
- [ ] Verificar conectividad entre vecinos directos

### Snapshot BASE
- [ ] Crear snapshot BASE
- [ ] Documentar el snapshot

### Hardening
- [ ] Configurar contraseña de administrador
- [ ] Crear usuario de monitoreo
- [ ] Deshabilitar servicios innecesarios en los 7 routers

### Backup inicial
- [ ] Realizar `/export` de cada router
- [ ] Guardar los exports en el repositorio

---

## Epic F2 — VRRP + OSPF
**Vencimiento: viernes 16/10**

### VRRP
- [ ] [R4] Configurar VRRP vrid 10 en DIST-1 como master
- [ ] [R4] Configurar VRRP vrid 20 en DIST-2 como master
- [ ] [R4] Configurar autenticación de VRRP
- [ ] [R5] Verificar funcionamiento master/backup

### OSPF área 0
- [ ] [R3] Configurar OSPF en CORE-1 y CORE-2
- [ ] Configurar OSPF entre EDGE, CORE y DIST
- [ ] [R3] Incluir el enlace CORE-1 ↔ CORE-2
- [ ] Configurar autenticación OSPF
- [ ] Verificar adyacencias FULL

### Verificación L3
- [ ] Verificar ping intra-LAN
- [ ] Verificar respuesta de los gateways virtuales

---

## Epic F3 — BGP + firewall
**Vencimiento: viernes 16/10**

### eBGP multi-homing
- [ ] [R1/R2] Configurar sesión EDGE ↔ ISP-1
- [ ] [R1/R2] Configurar sesión EDGE ↔ ISP-2
- [ ] Configurar autenticación BGP
- [ ] Verificar ambas sesiones established

### Redistribución
- [ ] Configurar redistribución OSPF → BGP
- [ ] Verificar anuncio de las LAN hacia los ISP

### Salida a Internet
- [ ] Verificar conectividad desde host hasta loopback de ISP

### Firewall edge
- [ ] Configurar filtro de entrada
- [ ] Proteger el plano de gestión
- [ ] Verificar funcionamiento de las reglas

---

## Epic F4 — Drills + monitoreo
**Vencimiento: martes 20/10**

### Drills de failover
- [ ] Ejecutar los 5 drills de failover
- [ ] Medir tiempos de recuperación
- [ ] Crear un runbook por drill
- [ ] Documentar el post-mortem de cada prueba

### Monitoreo
- [ ] Habilitar SNMP/chequeos
- [ ] Documentar el monitoreo

### Verificación de seguridad
- [ ] Probar una clave de autenticación incorrecta
- [ ] Documentar que la adyacencia/sesión falla correctamente

---

## Epic F5 — Memoria + defensa
**Vencimiento: viernes 23/10**

### Memoria
- [ ] Completar todas las secciones de la memoria
- [ ] Incorporar evidencias y capturas

### Backlog
- [ ] Verificar que todas las tareas estén terminadas
- [ ] Cerrar el backlog

### Defensa oral
- [ ] Cada integrante prepara su parte
- [ ] Cada integrante prepara al menos una parte ajena

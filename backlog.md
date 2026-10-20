Backlog — Laboratorio Failover Routing
Grupo: 7
Integrantes: Martina Castellani, Tomás Terruli, Pilar Giannelli
Vencimiento final: viernes 23/10/2026
El Grupo 7 está conformado por 3 integrantes. Debido a que la consigna define 5 roles, las responsabilidades de R1 a R5 se distribuyen entre los integrantes del grupo.

Leyenda de estado
- [ ] pendiente
- [~] en curso
- [x] hecho
- "Hecho" significa que se cumplió el criterio de aceptación correspondiente.
Epic F0 — Diseño y gestión de cambio
Vencimiento: viernes 2/10
IPAM / direccionamiento
- [x] [R1/R3/R4] Diseñar el direccionamiento de todos los enlaces
- [x] [R4] Definir las redes LAN USERS y SERVERS
- [x] [R4] Definir los gateways virtuales VRRP
- [x] [R3] Definir los router-ids
- [x] [R5] Verificar que no existan subredes solapadas
Corrección del diagrama
- [x] [R1] Identificar los defectos del diseño original
- [x] [R3/R4] Documentar las correcciones aplicadas
- [x] [R5] Justificar al menos tres correcciones
Política de seguridad
- [x] [R1] Definir usuarios y privilegios
- [x] [R2] Definir los servicios que se deshabilitarán
- [x] [R1/R3/R4] Definir autenticación para BGP, OSPF y VRRP
Política de operación
- [x] [R5] Definir el formato del change log
- [x] [R5] Definir la política de backups
Repositorio Git
- [x] Crear el repositorio del Grupo 7
- [x] Crear README e identificar integrantes y roles
- [x] Crear la estructura de carpetas requerida
- [x] Completar la documentación correspondiente a F0
Epic F1 — Topología + hardening + backup
Vencimiento: viernes 9/10
Despliegue
- [x] Levantar 7 routers CHR
- [x] Incorporar 2 switches
- [x] Incorporar 2 hosts
- [x] Cablear los nodos según el diseño aprobado
IPs de enlace + loopbacks
- [x] Configurar las IPs definidas en F0
- [x] Configurar loopbacks
- [x] Verificar conectividad entre vecinos directos
Snapshot BASE
- [x] Crear snapshot BASE
- [x] Documentar el snapshot
Hardening
- [x] Configurar contraseña de administrador
- [x] Crear usuario de monitoreo
- [x] Deshabilitar servicios innecesarios en los 7 routers
Backup inicial
- [x] Realizar /export de cada router
- [x] Guardar los exports en el repositorio
Corrección F1 (devolución del profesor, 16/10)
- [x] [R1/R5] Organizar y numerar las capturas de F1 en capturas/f1/ (34f6337, 356ea45)
- [x] [R3/R4] Probar el restore de F1 en los 7 routers desde backups/*-F1.rsc
- [x] [R1/R5] Evidenciar el restore de EDGE y de los hosts (a7d48c9)
- [x] [R2] Evidenciar el restore y hardening de ISP-1 e ISP-2 (97a88ea)
- [x] [R3/R4] Evidenciar el restore de CORE-1, CORE-2, DIST-1 y DIST-2 (42d78a8)
- [x] [R2] Completar el change log con los commits reales (a393e2e)
- [x] [R3/R4] Estructurar la memoria F1 con tablas de verificación y restore (87c4c26)
- [x] Crear snapshot BASE-F1-RESTAURADO en GNS3
Epic F2 — VRRP + OSPF
Vencimiento: viernes 16/10
VRRP
- [x] [R4] Configurar VRRP vrid 10 en DIST-1 como master
- [x] [R4] Configurar VRRP vrid 20 en DIST-2 como master
- [x] [R4] Configurar autenticación de VRRP
- [x] [R5] Verificar funcionamiento master/backup
OSPF área 0
- [x] [R3] Configurar OSPF en CORE-1 y CORE-2
- [x] Configurar OSPF entre EDGE, CORE y DIST
- [x] [R3] Incluir el enlace CORE-1 ↔ CORE-2
- [x] Configurar autenticación OSPF
- [x] Verificar adyacencias FULL
Verificación L3
- [x] Verificar ping intra-LAN
- [x] Verificar respuesta de los gateways virtuales
Epic F3 — BGP + firewall
Vencimiento: viernes 16/10
eBGP multi-homing
- [x] [R1/R2] Configurar sesión EDGE ↔ ISP-1
- [x] [R1/R2] Configurar sesión EDGE ↔ ISP-2
- [x] Configurar autenticación BGP
- [x] Verificar ambas sesiones established
Redistribución
- [x] Configurar redistribución OSPF → BGP
- [x] Verificar anuncio de las LAN hacia los ISP
Salida a Internet
- [x] Verificar conectividad desde host hasta loopback de ISP
Firewall edge
- [x] Configurar filtro de entrada
- [x] Proteger el plano de gestión
- [x] Verificar funcionamiento de las reglas
Backups y evidencias F2/F3
- [x] Snapshots BASE-F2 y BASE-F3 en GNS3
- [x] Exports en configs/ y backups en backups/post-F2/ y backups/post-F3/
- [x] Capturas en capturas/f2/ y capturas/f3/
- [x] Memoria de F2 y F3 y change log actualizados
Epic F4 — Drills + monitoreo
Vencimiento: martes 20/10
Drills de failover
- [x] Ejecutar los 5 drills de failover
- [x] Medir tiempos de recuperación
- [x] Crear un runbook por drill
- [x] Documentar el post-mortem de cada prueba
Monitoreo
- [x] Habilitar SNMP/chequeos
- [x] Documentar el monitoreo
Verificación de seguridad
- [x] Probar una clave de autenticación incorrecta
- [x] Documentar que la adyacencia/sesión falla correctamente
Epic F5 — Memoria + defensa
Vencimiento: viernes 23/10
Memoria
- [ ] Completar todas las secciones de la memoria
- [ ] Incorporar evidencias y capturas
Backlog
- [ ] Verificar que todas las tareas estén terminadas
- [ ] Cerrar el backlog
Defensa oral
- [ ] Cada integrante prepara su parte
- [ ] Cada integrante prepara al menos una parte ajena
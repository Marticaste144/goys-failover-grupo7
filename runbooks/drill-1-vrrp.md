# Runbook — Drill 1: VRRP, se cae el gateway de USERS

**Mecanismo:** redundancia de primer salto (VRRP, RFC 5798)
**Responsable:** Pilar Giannelli (R4 — Distribución)
**Fecha de ejecución:** 20/10/2026
**Horas:** las del log de los routers (UTC, tres horas más que la hora de Argentina)

## Objetivo

Comprobar que, si se cae DIST-1 (master del grupo vrid 10), DIST-2 toma la IP virtual 192.168.10.1 y los hosts de USERS siguen saliendo sin cambiar nada en su configuración.

## Estado esperado antes del drill

| Dónde | Comando | Qué tiene que verse |
|---|---|---|
| DIST-1 | `/interface vrrp print` | vrrp10 en RM (prioridad 150), vrrp20 en B |
| DIST-2 | `/interface vrrp print` | vrrp10 en B (prioridad 100), vrrp20 en RM |
| PC-USER | `ping 1.1.1.1` | Responde |

## Disparo de la falla

En GNS3: clic derecho sobre DIST-1 → **Stop**.

## Detección

- **Síntoma en el host:** el ping continuo desde PC-USER (`ping 1.1.1.1 -t`) empieza a dar `timeout`.
- **En DIST-2:** `/log print where topics~"vrrp"` muestra `vrrp10 now MASTER, master down timer`.
- **En los CORE:** `/log print where topics~"ospf"` muestra el vecino 6.6.6.6 pasando de Full a Down por `timeout`.

## Respuesta

La red responde sola: DIST-2 deja de recibir los anuncios de DIST-1, vence el *master down timer* y se declara master de vrid 10. El operador solo verifica:

1. En DIST-2: `/interface vrrp print` → vrrp10 y vrrp20 en RM.
2. En PC-USER: `show arp` → 192.168.10.1 sigue con la MAC virtual `00:00:5e:00:01:0a`. El host no se entera de que cambió el router.
3. En PC-USER: el ping vuelve a responder.

## Recuperación

1. En GNS3: clic derecho sobre DIST-1 → **Start**.
2. Esperar a que DIST-1 arranque y forme OSPF con los dos CORE.
3. DIST-1 recupera vrid 10 por preemption (prioridad 150 > 100).
4. Verificar:
   - DIST-2: `/log print where topics~"vrrp"` → `vrrp10 now BACKUP, got higher priority 150 from 192.168.10.2`.
   - DIST-2: `/interface vrrp print` → vrrp10 en B.
   - PC-USER: `ping 1.1.1.1 -c 5` → 5 respuestas.

## Criterio de éxito

El gateway virtual sigue respondiendo con la falla y vuelve a DIST-1 cuando se recupera, sin tocar los hosts.

## Resultado

| Dato | Valor |
|---|---|
| Pings perdidos en PC-USER | 14 (icmp_seq 32 a 45) |
| **Tiempo de corte medido** | **≈ 14 s** |
| DIST-2 pasa a master de vrid 10 | 02:44:19 |
| CORE-1 da por caído a DIST-1 (OSPF) | 02:44:54 |
| MAC del gateway en PC-USER durante la falla | 00:00:5e:00:01:0a (sin cambios) |
| Failback (DIST-1 retoma vrid 10) | 02:52:58 |
| OSPF CORE-1↔DIST-1 de nuevo en Full | 02:52:52 |

## Post-mortem

**Qué pasó.** Al apagar DIST-1, DIST-2 tomó el gateway de USERS y PC-USER volvió a salir sin cambiar nada. Medimos 14 pings perdidos.

**Por qué funcionó.** Los dos DIST comparten la IP virtual y la MAC virtual del grupo 10. Como el host apunta a esa IP y esa MAC, el cambio de router le resulta transparente. DIST-2, que estaba escuchando los anuncios de DIST-1, se promovió cuando dejaron de llegar.

**Lo que no cierra del todo.** VRRP declara caído al master en unos 3,6 s (tres anuncios de 1 s más el *skew time*), pero el corte que vio el host fue de 14 s. No es el dead interval de OSPF completo, porque CORE-1 recién dio de baja a DIST-1 a las 02:44:54, después de que el ping ya había vuelto. Nuestra hipótesis es que parte de la diferencia está en el camino de vuelta del tráfico: los CORE siguen viendo a DIST-1 como vecino durante un tiempo, y en el apagado desde GNS3 no queda claro en qué segundo exacto se cortó el nodo. Para medirlo mejor habría que registrar la hora exacta del Stop.

**El failback salió en buen orden.** DIST-1 primero formó OSPF con los CORE (02:52:52) y recién después recuperó el gateway (02:52:58). Si hubiera retomado el gateway antes de tener rutas, los hosts se habrían quedado sin salida unos segundos.

**Incidentes durante el drill.**
- Al volver a arrancar DIST-1, GNS3 no pudo abrir su consola porque el puerto 5012 seguía tomado por el servidor de GNS3. El router arrancó igual. Lo resolvimos cambiando el tipo de consola con el nodo detenido, para que GNS3 le asignara otro puerto.
- En ese proceso DIST-1 se reinició dos veces más. En cada reinicio la red repitió el mismo failover y failback, lo que confirma que el mecanismo es estable.

**Mejoras.**
- Anotar la hora exacta en que se provoca la falla para medir el tiempo de detección contra el log.
- Evaluar `preemption-delay` en DIST-1, para que espere unos segundos antes de recuperar el gateway después de arrancar.

## Evidencia

`capturas/f4/`: `d1-01-antes-vrrp-DIST2.png`, `d1-02a-ping-inicio-PC-USER.png`, `d1-02b-ping-corte-arp-PC-USER.png`, `d1-03-failover-vrrp-DIST2.png`, `d1-03b-ospf-CORE1.png`, `d1-04a-failback-vrrp-DIST2.png`, `d1-04b-failback-ping-PC-USER.png`, `d1-05-error-consola-DIST1.png`.

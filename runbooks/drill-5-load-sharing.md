# Runbook — Drill 5: Load-sharing VRRP, los dos DIST activos

**Mecanismo:** dos grupos VRRP con masters cruzados
**Responsable:** Pilar Giannelli (R4 — Distribución)
**Fecha de ejecución:** 20/10/2026

## Objetivo

Comprobar que las dos distribuciones trabajan al mismo tiempo: DIST-1 atiende USERS y DIST-2 atiende SERVERS, y cada una es respaldo de la otra.

## Disparo

No se provoca ninguna falla. Es una verificación del estado normal de operación.

## Detección (cómo se verifica)

| Dónde | Comando | Qué tiene que verse |
|---|---|---|
| DIST-1 | `/interface vrrp print` | vrrp10 en RM (prioridad 150), vrrp20 en B (100) |
| DIST-2 | `/interface vrrp print` | vrrp10 en B (100), vrrp20 en RM (prioridad 150) |
| PC-USER | `trace 1.1.1.1` | Primer salto 192.168.10.2 (DIST-1) |
| SRV | `trace 1.1.1.1` | Primer salto 192.168.20.3 (DIST-2) |

## Respuesta

Si alguno de los dos DIST no es master de su grupo:

1. Revisar las prioridades con `/interface vrrp print`.
2. Revisar que la autenticación coincida en los dos DIST. Si no coincide, cada uno se cree master y quedan dos masters.
3. Revisar los logs con `/log print where topics~"vrrp"`.

## Recuperación

No aplica: es el estado normal. Si se cae un DIST, el otro toma los dos grupos (drill 1). Cuando el DIST caído vuelve, cada grupo regresa a su master por preemption.

## Resultado

| Host | Primer salto | Segundo salto | Sale por |
|---|---|---|---|
| PC-USER (USERS) | 192.168.10.2 — DIST-1 | 10.0.0.21 — CORE-1 | EDGE → ISP-1 |
| SRV (SERVERS) | 192.168.20.3 — DIST-2 | 10.0.0.33 — CORE-2 | EDGE → ISP-1 |

| Router | vrrp10 (USERS) | vrrp20 (SERVERS) |
|---|---|---|
| DIST-1 | RM, prioridad 150 | B, prioridad 100 |
| DIST-2 | B, prioridad 100 | RM, prioridad 150 |

## Post-mortem

**Qué pasó.** Con la red en operación normal, cada LAN sale por una distribución distinta y además por un CORE distinto.

**Por qué funcionó.** Al cruzar las prioridades, cada DIST es master de un grupo y backup del otro. Así no hay un router ocioso esperando una falla: los dos llevan tráfico y los dos están listos para tomar el grupo del otro.

**Qué aprendimos.** El load-sharing de VRRP no reparte el tráfico de una misma LAN entre dos routers; reparte LAN completas. Si una LAN tuviera mucho más tráfico que la otra, el reparto quedaría desbalanceado.

**Incidente.** Al cerrar la ventana QEMU de DIST-1 (con la consola en `none`), GNS3 apagó el nodo. La red hizo un failover más hacia DIST-2 y volvió sola cuando arrancamos DIST-1 con la consola en telnet. No se perdió configuración.

## Evidencia

`capturas/f4/`: `d5-01-trace-PC-USER.png`, `d5-02-trace-SRV.png`, `d5-03a-vrrp-DIST1.png`, `d5-03b-vrrp-DIST2.png`.

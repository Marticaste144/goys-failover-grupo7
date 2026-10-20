# Runbook — Drill 2: OSPF, se corta un camino interno

**Mecanismo:** reconvergencia del IGP (OSPF, RFC 2328)
**Responsable:** Pilar Giannelli (R3 — Core)
**Fecha de ejecución:** 20/10/2026
**Horas:** las del log de los routers (UTC)

## Objetivo

Comprobar que, si se corta el enlace EDGE↔CORE-1, OSPF recalcula y el tráfico de USERS sigue saliendo por otro camino sin intervención.

## Estado esperado antes del drill

| Dónde | Comando | Qué tiene que verse |
|---|---|---|
| EDGE | `/routing ospf neighbor print` | 4.4.4.4 (ether3) y 5.5.5.5 (ether4) en Full |
| PC-USER | `trace 1.1.1.1` | DIST-1 → CORE-1 (10.0.0.21) → EDGE |

## Disparo de la falla

En GNS3: clic derecho sobre el enlace EDGE↔CORE-1 → **Suspend**.

## Detección

- **Netwatch en EDGE:** `/log print where message~"NETWATCH"` → `NETWATCH CORE-1 DOWN`.
- **En CORE-1:** `/log print where message~"ether1"` → `ether1 link down` y el vecino 3.3.3.3 pasando de Full a Down.
- **En EDGE:** `/routing ospf neighbor print` → queda un solo vecino (5.5.5.5).

## Respuesta

La red responde sola: CORE-1 detecta que se cayó el enlace, baja la adyacencia con EDGE y OSPF recalcula las rutas. El operador verifica:

1. En PC-USER: el ping continuo no se corta.
2. En PC-USER: `trace 1.1.1.1` → el tráfico ahora va por CORE-2.

## Recuperación

1. En GNS3: clic derecho sobre el enlace EDGE↔CORE-1 → **Resume**.
2. Esperar unos 15 s.
3. Verificar:
   - EDGE: `/routing ospf neighbor print` → los dos vecinos en Full.
   - PC-USER: `trace 1.1.1.1` → llega a 1.1.1.1.

## Criterio de éxito

El tráfico de USERS sigue saliendo con el enlace cortado y la adyacencia vuelve a Full cuando se repone.

## Resultado

| Dato | Valor |
|---|---|
| Pings perdidos en PC-USER | 0 (icmp_seq 148 a 194 sin cortes) |
| **Tiempo de corte medido** | **0 s** (un solo pico de 143 ms en icmp_seq 153) |
| CORE-1 detecta la caída del enlace | 03:40:44 (`ether1 link down`) |
| CORE-1 baja el vecino 3.3.3.3 | 03:40:46 (2 s después) |
| Netwatch de EDGE registra la caída | 03:40:49 |
| Camino durante la falla | DIST-1 → 10.0.0.25 (CORE-2) → 10.0.0.13 (EDGE) |
| Adyacencia EDGE↔CORE-1 tras el Resume | Full |

## Post-mortem

**Qué pasó.** Cortamos el enlace EDGE↔CORE-1 con tráfico en curso y el ping no perdió ningún paquete. Solo hubo un pico de latencia de 143 ms, que coincide con el momento en que la red cambió de camino.

**Por qué funcionó.**
- La detección fue por pérdida de enlace, no por el dead interval. Las interfaces tienen `disable-running-check=no`, así que el CHR se entera al instante de que el enlace se cayó, y OSPF bajó la adyacencia en 2 s en vez de esperar 40.
- DIST-1 tiene dos caminos de igual costo hacia afuera: uno por CORE-1 y otro por CORE-2. Al caer el enlace de CORE-1 con EDGE, DIST-1 pasó a usar directamente el de CORE-2. Ni siquiera hizo falta usar el enlace core–core.

**Qué aprendimos.**
- El diseño de malla entre distribución y core es lo que da la redundancia: cada DIST está conectado a los dos CORE.
- Después del Resume el tráfico siguió saliendo por CORE-2 y no volvió a CORE-1. No es un error. Con dos caminos de igual costo (ECMP), los dos son válidos y no hay "camino principal" al que volver.
- Si la falla hubiera sido un router colgado sin caída de enlace, la detección habría dependido del dead interval (40 s). Lo vimos en el drill 1, donde CORE-1 tardó en dar por caído a DIST-1.

**Mejoras.** Para fallas sin caída de enlace, bajar los timers de hello y dead, o usar BFD, haría que OSPF detecte en menos de un segundo.

## Evidencia

`capturas/f4/`: `d2-01-antes-ospf-EDGE.png`, `d2-02-ping-sin-corte-PC-USER.png`, `d2-02b-topologia-suspendida.png`, `d2-03-deteccion-EDGE.png`, `d2-03b-trace-reconvergido-PC-USER.png`, `d2-03c-log-CORE1.png`, `d2-04a-recuperado-ospf-EDGE.png`, `d2-04b-recuperado-trace-PC-USER.png`.

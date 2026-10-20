# Runbook — Drill 4: check-gateway, failover estático de enlace

**Mecanismo:** rutas estáticas con `check-gateway=ping` y `distance`
**Responsable:** Tomás Terruli (R1 — Edge-WAN, rotación de F4)
**Fecha de ejecución:** 20/10/2026
**Horas:** las del log de los routers (UTC)

## Objetivo

Comprobar el failover más simple, sin protocolo de ruteo: dos rutas por defecto estáticas, una primaria hacia ISP-1 y otra de respaldo hacia ISP-2, donde el router vigila cada gateway con ping.

## Preparación (en EDGE)

```
/ip route add dst-address=0.0.0.0/0 gateway=10.0.0.1 check-gateway=ping distance=1 comment="F4 drill4 primaria ISP-1"
/ip route add dst-address=0.0.0.0/0 gateway=10.0.0.5 check-gateway=ping distance=2 comment="F4 drill4 backup ISP-2"
```

Con distance 1 y 2, las dos estáticas le ganan a las rutas de BGP (distance 20). Durante el drill manda solo el mecanismo estático, y BGP queda como estaba.

## Estado esperado antes del drill

| Dónde | Comando | Qué tiene que verse |
|---|---|---|
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | Estática a 10.0.0.1 en As (distance 1), estática a 10.0.0.5 en s (distance 2), BGP inactivas |
| PC-USER | `ping 8.8.8.8` | Responde |

## Disparo de la falla

En GNS3: clic derecho sobre el enlace EDGE↔ISP-1 → **Suspend**.

## Detección

- **Netwatch en EDGE:** `/log print where message~"NETWATCH ISP"` → `NETWATCH ISP-1 DOWN`.
- **En EDGE:** `/ip route print where dst-address=0.0.0.0/0` → la estática a 10.0.0.1 pasa a Is (inactiva) y la de 10.0.0.5 pasa a As (activa).

## Respuesta

La red responde sola. El operador verifica en PC-USER que el ping a 8.8.8.8 siga respondiendo.

## Recuperación

1. En GNS3: clic derecho sobre el enlace EDGE↔ISP-1 → **Resume**.
2. Verificar en EDGE:
   - `/ip route print where dst-address=0.0.0.0/0` → la estática a 10.0.0.1 vuelve a As.
   - `/log print where message~"NETWATCH ISP"` → `NETWATCH ISP-1 UP`.
3. Al terminar el drill, quitar las estáticas para volver a la configuración con BGP:
   ```
   /ip route remove [find comment~"F4 drill4"]
   ```
4. Verificar que queden solo las dos defaults de BGP, con la de 10.0.0.1 en DAb.

## Criterio de éxito

Con la primaria caída, la ruta de respaldo toma el tráfico; con la primaria repuesta, el tráfico vuelve a ella. Al final, la configuración queda como antes del drill.

## Resultado

| Dato | Valor |
|---|---|
| Pings perdidos en PC-USER al caer el enlace | 0 (icmp_seq 1 a 46 sin cortes) |
| **Tiempo de corte medido** | **0 s** |
| Netwatch registra la caída | 13:42:11 |
| Pings perdidos en el failback | 0 |
| Netwatch registra la vuelta | 13:49:19 |
| Estáticas quitadas al final | Sí; quedan las dos defaults BGP con 10.0.0.1 activa |

## Post-mortem

**Qué pasó.** Al cortar el enlace con ISP-1, la ruta de respaldo tomó el tráfico sin perder pings, y al reponerlo el tráfico volvió a la primaria también sin pérdidas.

**Por qué funcionó.** RouterOS elige la ruta activa por distancia: con la primaria disponible gana la de distance 1. Cuando el gateway 10.0.0.1 deja de ser alcanzable, la ruta queda inactiva y pasa a usarse la de distance 2.

**Qué aprendimos.**
- En este drill el enlace se cayó físicamente, así que la ruta se desactivó en el instante por falta de enlace, antes de que `check-gateway` llegara a fallar. El aporte real de `check-gateway=ping` es para el caso en que el enlace sigue arriba pero el gateway no responde: ahí detecta la falla después de dos pings fallidos, unos 10 a 20 s.
- Comparado con BGP (drill 3), es más simple y no depende de que el proveedor hable BGP, pero solo verifica el próximo salto. No se entera si el problema está más adentro del proveedor, ni le dice al proveedor por dónde volver: el retorno igual lo resuelve BGP en este laboratorio.
- Es el "failover más barato y más olvidado" del que se habló en clase: dos líneas de configuración.

**Mejora.** Si se usara como respaldo real, convendría vigilar una dirección más allá del gateway (por ejemplo, con netwatch o rutas recursivas) para detectar fallas del proveedor y no solo del enlace.

## Evidencia

`capturas/f4/`: `d4-01-rutas-estaticas-EDGE.png`, `d4-02-ping-corte-PC-USER.png`, `d4-02b-topologia-suspendida.png`, `d4-03-failover-EDGE.png`, `d4-04a-ping-failback-PC-USER.png`, `d4-04b-failback-EDGE.png`, `d4-05-estaticas-removidas-EDGE.png`.

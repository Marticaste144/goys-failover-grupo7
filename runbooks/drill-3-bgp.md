# Runbook — Drill 3: BGP, se cae el proveedor

**Mecanismo:** BGP multi-homing (eBGP con dos proveedores, RFC 4271)
**Responsable:** Martina Castellani (R2 — Proveedores, rotación de F4)
**Fecha de ejecución:** 20/10/2026
**Horas:** las del log de los routers (UTC)

## Objetivo

Comprobar que, si se cae ISP-1, la salida a Internet pasa sola a ISP-2 y vuelve a ISP-1 cuando se recupera.

## Preparación

Para probar la ruta por defecto (y no una ruta específica), en los dos ISP agregamos la misma dirección como "destino de Internet":

```
/ip address add address=8.8.8.8/32 interface=loopback comment="F4 destino Internet simulado"
```

Esa dirección no se anuncia por BGP (la lista `anuncio-isp` solo tiene la loopback propia de cada ISP), así que los hosts llegan a ella únicamente por la ruta por defecto. Con ISP-1 arriba responde ISP-1, y si ISP-1 se cae tiene que responder ISP-2.

## Estado esperado antes del drill

| Dónde | Comando | Qué tiene que verse |
|---|---|---|
| EDGE | `/routing bgp session print` | a-ISP1-1 y a-ISP2-1 con E (established) |
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | DAb por 10.0.0.1 (activa) y D b por 10.0.0.5 (respaldo) |
| PC-USER | `ping 8.8.8.8` | Responde |

## Disparo de la falla

En GNS3: clic derecho sobre el enlace EDGE↔ISP-1 → **Suspend**.

## Detección

- **Netwatch en EDGE:** `/log print where message~"NETWATCH ISP"` → `NETWATCH ISP-1 DOWN`.
- **En EDGE:** `/ip route print where dst-address=0.0.0.0/0` → la default por 10.0.0.1 pasa a inactiva (DIb) y la de 10.0.0.5 pasa a activa (DAb).
- **En EDGE, más tarde:** `/log print where topics~"bgp"` → `HoldTimer expired a-ISP1-1` y la sesión pasa a Idle.

## Respuesta

La red responde sola. El operador verifica:

1. En PC-USER: el ping a 8.8.8.8 vuelve a responder (ahora contesta ISP-2).
2. En ISP-2: `/ip route print where dst-address~"192.168"` → tiene las dos LAN por 10.0.0.6, así que puede devolver el tráfico.
3. En EDGE: después del hold timer, `/routing bgp session print` → solo a-ISP2-1 con E.

## Recuperación

1. En GNS3: clic derecho sobre el enlace EDGE↔ISP-1 → **Resume**.
2. Esperar alrededor de 1 minuto a que BGP vuelva a armar la sesión.
3. Verificar en EDGE:
   - `/routing bgp session print` → las dos sesiones con E.
   - `/ip route print where dst-address=0.0.0.0/0` → la default activa vuelve a ser la de 10.0.0.1.
   - `/log print where message~"NETWATCH ISP" or topics~"bgp"` → `NETWATCH ISP-1 UP` y `a-ISP1-1 ... Established`.

## Criterio de éxito

La salida a Internet pasa a ISP-2 durante la falla y vuelve a ISP-1 cuando se recupera, sin tocar la configuración.

## Resultado

| Dato | Valor |
|---|---|
| Pings perdidos en PC-USER al caer ISP-1 | 1 (icmp_seq 14) |
| **Tiempo de corte medido** | **≈ 1 s** |
| Netwatch registra la caída | 13:27:01 |
| BGP da de baja la sesión (hold timer) | 13:29:33 (2 min 32 s después) |
| Pings perdidos en la recuperación | 0 |
| Sesión con ISP-1 restablecida | 13:35:19 (mismo segundo que `NETWATCH ISP-1 UP`) |

## Post-mortem

**Qué pasó.** Al cortar el enlace con ISP-1 se perdió un solo ping y el tráfico siguió por ISP-2. Al reponer el enlace, la sesión se restableció y la salida volvió a ISP-1 sin perder paquetes.

**Por qué el corte fue de 1 s y no de 3 minutos.** La conmutación no la hizo BGP. Al caer el enlace, la ruta por defecto aprendida de ISP-1 se quedó sin forma de llegar a su próximo salto (10.0.0.1) y RouterOS la desactivó en el momento, así que pasó a usar la de ISP-2. BGP, en cambio, siguió creyendo que la sesión estaba viva hasta que venció el hold timer, 2 min 32 s después (el hold time es de 3 min y empieza a contar desde el último keepalive recibido).

**Qué aprendimos.**
- BGP tarda en detectar una falla. Es lo que se vio en clase: el hold timer es largo a propósito, porque BGP prioriza la estabilidad entre sistemas autónomos.
- Si la falla hubiera sido dentro del proveedor, con el enlace físico arriba, la ruta no se habría desactivado y el corte habría durado hasta que venza el hold timer: unos 3 minutos.
- El failback es automático. Las dos defaults tienen los mismos atributos y gana la de ISP-1 por desempate (tiene el router-id más bajo), así que en cuanto vuelve la sesión, vuelve a ser la activa.

**Mejoras.**
- Bajar el hold time y el keepalive de las sesiones (por ejemplo, 30 s y 10 s), o usar BFD, para detectar fallas del proveedor sin caída de enlace.
- Definir la preferencia por ISP-1 de forma explícita (local-preference) en lugar de depender del desempate.

## Evidencia

`capturas/f4/`: `d3-01-antes-bgp-EDGE.png`, `d3-01b-antes-trace-PC-USER.png`, `d3-02-ping-corte-PC-USER.png`, `d3-03-failover-bgp-EDGE.png`, `d3-03b-sesion-caida-EDGE.png`, `d3-03c-rutas-LAN-ISP2.png`, `d3-04a-ping-recuperacion-PC-USER.png`, `d3-04b-recuperado-bgp-EDGE.png`.

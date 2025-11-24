# INFORME 9 - Enrique Sopeña Urbano

## Pregunta 1

Tras ejecutar los comandos establecidos en el laboratorio, el resultado por consola fue el siguiente:

```bash
Active Timestamp: 1
Channel: 22
Wake-up Channel: 25
Channel Mask: 0x07fff800
Ext PAN ID: 247bfd9d68d2890f
Mesh Local Prefix: fdd7:2a41:82b:9429::/64
Network Key: c54fa0f215fc2fa1b7cb41bb5014eb80
Network Name: OpenThread-a4a3
PAN ID: 0xa4a3
PSKc: a673753b6feee322aae612bc53488caf
Security Policy: 672 onrc 0
Done
```

De estos datos se obtiene el `Network Key,` el `Network Name` y el `PAN ID`:

| **Parámetro** | **Valor**                        |
| ------------- | -------------------------------- |
| Network Key   | c54fa0f215fc2fa1b7cb41bb5014eb80 |
| Network Name  | OpenThread-a4a3                  |
| PAN ID        | 0xa4a3                           |

## Pregunta 2

La dirección **link-local** es aquella utilizada para la comunicación dentro del mismo segmento de red local (en este caso, el mismo enlace inalámbrico 802.15.4) y **comienza con** `fe80`.

- **Dirección Link-Local:**
  ```bash
  fe80:0:0:0:70b4:4313:c061:78eb
  ```

## Pregunta 3

El **Endpoint Identifier (EID)** es la dirección **Mesh-Local** (que comienza con `fd`) utilizada para identificar al dispositivo final. Se distingue por **no contener la secuencia** `ff:fe00` en el identificador de interfaz.

- **Endpoint Identifier (EID)**
  ```bash
  fdd7:2a41:82b:9429:b59e:808e:751d:ef55
  ```

(Nota: Las otras direcciones `fdd7:2a41:82b:9429:0:ff:fe00:fc00` y `fdd7:2a41:82b:9429:0:ff:fe00:4800` son direcciones RLOC —Router Locator—, también Mesh-Local, utilizadas para el _routing_ dentro de la red Thread.)

## Pregunta 4

La latencia del _ping_ se determina a partir del tiempo de ida y vuelta (**Round-trip Time** o RTT) medido durante la transmisión de paquetes ICMP entre el Nodo 2 y el Nodo 1.

Basado en la salida obtenida de la prueba de _ping_ realizada desde el Nodo 2 hacia el **Endpoint Identifier (EID)** del Nodo 1 (`fdd7:2a41:82b:9429:b59e:808e:751d:ef55`), la latencia registrada es:

- **Latencia Mínima / Promedio / Máxima (RTT):**
  ```bash
  > ping fdd7:2a41:82b:9429:b59e:808e:751d:ef55
  16 bytes from fdd7:2a41:82b:9429:b59e:808e:751d:ef55: icmp_seq=1 hlim=64 time=6ms
  1 packets transmitted, 1 packets received. Packet loss = 0.0%. Round-trip min/avg/max = 6/6.000/6 ms.
  Done
  ```

El valor del **tiempo de ida y vuelta** para el paquete ICMP exitoso fue de **6 ms**.

## Pregunta 5

La prueba de autenticación se ejecutó correctamente configurando el Nodo 1 como Commissioner y el Nodo 2 como Joiner con la credencial `J01NME`. Posteriormente, se verificó la conectividad de capa superior (TCP).

## Mensaje de Confirmación de Autenticación

El mensaje clave obtenido en el Nodo 2 que confirma la finalización exitosa del proceso de autenticación con el Commissioner y la recepción de las credenciales de red Thread es:

```bash
Join success
```

Simultáneamente, el Nodo 1 (Commissioner) registra la secuencia de eventos de autenticación:

```bash
Commissioner: Joiner start d65e64fa83f81cf7
Commissioner: Joiner connect d65e64fa83f81cf7
Commissioner: Joiner finalize d65e64fa83f81cf7
Commissioner: Joiner end d65e64fa83f81cf7
```

### Prueba de Conexión TCP

Para realizar la prueba de conexión TCP, fue necesario obtener la nueva dirección Link-Local (`fe80`) del Nodo 1, dado que el comando `factoryreset` previo reinició la interfaz de red IPv6 del dispositivo.

La nueva dirección Link-Local del Nodo 1, obtenida tras la inicialización del Thread, es:

```bash
fe80:0:0:0:8862:dcfe:5d7d:2d0c
```

El Nodo 1 se configuró para escuchar en el puerto `30000`:

```bash
> tcp init
Done
> tcp listen :: 30000
Done
```

y el Nodo 2 intentó conectarse utilizando la nueva dirección Link-Local del Leader.

```bash
> tcp init
Done
> tcp connect fe80:0:0:0:8862:dcfe:5d7d:2d0c 30000
Done
> TCP: Connection established
tcp send hello
Done
```

El Nodo 1 confirmó la recepción exitosa de la conexión y del mensaje de datos:

```bash
Accepted connection from [fe80:0:0:0:a8bf:9f88:9a2c:3d4f]:49152
TCP: Connection established
TCP: Received 5 bytes: hello
```

**Conclusión:** La recepción exitosa del mensaje "hello" en el Nodo 1 demuestra que, una vez corregida la dirección de destino y establecida la autenticación, la red Thread es capaz de enrutar correctamente el tráfico de capa superior (TCP) entre los dispositivos emulados.

### Ejecución completa en cada nodo

**Nodo 1:**

```bash
root@36141d756000:/# /openthread/build/examples/apps/cli/ot-cli-ftd 1
> dataset init new
Done
> dataset
Active Timestamp: 1
Channel: 23
Wake-up Channel: 15
Channel Mask: 0x07fff800
Ext PAN ID: bac8d632725129b5
Mesh Local Prefix: fd85:b008:c1f7:e14::/64
Network Key: 79cdd6f8b3b1dd7d36d90b6ad88b9dfc
Network Name: OpenThread-b638
PAN ID: 0xb638
PSKc: f62a824d3b8844408621ae983df24052
Security Policy: 672 onrc 0
Done
> dataset commit active
Done
> ifconfig up
Done
> thread start
Done
> state
leader
Done
> commissioner start
Commissioner: petitioning
Done
> Commissioner: active
> commissioner joiner add * J01NME
Done
> Commissioner: Joiner start d65e64fa83f81cf7
Commissioner: Joiner connect d65e64fa83f81cf7
Commissioner: Joiner finalize d65e64fa83f81cf7
Commissioner: Joiner end d65e64fa83f81cf7
> ipaddr
fd85:b008:c1f7:e14:0:ff:fe00:fc30
fd85:b008:c1f7:e14:0:ff:fe00:fc00
fd85:b008:c1f7:e14:0:ff:fe00:4400
fd85:b008:c1f7:e14:92d:7cd1:a5f6:ccce
fe80:0:0:0:8862:dcfe:5d7d:2d0c
Done
> tcp init
Done
> tcp listen :: 30000
Done
> Commissioner: Joiner remove
Accepted connection from [fe80:0:0:0:a8bf:9f88:9a2c:3d4f]:49152
TCP: Connection established
TCP: Received 5 bytes: hello
```

**Nodo 2:**

```bash
root@36141d756000:/# /openthread/build/examples/apps/cli/ot-cli-ftd 2
> ifconfig up
Done
> joiner start J01NME
Done
> Join success
> thread start
Done
> tcp init
Done
> tcp connect fe80:0:0:0:8862:dcfe:5d7d:2d0c 30000
Done
> TCP: Connection established
tcp send hello
Done
```

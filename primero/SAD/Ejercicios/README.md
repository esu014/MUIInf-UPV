# Ejercicios

## [Tarea de Sincronización con NATS](./crsqlite-lab/)

### Objetivo

Este proyecto implementa un sistema de **sincronización entre peers** usando **Core NATS** (pub/sub) para propagar los cambios en los TODOs en tiempo real entre distintos **nodos** (peers) que mantienen una base de datos SQLite local. En lugar de usar REST para sincronización (`pull` y `push`), se utiliza NATS como mecanismo de comunicación entre los nodos.

### Enunciado

>[!NOTE]
> El ejemplo donde se muestra como propagar cr_sqlite con nodejs hace uso de un servidor de sincronización mediante http. 
>
>La presente tarea pide que se use Core NATS para propagar los cambios  que se producen en cada " peer" (copia de base de datos sqlite.
>
>Para ello, adaptar los peer del ejemplo de forma que reciban peticiones funcionales para afectar a los TODOs, pero no para sincronizar.
>
>Propón como debe funcionar la sincronización con NATS core, y provee una implementación en nodejs.
>
>Debes entregar en un zip/tgz el package ejecutable completo de nodejs que implementa lo que se pide. 
>
>Dentro de ese archivo incluye un breve documento que explica la intención del código en su uso de NATS.
>
>La entrega deba hacerse dentro de los limites temporales que se establecen en poliformat. Ninguna entrega será aceptada con posterioridad.

### Componentes Principales

1. **Peers**: 
   - Cada nodo tiene una base de datos SQLite y un servidor HTTP (con Express).
   - Los peers están configurados para **publicar los cambios locales** en un canal de NATS (`crsql.<room>.changes`).
   - También **se suscriben a este canal** para recibir los cambios de otros peers y aplicarlos en su base de datos.

2. **NATS**:
   - NATS se utiliza para la comunicación **reactiva** y **en tiempo real** entre los peers.
   - El mecanismo pub/sub garantiza que todos los peers reciban y apliquen los cambios sin necesidad de intervenciones manuales.

3. **Base de datos SQLite**:
   - Los TODOs se almacenan en una tabla SQLite. Los cambios (agregar o modificar TODOs) se replican entre los peers automáticamente a través de NATS.
   - La tabla `crsql_changes` gestiona la sincronización y la replicación de los datos.

### Funcionamiento del Sistema

1. **Publicación de cambios**:
   - Cuando un usuario agrega o modifica un TODO, el peer publica este cambio en el canal de NATS correspondiente.
   
2. **Suscripción a cambios**:
   - Los otros peers se suscriben a este canal de NATS. Cuando reciben nuevos cambios, los aplican a su propia base de datos SQLite.

3. **Prevención de bucles**:
   - Para evitar que los peers se "retroalimenten" con sus propios cambios, se verifica el campo `site_id` de cada mensaje para asegurarse de que no se repliquen los cambios del propio peer.

### Estructura del Proyecto

```
├── crsqlite-lab/
│   ├── crsqlite-examen.pdf
│   ├── package-lock.json
│   ├── package.json
│   ├── tsconfig.json
│   ├── tsconfig.json.b
│   ├── writeup.md
│   ├── src/
│      ├── db.ts         
│      ├── schema.ts     
│      ├── natsSync.ts   
│      ├── natsClient.ts 
│      ├── peer.ts       
│      ├── main.ts       
```
### Cómo Ejecutar el Proyecto
1. Instalar Dependencias
    ```bash
    npm install
    ```
2. Levantar el Servidor NATS
Si no tienes un servidor NATS corriendo, usa Docker para levantar uno:

    ```bash
    docker run -p 4222:4222 -p 8222:8222 nats:2
    ```
3. Ejecutar los Peers
Para arrancar los dos peers, ejecuta:
    ```bash
    npm run start:peerA
    npm run start:peerB
    ```
4. Probar la Sincronización
Agregar un TODO en el Peer A:
    ```bash
    curl -XPOST http://localhost:3001/add
    ```
5. Verificar los TODOs en ambos peers:

    ```bash
    curl http://localhost:3001/todos
    curl http://localhost:3002/todos
    ```
    Ambos peers deberían sincronizar los TODOs automáticamente.

### Cómo Funciona la Sincronización con NATS
- **Publicación**: Cuando un peer agrega o modifica un TODO, publica el cambio en un canal de NATS (crsql.<room>.changes).
- **Suscripción**: Los demás peers están suscritos a este canal. Cuando reciben un cambio, lo aplican en su base de datos local (crsql_changes).
- **Prevención de Retroalimentación**: El peer verifica que los cambios recibidos no sean de sí mismo (por el site_id) para evitar que se sincronice con su propio estado.

### Archivos Clave
- ``natsSync.ts``: Lógica que se encarga de publicar y suscribir a los cambios usando NATS.
- ``peer.ts``: Implementa los endpoints funcionales del peer, como agregar TODOs y obtener la lista de TODOs.
- ``natsClient.ts``: Cliente NATS reutilizable para facilitar la conexión y manejo de los mensajes NATS.


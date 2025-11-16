# INFORME 8- Enrique Sopeña Urbano

## Pregunta 1

El `Dockerfile` es el script que contiene una serie de instrucciones secuenciales necesarias para construir una imagen Docker funcional. Estas instrucciones definen el entorno base, las dependencias, la estructura de archivos y el proceso de ejecución de la aplicación Flask.

A continuación, se detalla el propósito de cada línea del fichero:

1. **`FROM alpine` :** Define la **imagen base** sobre la cual se construirá la nueva imagen. Se utiliza `alpine`, una distribución ligera de Linux (conocida por su pequeño tamaño), para mantener el tamaño final de la imagen al mínimo.
2. **`RUN apk update && apk add --no-cache python3 py3-pip` :** Ejecuta comandos dentro de la capa de construcción de la imagen.  **`apk update`** actualiza el índice de paquetes de Alpine. **`apk add --no-cache`** instala el intérprete **`python3`** y el gestor de paquetes **`py3-pip`**, optimizando el proceso al no almacenar la caché de paquetes.
3. **`RUN apk add py3-flask` :** Instala el *framework* **Flask** utilizando el gestor de paquetes de Alpine.
4. **`COPY app.py /usr/src/app/` :** Copia el archivo principal de la aplicación (`app.py`) desde el directorio local al contenedor, ubicándolo en la ruta `/usr/src/app/`.
5. **`COPY templates/index.html /usr/src/app/templates/` :** Copia el archivo de la plantilla HTML (`index.html`) del directorio local `templates/` a la ruta `/usr/src/app/templates/` dentro del contenedor. Esta estructura es necesaria para que Flask pueda localizar las plantillas.
6. **`EXPOSE 5000` :** Documenta el puerto de red (`5000`) que la aplicación Flask dentro del contenedor utilizará para escuchar las conexiones entrantes. Esta instrucción es informativa; el mapeo de puertos real se realiza al ejecutar el contenedor con el comando `docker run`.
7. **`CMD ["python3", "/usr/src/app/app.py"]` :** Define el comando y los argumentos que se ejecutarán cuando se inicie un contenedor a partir de esta imagen. Inicia la aplicación Flask ejecutando el script `/usr/src/app/app.py` con el intérprete `python3`. Esta instrucción debe ser el último comando del `Dockerfile`.

## Pregunta 2

La URL requerida para acceder a la aplicación web Flask desde el navegador de la máquina anfitriona (*Docker Host*) es: `http://localhost:8888`  o  la forma equivalente utilizando la dirección de *loopback*: `http://127.0.0.1:8888`.

La URL se establece mediante el mecanismo de **mapeo de puertos** definido en el comando `docker run`:

```bash
docker run -p 8888:5000 --name myfirstapp YOUR_USERNAME/myfirstapp
```

- `localhost` / `127.0.0.1`: Esta dirección identifica a la interfaz de red del *Docker Host*. El acceso debe dirigirse a la máquina anfitriona, ya que es la entidad que gestiona el reenvío del tráfico.
- `8888` (Puerto Externo): Este valor se corresponde con el puerto especificado antes de los dos puntos en el *flag* `p` (`*8888**:5000`). Este puerto se abre en la máquina anfitriona para recibir peticiones HTTP destinadas al contenedor.

No se utiliza la dirección IP interna del contenedor (ej., `172.17.0.2:5000`) porque esta subred es una red virtual privada a la que el navegador web del Host no tiene un acceso directo sin la regla de reenvío explícita del *Docker Daemon*.

## Pregunta 3

El nombre completo (*Fully Qualified Name*) de la imagen Docker en el registro público, tal como se confirma tras la operación exitosa de `docker push` a la plataforma Docker Hub, es `docker.io/esu014/myfirstapp:latest`.

## Pregunta 4

### Fichero Dockerfile

El `Dockerfile` define el entorno minimalista necesario para la ejecución del suscriptor. Se seleccionó la imagen base Alpine por su ligereza, optimizando el tamaño final del contenedor.

La construcción del entorno siguió los siguientes pasos esenciales, justificados por el requisito de la dependencia `paho-mqtt`:

1. Entorno Base e Instalación de Python: Se inició con la imagen `alpine:latest` y se instaló el intérprete Python (`python3`) y su gestor de paquetes (`py3-pip`) utilizando `apk add`.
2. Instalación de Dependencias: La librería `paho-mqtt` se instaló utilizando `pip install`. Para mitigar el error `externally-managed-environment` (PEP 668), se empleó el *flag* de anulación (`-break-system-packages`), una práctica común en entornos desechables como Docker para garantizar la instalación de librerías en el sistema base.
3. Configuración y Ejecución: Se estableció el directorio de trabajo (`WORKDIR /app`), se copió el *script* (`sisub.py`) y se definió el punto de entrada (`CMD`) para ejecutar el cliente MQTT al iniciar el contenedor.

Fragmento de Código del Dockerfile:

```docker
# Dockerfile
FROM alpine:latest
RUN apk update && \
    apk add --no-cache python3 py3-pip
RUN pip install paho-mqtt --break-system-packages
WORKDIR /app
COPY sisub.py /app/
CMD ["python3", "sisub.py"]
```

### Fichero Python del Subscriber (`sisub.py`)

El *script* implementa un cliente MQTT bajo la API de *Callbacks* V2 de `paho-mqtt`. Su función principal es establecer una conexión persistente con el *broker* y procesar los mensajes asíncronos.

Funcionalidad Central

- Conexión y Suscripción: El cliente se conecta al *broker* `broker.hivemq.com` en el puerto estándar 1883. Una vez establecida la conexión (`on_connect`), el cliente se suscribe al tópico comodín multinivel `test/#`, cumpliendo con la especificación de la actividad para recibir mensajes de cualquier sub-tópico bajo `test/`.
    
    ```python
    THE_BROKER = "broker.hivemq.com"
    THE_TOPIC = "test/#"
    
    def on_connect(client, userdata, flags, reason_code, properties):
        if reason_code == 0:
            print("Successfully connected to", client._host, "port:", client._port)
            client.subscribe(THE_TOPIC)
        else:
            print("Connection failed. Reason code:", reason_code)
    ```
    
- Gestión de Mensajes: La función `on_message` es la encargada de recibir y decodificar el *payload* de los mensajes entrantes, imprimiendo el tópico y el contenido para su visualización.
    
    ```python
    def on_message(client, userdata, msg):
        print(msg.topic, msg.qos, msg.payload.decode())
    ```
    
- Funcionamiento: Tras instanciar el cliente MQTT y asignar las funciones callback, se inicia la conexión al broker. La función `client.loop_forever()` es fundamental para el manejo asíncrono de eventos: escucha continuamente el socket de red y, cuando el broker envía una respuesta o un mensaje, activa inmediatamente las funciones callback asociadas (como `on_connect` y `on_message`). Esta arquitectura garantiza que el cliente permanezca siempre operativo, reaccionando a los eventos de red en tiempo real y procesando los mensajes del tópico test/# sin bloquear el hilo principal de ejecución.
    
    ```python
    def on_subscribe(client, userdata, mid, reason_codes, properties):
        print("Subscribed:", mid, reason_codes)
    
    if __name__ == "__main__":
        client = mqttc.Client(
            mqttc.CallbackAPIVersion.VERSION2,
            client_id="",
            clean_session=True,
            userdata=None,
            protocol=mqttc.MQTTv311,
            transport="tcp",
        )
    
        client.on_connect = on_connect
        client.on_message = on_message
        client.on_subscribe = on_subscribe
    
        client.username_pw_set(username=None, password=None)
        client.connect(THE_BROKER, port=1883, keepalive=60)
    
        client.loop_forever()
    ```
    

### Nombre de la Imagen Final

Tras la construcción exitosa, la imagen fue etiquetada y subida a Docker Hub. El nombre completo de la imagen en el registro es: `docker.io/esu014/thesub:latest`
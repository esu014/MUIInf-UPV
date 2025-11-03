# INFORME 4 - Enrique Sopeña Urbano


## Pregunta 1

En esta primera tarea se ha desarrollado un script en Python que permite enviar datos generados localmente a la plataforma **Ubidots** mediante el protocolo **MQTT**. El objetivo es simular un dispositivo IoT que transmite mediciones periódicas a la nube para su almacenamiento y análisis posterior.

Para ello, se creó una cuenta STEM gratuita en Ubidots, se añadió un dispositivo denominado `device_lab4` y dentro de él una variable tipo *Raw* llamada `variable_lab4`, encargada de recibir los valores publicados. El token de autenticación, obtenido desde la sección *API Credentials*, se utilizó como nombre de usuario en la conexión al broker MQTT `things.ubidots.com` (puerto 1883).

El script establece la conexión con el broker y ejecuta un bucle que genera valores aleatorios entre 0 y 100, los convierte a formato **JSON** y los publica en el tópico `/v1.6/devices/device_lab4`. El formato del mensaje enviado es:

```json
{"variable_lab4": 47}
```

Durante la ejecución, el programa publica un nuevo valor cada cinco segundos, mostrando por consola el estado de la conexión y los datos transmitidos. 

```bash
Conectado correctamente a things.ubidots.com
Enviado -> /v1.6/devices/device_lab4 : {"variable_lab4": 83}
Mensaje publicado (MID=2)
```

En Ubidots, los valores aparecen registrados correctamente en la variable correspondiente, confirmando el funcionamiento adecuado del envío de datos a la plataforma.

## Pregunta 2

En esta segunda tarea se ha creado un **dashboard en la plataforma Ubidots** para visualizar los datos enviados por el script desarrollado en la tarea anterior. Para ello, se añadieron tres widgets vinculados a la variable `variable_lab4` del dispositivo `device_lab4`.

![image.png](INFORME%204%20-%20Enrique%20Sope%C3%B1a%20Urbano/image.png)

El primero es una **tabla de datos** que muestra de forma cronológica todos los valores recibidos desde el publicador MQTT, permitiendo verificar la recepción continua de información.

El segundo es un **gráfico de líneas (Line Chart)** que representa la evolución de los valores a lo largo del tiempo, facilitando la interpretación de tendencias.

Por último, se añadió un **widget tipo métrica (Metrics)** que muestra el valor más reciente recibido por la plataforma, simulando el comportamiento de un sensor en tiempo real.

## Pregunta 3

En esta tercera tarea se ha desarrollado un programa en Python que recibe los datos publicados por **The Things Network (TTN)** y reenvía a **Ubidots** únicamente el valor correspondiente a la temperatura. Para ello, se utilizó el protocolo MQTT conectándose al broker de TTN (`eu1.cloud.thethings.network`) y al broker de Ubidots (`things.ubidots.com`).

El código procesa los mensajes entrantes de TTN en formato JSON, extrae las variables `temperature`, `humidity` y `lux`, y publica únicamente la temperatura en la variable `temperatura_lab4` del dispositivo creado específicamente para esta tarea. De este modo, se asegura que los datos de esta prueba quedan separados de los obtenidos en ejecuciones anteriores.

Durante la ejecución, el programa muestra por consola los valores recibidos desde TTN y confirma el envío correcto de la temperatura a Ubidots. 

```bash
Conectado correctamente a TTN: eu1.cloud.thethings.network
Conectado correctamente a Ubidots: things.ubidots.com
Suscrito al topic TTN: v3/+/devices/#
Mensaje recibido desde TTN: v3/lopys2ttn@ttn/devices/device01/up
@18:22:04 >> temp=22.53°C  hum=41.27%  lux=125.00 lx
🚀 Enviada temperatura a Ubidots -> /v1.6/devices/temperatura_lab4 : {"temperatura_lab4": 22.53}
```

En la plataforma, los datos pueden visualizarse en un nuevo *dashboard* compuesto por los mismos widgets utilizados anteriormente: una **tabla** que lista los valores recibidos, un **gráfico de líneas** que representa su evolución temporal, y un **widget métrico** que muestra el último valor disponible.

### Dashboard de resultados tras ejecución

La imagen incluida a continuación muestra claramente la actualización periódica de la variable `temperatura_lab4`, evidenciando la correcta comunicación entre TTN, el script en Python y la plataforma Ubidots.

![image.png](INFORME%204%20-%20Enrique%20Sope%C3%B1a%20Urbano/image%201.png)
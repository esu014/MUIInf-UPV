# INFORME 5 - Enrique Sopeña Urbano

---

## Pregunta 1

---

En esta primera parte se desarrolló un bot de **Telegram** conectado a **The Things Network (TTN)** mediante el protocolo **MQTT**. El bot se configuró utilizando el *Access Token* generado con BotFather y las credenciales de TTN para suscribirse al topic correspondiente. Una vez en ejecución, el bot respondió correctamente al comando `/getdata`, mostrando en Telegram el último valor de temperatura recibido desde TTN, validando así la comunicación entre el sistema de sensores y la interfaz del usuario.

![Captura de pantalla 2025-11-10 a las 13.34.49.png](INFORME%205%20-%20Enrique%20Sope%C3%B1a%20Urbano/Captura_de_pantalla_2025-11-10_a_las_13.34.49.png)

## Pregunta 2

---

En la segunda parte se amplió la funcionalidad del bot para que pudiera responder de forma independiente a solicitudes de **temperatura**, **humedad** y **luminosidad**. Se añadieron nuevos comandos (`/gettemp`, `/gethum` y `/getlux`) que permiten al usuario consultar los valores más recientes de cada variable directamente desde Telegram. 

![image.png](INFORME%205%20-%20Enrique%20Sope%C3%B1a%20Urbano/image.png)
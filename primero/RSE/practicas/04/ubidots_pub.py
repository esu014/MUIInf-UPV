"""
Publicador MQTT para enviar datos a Ubidots (STEM) usando paho-mqtt.
Envía valores aleatorios entre 0 y 100 a una variable del dispositivo indicado.
"""

import paho.mqtt.client as mqtt
import random
import json
import time

BROKER = "things.ubidots.com"
PORT = 1883
TOKEN = "---TU_TOKEN---"  
DEVICE_LABEL = "---DEVICE_LABEL---"                   
VARIABLE_LABEL = "---VARIABLE_LABEL---"

def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print(f"Conectado correctamente a {BROKER}")
    else:
        print(f"Error de conexión. Código: {reason_code}")

def on_publish(client, userdata, mid, reason_code, properties):
    print(f"Mensaje publicado (MID={mid})")

client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id="ubidots_publisher",
    clean_session=True,
    userdata=None,
    protocol=mqtt.MQTTv311
)

client.username_pw_set(TOKEN, password=None)
client.on_connect = on_connect
client.on_publish = on_publish

client.connect(BROKER, PORT, keepalive=60)
client.loop_start()

try:
    while True:
        valor = random.randint(0, 100)
        data = {VARIABLE_LABEL: valor}
        payload = json.dumps(data)
        topic = f"/v1.6/devices/{DEVICE_LABEL}"
        result = client.publish(topic, payload=payload, qos=0, retain=False)
        print(f" Enviado -> {topic} : {payload}")
        time.sleep(5)

except KeyboardInterrupt:
    print("\n Publicador detenido por el usuario.")
finally:
    client.loop_stop()
    client.disconnect()
    print(" Conexión cerrada.")

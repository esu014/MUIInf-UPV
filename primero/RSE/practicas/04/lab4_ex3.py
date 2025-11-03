"""
Lee datos desde TTN (The Things Network) y publica una variable seleccionada en Ubidots.
Basado en la plantilla proporcionada en el laboratorio.
"""

import time
import json
import paho.mqtt.client as mqtt

TTN_BROKER = "eu1.cloud.thethings.network"
TTN_USERNAME = "lopys2ttn@ttn"
TTN_PASSWORD = "NNSXS.A55Z2P4YCHH2RQ7ONQVXFCX2IPMPJQLXAPKQSWQ.A5AB4GALMW623GZMJEWNIVRQSMRMZF4CHDBTTEQYRAOFKBH35G2A"
TTN_TOPIC = "v3/+/devices/#"

UBI_BROKER = "things.ubidots.com"
TOKEN = "---TU_TOKEN---"  
DEVICE_LABEL = "---DEVICE_LABEL---"                   
VARIABLE_LABEL = "---VARIABLE_LABEL---"

def on_connectTTN(client, userdata, flags, reason_code, properties):
    """Callback al conectar con TTN"""
    if reason_code == 0:
        print(f"Conectado correctamente a TTN: {TTN_BROKER}")
        client.subscribe(TTN_TOPIC)
        print(f"Suscrito al topic TTN: {TTN_TOPIC}")
    else:
        print(f"Error de conexión a TTN. Código: {reason_code}")


def on_connectUBI(client, userdata, flags, reason_code, properties):
    """Callback al conectar con Ubidots"""
    if reason_code == 0:
        print(f"Conectado correctamente a Ubidots: {UBI_BROKER}")
    else:
        print(f"Error de conexión a Ubidots. Código: {reason_code}")


def on_messageTTN(client, userdata, msg):
    """Callback al recibir mensaje desde TTN"""
    print(f"\nMensaje recibido desde TTN: {msg.topic}")

    try:
        if "v3/lopys2ttn@ttn/devices/" in msg.topic and "/up" in msg.topic:
            themsg = json.loads(msg.payload.decode("utf-8"))
            dpayload = themsg["uplink_message"]["decoded_payload"]

            temp = dpayload.get("temperature", None)
            hum = dpayload.get("humidity", None)
            lux = dpayload.get("lux", None)

            print("@%s >> temp=%.2f°C  hum=%.2f%%  lux=%.2f lx" %
                  (time.strftime("%H:%M:%S"), temp, hum, lux))

            if temp is not None:
                ubi_payload = json.dumps({UBI_VARIABLE: temp})
                topic = f"/v1.6/devices/{UBI_DEVICE}"

                clientUBI.publish(topic, payload=ubi_payload, qos=0, retain=False)
                print(f"Enviada temperatura a Ubidots -> {topic} : {ubi_payload}")
    except Exception as e:
        print(f"Error procesando mensaje TTN: {e}")

clientTTN = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id="reader_ttn",
    clean_session=True,
    userdata=None,
    protocol=mqtt.MQTTv311,
    transport="tcp"
)
clientTTN.username_pw_set(TTN_USERNAME, password=TTN_PASSWORD)
clientTTN.on_connect = on_connectTTN
clientTTN.on_message = on_messageTTN

clientUBI = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id="sender_ubidots",
    clean_session=True,
    userdata=None,
    protocol=mqtt.MQTTv311,
    transport="tcp"
)
clientUBI.username_pw_set(UBI_TOKEN, password=None)
clientUBI.on_connect = on_connectUBI

print("Conectando a TTN y Ubidots...\n")
clientTTN.connect(TTN_BROKER, port=1883, keepalive=60)
clientUBI.connect(UBI_BROKER, port=1883, keepalive=60)

clientTTN.loop_forever()

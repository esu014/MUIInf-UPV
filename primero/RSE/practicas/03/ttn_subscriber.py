"""
TTN MQTT subscriber - listens to all messages from TTN Network Server
and prints the full JSON received.
"""

import paho.mqtt.client as mqtt
import json

BROKER = "eu1.cloud.thethings.network"
PORT = 1883
USERNAME = "lopys2ttn@ttn"
PASSWORD = "NNSXS.A55Z2P4YCHH2RQ7ONQVXFCX2IPMPJQLXAPKQSWQ.A5AB4GALMW623GZMJEWNIVRQSMRMZF4CHDBTTEQYRAOFKBH35G2A"
TOPIC = "v3/+/devices/#"  

def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print(f"✅ Connected to {BROKER}")
        client.subscribe(TOPIC)
        print(f"📡 Subscribed to topic: {TOPIC}")
    else:
        print(f"❌ Connection failed (code {reason_code})")

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
        print("\n📦 New message received:")
        print(json.dumps(payload, indent=2))
    except Exception:
        print("\n⚠️ Raw message received (non-JSON):")
        print(msg.payload.decode("utf-8"))

client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id="ttn_subscriber",
    clean_session=True,
    userdata=None,
    protocol=mqtt.MQTTv311
)

client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(USERNAME, PASSWORD)

client.connect(BROKER, PORT, keepalive=60)
client.loop_forever()

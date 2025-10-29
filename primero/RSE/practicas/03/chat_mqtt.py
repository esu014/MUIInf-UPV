"""
Simple MQTT chat application using paho-mqtt 2.x
All messages sent by any member are received by everyone in the same group.
"""

import paho.mqtt.client as mqtt
import threading

BROKER = "test.mosquitto.org"
PORT = 1883
GROUP_TOPIC = "upv/chat/grupo1"   

name = input("Enter your name: ")

def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print(f"✅ Connected to broker {BROKER}")
        client.subscribe(GROUP_TOPIC)
        print(f"📡 Subscribed to group: {GROUP_TOPIC}")
    else:
        print("❌ Connection failed, code:", reason_code)

def on_message(client, userdata, msg):
    try:
        text = msg.payload.decode()
        if not text.startswith(f"{name}:"):
            print(f"\n💬 {text}")
    except Exception as e:
        print("Error decoding message:", e)

client = mqtt.Client(
    mqtt.CallbackAPIVersion.VERSION2,
    client_id=f"{name}_chat",
    clean_session=True,
    userdata=None,
    protocol=mqtt.MQTTv311
)

client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER, PORT, keepalive=60)
client.loop_start()

def send_messages():
    try:
        while True:
            msg = input("> ")
            if msg.lower() in ("exit", "quit"):
                print("👋 Leaving chat...")
                break
            full_msg = f"{name}: {msg}"
            client.publish(GROUP_TOPIC, payload=full_msg, qos=0, retain=False)
    except KeyboardInterrupt:
        print("\n👋 Chat interrupted by user.")
    finally:
        client.loop_stop()
        client.disconnect()

send_messages()

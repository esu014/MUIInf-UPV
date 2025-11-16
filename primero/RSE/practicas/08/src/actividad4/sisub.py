"""MQTT subscriber using paho-mqtt 2.x and Callback API V2."""

import paho.mqtt.client as mqttc

THE_BROKER = "broker.hivemq.com"
THE_TOPIC = "test/#" 

def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        print("Successfully connected to", client._host, "port:", client._port)
        client.subscribe(THE_TOPIC)
    else:
        print("Connection failed. Reason code:", reason_code)

def on_message(client, userdata, msg):
    print(msg.topic, msg.qos, msg.payload.decode())

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
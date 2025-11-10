import argparse
import base64
import json
import logging
import signal
import struct
import sys
import time


from telegram.ext import Application
from telegram.ext import CommandHandler
from telegram.ext import MessageHandler
from telegram.ext import filters


import paho.mqtt.client as mqtt
from datetime import datetime, timezone

r_value = "VOID"

TELEGRAM_TOKEN = "----TOKEN generado por BotFather----"
TTN_USERNAME = "lopys2ttn@ttn"
TTN_PASSWORD = "NNSXS.A55Z2P4YCHH2RQ7ONQVXFCX2IPMPJQLXAPKQSWQ.A5AB4GALMW623GZMJEWNIVRQSMRMZF4CHDBTTEQYRAOFKBH35G2A"
TTN_BROKER = "eu1.cloud.thethings.network"
TTN_TOPIC = "v3/+/devices/#"

def on_connect(mqttc, obj, flags, reason_code, properties=None):
    print(f"Connected to {mqttc._host}:{mqttc._port}")
    print(f"Flags: {flags}")
    print(f"Reason Code: {reason_code}")
    print(f"Properties: {properties}")

    mqttc.subscribe("v3/+/devices/#", qos=0)

def on_message(client, userdata, msg):
    global r_value
#    print("msg received with topic: {} and payload: {}".format(msg.topic, str(msg.payload)))

    if ("v3/lopys2ttn@ttn/devices/" in msg.topic and "/up" in msg.topic):
        themsg = json.loads(msg.payload.decode("utf-8"))
        dpayload = themsg["uplink_message"]["decoded_payload"]
        print("@%s >> temp=%.3f hum=%.3f lux=%.3f" %
              (time.strftime("%H:%M:%S"), dpayload["temperature"],
               dpayload["humidity"], dpayload["lux"]))
        r_value = dpayload["temperature"]

async def start(update, context):
    options_text = ("👋 ¡Hola! I'm a Bot 🤖."
        "Please use one of the following:\n"
        "/start - See all available options 👀.\n"
        "/getdata - Get data 🌡️.\n"
    )
    await context.bot.send_message(chat_id=update.effective_chat.id, text=options_text)

async def getdata(update, context):
    await context.bot.send_message(chat_id=update.effective_chat.id,
                                   text=f"🌡️ Current temperature is: {r_value}°C")

async def unknown(update, context):
    options_text = (
        "💬 Sorry I dont understand this command. 😕\n\n"
        "Please use one of the following:\n"
        "/start - See all available options 👀.\n"
        "/getdata - Get data 🌡️.\n"
    )
    await context.bot.send_message(chat_id=update.effective_chat.id, text=options_text)

# setting up MQTT
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
client.on_connect = on_connect
client.on_message = on_message
client.username_pw_set(
    TTN_USERNAME,
    password=TTN_PASSWORD
)
client.connect(TTN_BROKER, port=1883, keepalive=60)
client.loop_start()

# bot configuration
application = Application.builder().token(TELEGRAM_TOKEN).build()

## commands handlers
start_handler = CommandHandler('start', start)
application.add_handler(start_handler)

getdata_handler = CommandHandler('getdata', getdata)
application.add_handler(getdata_handler)

unknown_handler = MessageHandler(filters.TEXT | (~filters.COMMAND), unknown)
application.add_handler(unknown_handler)

# starts bot
application.run_polling()


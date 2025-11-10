from influxdb import InfluxDBClient

""" 
Pongo 172.19.0.2 porque el código en python lo ejecuto en otro contenedor,
no en mi maquina local y es la ip que tiene el contenedor que corre influxdb 
en la red conjunta 
"""

client = InfluxDBClient(host='172.19.0.2', port=8086)
client.switch_database('telegraf')

results = client.query('select * from TTN WHERE time > now() - 15m')

points = results.get_points()
for item in points:
    if item['uplink_message_decoded_payload_temperature'] is not None:
        print(item['time'], " -> Temperatura:", item['uplink_message_decoded_payload_temperature'])

    if item['uplink_message_decoded_payload_humidity'] is not None:
        print(item['time'], " -> Humedad:", item['uplink_message_decoded_payload_humidity'])

    if item['uplink_message_decoded_payload_lux'] is not None:
        print(item['time'], " -> Luminosidad:", item['uplink_message_decoded_payload_lux'])

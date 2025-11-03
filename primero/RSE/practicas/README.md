# Laboratorio de Redes y Seguridad

Esta carpeta contiene los ejercicios realizados en el laboratorio para aprender sobre **Mininet** y **MQTT** en un entorno de red simulado. A lo largo del laboratorio, se abordaron conceptos fundamentales de redes, controladores SDN y la comunicación en tiempo real con MQTT.

>[!IMPORTANT] 
>### Requisitos Previos
>Antes de comenzar con las prácticas, debes **completar las configuraciones previas** descritas en los documentos proporcionados por el profesor. Estas instrucciones incluyen la descarga de herramientas, configuración del entorno y otros pasos importantes que debes seguir antes de realizar la **Práctica 1**.

## Prácticas Realizadas

### [1. Introducción a Mininet y Conceptos Básicos](./01/)

En esta primera práctica, se utilizó **Mininet** para crear una topología simple con 3 hosts y 1 switch. Se realizaron comandos básicos de Mininet, como **inspeccionar la red** y **verificar la conectividad** entre los dispositivos de la red utilizando `pingall`. También se exploraron los **puertos de los switches** utilizando OpenFlow y se configuraron las **características de la red**, como el **ancho de banda**, **retardo** y **pérdida de paquetes**.

### [2. Gestión Avanzada de Flujos y Topologías](./02/)

En esta práctica, se profundizó en la **gestión de flujos** dentro de un switch Open vSwitch (OVS) y cómo **controlar el tráfico** entre los hosts mediante **OpenFlow**. Se utilizaron herramientas como `ovs-ofctl` para agregar, eliminar y visualizar flujos en un switch. Además, se implementó un **firewall de capa 2** (L2) utilizando **Access Control Lists (ACL)** en **ONOS** para **bloquear el tráfico** entre ciertos hosts de la red.

### [3. Introducción a MQTT y Creación de una Aplicación de Chat Básica](./03)

En esta práctica, se aprendió el funcionamiento básico de **MQTT**, un protocolo de mensajería ligero utilizado en redes de dispositivos IoT. Se desarrollaron dos aplicaciones simples: un **publicador** que envía mensajes aleatorios a un tópico específico y un **suscriptor** que recibe dichos mensajes.  

Se experimentó con la opción **`retain`** para comprender la **persistencia de mensajes**, se implementó una aplicación de **chat** entre varios clientes y se analizó el comportamiento del protocolo al modificar los nombres de los tópicos, verificando su sensibilidad a mayúsculas y minúsculas.

### [4. Envío y Visualización de Datos en Ubidots](./04)

En esta práctica se integró **MQTT con la plataforma Ubidots**, simulando un dispositivo IoT que envía datos a la nube. Se desarrolló un script en Python que publica valores aleatorios en un dispositivo y variable creados en Ubidots, verificando su recepción en tiempo real.  

Posteriormente, se diseñó un **dashboard** para visualizar los datos mediante distintos widgets (tabla, gráfico de líneas y métrica). Finalmente, se implementó una integración con **The Things Network (TTN)** para leer los valores del sensor (temperatura, humedad y luz) y reenviar solo la temperatura a Ubidots, completando así la comunicación entre un nodo LoRaWAN y la nube.
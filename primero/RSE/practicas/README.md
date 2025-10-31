
# Laboratorio de Redes y Seguridad

Este repositorio contiene los ejercicios realizados en el laboratorio para aprender sobre **Mininet** y **MQTT** en un entorno de red simulado. A lo largo del laboratorio, se abordaron conceptos fundamentales de redes, controladores SDN, y la comunicación en tiempo real con MQTT.

## Prácticas Realizadas

### [1. Introducción a Mininet y Conceptos Básicos](./01/)

En esta primera práctica, se utilizó **Mininet** para crear una topología simple con 3 hosts y 1 switch. Se realizaron comandos básicos de Mininet, como **inspeccionar la red** y **verificar la conectividad** entre los dispositivos de la red utilizando `pingall`. También se exploraron los **puertos de los switches** utilizando OpenFlow y se configuraron las **características de la red**, como el **ancho de banda**, **retardo** y **pérdida de paquetes**.

### [2. Gestión Avanzada de Flujos y Topologías](./02/)

En esta práctica, se profundizó en la **gestión de flujos** dentro de un switch Open vSwitch (OVS) y cómo **controlar el tráfico** entre los hosts mediante **OpenFlow**. Se utilizaron herramientas como `ovs-ofctl` para agregar, eliminar y visualizar flujos en un switch. Además, se implementó un **firewall de capa 2** (L2) utilizando **Access Control Lists (ACL)** en **ONOS** para **bloquear el tráfico** entre ciertos hosts de la red.

### [3. Introducción a MQTT y Creación de una Aplicación de Chat Básica](./03)

En esta práctica, se aprendió el funcionamiento básico de **MQTT**, un protocolo de mensajería ligero utilizado en redes de dispositivos IoT. Se desarrollaron dos aplicaciones simples:
- **Un publicador** que envía mensajes aleatorios a un **topic** específico.

- **Un suscriptor** que recibe estos mensajes. 

Se experimentó con la opción **`retain`** para entender cómo funciona la **persistencia de mensajes** en MQTT, y se implementó una aplicación de **chat** en la que los mensajes enviados por un usuario son recibidos por todos los miembros del grupo suscritos a un mismo topic.

También se experimentó con el comportamiento de MQTT al **cambiar el nombre de los tópicos**. Se verificó cómo los **tópicos son sensibles a las mayúsculas y minúsculas** y se observó cómo los mensajes no son recibidos si los **tópicos no coinciden exactamente** entre el publicador y el suscriptor.

Se profundizó en el concepto de **mensajes retenidos** en MQTT. Se modificó el código de un publicador para que los mensajes enviados al broker quedaran retenidos, lo que permite a los nuevos suscriptores recibir el último mensaje publicado en un tópico, incluso si no estaban conectados en ese momento.

Se desarrolló una **aplicación de chat simple** utilizando **MQTT** donde los miembros de un grupo pueden enviar y recibir mensajes. Todos los mensajes enviados por un usuario son recibidos por todos los miembros suscritos al mismo tópico de chat. El chat funciona en un sistema de **publicador y suscriptor** y permite una comunicación asíncrona en tiempo real.

## Requisitos Previos

Antes de comenzar con las prácticas, debes **completar las configuraciones previas** descritas en los documentos proporcionados por el profesor. Estas instrucciones incluyen la descarga de herramientas, configuración del entorno y otros pasos importantes que debes seguir antes de realizar la **Práctica 1**.

## Conclusión

Este laboratorio proporciona una **visión completa de cómo interactuar con MQTT** y **Mininet**, explorando desde la **publicación y suscripción básica** hasta el manejo de flujos en **redes definidas por software** (SDN) con **OpenFlow** y **ONOS**. El uso de **MQTT** para aplicaciones simples de **chat** y **comunicación de datos** es fundamental para entender cómo funciona este protocolo en entornos reales.

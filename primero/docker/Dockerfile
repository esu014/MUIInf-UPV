# Imagen base: Ubuntu LTS
FROM ubuntu:22.04

# Evita prompts interactivos
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza e instala herramientas básicas del sistema
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    nano \
    vim \
    curl \
    wget \
    git \
    zip \
    unzip \
    tar \
    net-tools \
    iputils-ping \
    htop \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    jq \
    locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala Node.js 20.x (LTS) desde NodeSource sin conflictos
RUN apt-get remove -y nodejs libnode-dev npm || true && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Instalar la librería paho-mqtt de forma global
RUN python3 -m pip install paho-mqtt

# Instalar el paquete del bot de telegram
RUN python3 -m pip install python-telegram-bot

# Instalar el paquete influxdb
RUN python3 -m pip install influxdb

# Directorio de trabajo y volumen persistente
RUN mkdir -p /home/root/
VOLUME ["/home/root/"]

WORKDIR /home/root

# Mostrar versiones instaladas al arrancar
RUN echo "\
Python: $(python3 --version)\n\
Pip: $(pip3 --version)\n\
Node: $(node -v)\n\
NPM: $(npm -v)\n\
Git: $(git --version)\n\
" > /VERSIONS.txt

# Comando por defecto
CMD ["/bin/bash"]
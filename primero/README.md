# Primer curso MUIInf
Esta carpeta contiene todo el contenido realizado durante el primer curso del master del año 2025-2026

## [COS](./COS)

## [RSE](./RSE)

## [SAD](./SAD)

## [Entorno Docker para el Máster](./docker)

> [!IMPORTANT]
> Esta imagen Docker incluye las herramientas básicas necesarias para el desarrollo inicial del proyecto del Máster en Ingeniería Informática. A medida que surjan nuevos requisitos, se irán añadiendo más herramientas y dependencias al contenedor según sea necesario. Mantén el Dockerfile y el archivo `docker-compose.yml` actualizados para reflejar cualquier cambio en el entorno de desarrollo.

<aside>
Este proyecto utiliza un contenedor Docker configurado para proporcionar todas las herramientas necesarias para el desarrollo del Máster en Ingeniería Informática. La imagen se basa en Ubuntu 22.04 LTS, y está configurada con las siguientes herramientas y configuraciones:
</aside>

### Cómo funciona el entorno Docker

La imagen Docker se construye a partir del **Dockerfile** proporcionado y se gestiona con **docker-compose**. La imagen se denomina `ubuntu-muiinf` y tiene configurados los siguientes servicios:

1. **Ubuntu 22.04 LTS**: Se utiliza como base para tener un entorno limpio y optimizado.
2. **Herramientas esenciales**:
   - **`nano`, `vim`** (editores de texto)
   - **`curl`, `wget`, `git`** (utilidades de red y control de versiones)
   - **`zip`, `unzip`, `tar`** (compresión y descompresión de archivos)
   - **`python3`, `python3-pip`** (para trabajar con Python y gestionar paquetes)
   - **`nodejs`, `npm`** (para desarrollo de aplicaciones Node.js)

### Dockerfile

El **Dockerfile** configura el contenedor de la siguiente manera:
- Instala las herramientas necesarias como editores de texto, utilidades de red y administración de paquetes.
- Instala Node.js y Python 3, junto con sus respectivos gestores de paquetes (`npm` y `pip`).
- Establece `/home/root/` como directorio de trabajo y punto de montaje para los volúmenes persistentes.
- **El volumen `ubuntu-data`** se monta en el contenedor en `/home/root/`, lo que permite persistir datos como bases de datos, configuraciones, o archivos generados dentro del contenedor.
- Muestra las versiones de las herramientas instaladas en un archivo `/VERSIONS.txt` dentro del contenedor para facilitar el diagnóstico.

```dockerfile
FROM ubuntu:22.04

# Instala herramientas básicas
RUN apt-get update && apt-get upgrade -y &&     apt-get install -y     nano     vim     curl     wget     git     zip     unzip     tar     net-tools     iputils-ping     htop     build-essential     python3     python3-pip     ca-certificates     jq     locales

# Instalar Node.js 20.x (LTS) desde NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&     apt-get install -y nodejs &&     npm install -g npm@latest

# Crear el directorio de trabajo y volumen persistente
RUN mkdir -p /home/root/
VOLUME ["/home/root/"]

# Establecer el directorio de trabajo y el volumen
WORKDIR /home/root

# Mostrar las versiones de las herramientas instaladas
RUN echo "Python: $(python3 --version)
Pip: $(pip3 --version)
Node: $(node -v)
NPM: $(npm -v)
Git: $(git --version)
" > /VERSIONS.txt

# Comando por defecto
CMD ["/bin/bash"]
```

### docker-compose.yml

El **`docker-compose.yml`** define los servicios y puertos que se exponen del contenedor:

- **Puertos configurables**: Permite modificar los puertos expuestos a través del archivo `.env`.
- **Volumen persistente**: El volumen `ubuntu-data` se monta en `/home/root/` dentro del contenedor, permitiendo persistir datos de forma segura entre reinicios.
- **Configuración de entorno**: Incluye variables de entorno para configurar el entorno de desarrollo, como `NODE_ENV` o la zona horaria `TZ`.

```yaml
version: "3.9"

services:
  ubuntu-muiinf:
    build: .
    container_name: ubuntu-muiinf
    image: ubuntu-muiinf:latest
    tty: true
    stdin_open: true

    # Puertos configurables desde .env
    ports:
      - "${PORT_3001:-3001}:3001"
      - "${PORT_3002:-3002}:3002"
      - "${PORT_8080:-8080}:8080"
      - "${PORT_5000:-5000}:5000"
      - "${PORT_4222:-4222}:4222"
      - "${PORT_8222:-8222}:8222"

    volumes:
      # Volumen persistente ubuntu-data montado en /home/root/
      - ubuntu-data:/home/root/

    working_dir: /home/root/

    environment:
      - NODE_ENV=development
      - LANG=C.UTF-8
      - LC_ALL=C.UTF-8
      - TZ=Europe/Madrid

volumes:
  ubuntu-data:
    external: true
```

### Requisitos previos

1. **Instalar Docker y Docker Compose** en tu máquina (si no lo has hecho ya).
2. **Crear el archivo `.env`** en el mismo directorio que el `docker-compose.yml` con las variables de puertos configurables. Por ejemplo:

```bash
PORT_3001=3001
PORT_3002=3002
PORT_8080=8080
PORT_5000=5000
PORT_4222=4222
PORT_8222=8222
```

### Cómo ejecutar el contenedor

1. Construir la imagen:

```bash
docker compose build --no-cache
```

2. Levantar el contenedor:

```bash
docker compose up -d
```

3. Acceder al contenedor:

```bash
docker exec -it ubuntu-muiinf bash
```

4. Verificar las versiones de las herramientas instaladas:

```bash
cat /VERSIONS.txt
```

### Uso en el contexto del Máster

Este contenedor está diseñado para ser una **base sólida** para tus proyectos del Máster en Ingeniería Informática, con herramientas esenciales como:
- **Node.js** para desarrollo web y servidores backend.
- **Python 3** para tareas de automatización o análisis de datos.
- Herramientas de desarrollo estándar como **git**, **nano**, **vim**, y utilidades de red y sistema.

El volumen `ubuntu-data` te permitirá **persistir datos** entre ejecuciones del contenedor, como bases de datos, archivos de configuración y cualquier archivo generado por tus aplicaciones.

#!/bin/bash

# === CONFIGURACIÓN ===
USUARIO="practica"
PASSWORD="cos"
HOST="158.42.181.244"

# === VALIDACIÓN DE ARGUMENTO ===
if [ -z "$1" ]; then
  echo "Uso: $0 <número_de_salida>"
  echo "Debes indicar un número de salida entre 1 y 8"
  exit 1
fi

SALIDA="$1"

# Verificar si es un número entre 1 y 8
if ! [[ "$SALIDA" =~ ^[1-8]$ ]]; then
  echo "Error: '$SALIDA' no es una salida válida."
  echo "Por favor, introduce un número del 1 al 8."
  exit 1
fi

# === ENVÍO DE COMANDOS ===
{
  printf "$USUARIO\n"
  printf "$PASSWORD\n"
  printf "1\n"         # Entrar en el menú de control
  printf "$SALIDA\n"   # Seleccionar la salida a encender
  printf "1\n"         # Encender
  printf "yes\n"       # Confirmar
  printf "\n"          # Retorno
  printf "\033\0334\n" # Salida del menú con doble ESC + 4
} | telnet "$HOST"

echo "Salida $SALIDA encendida correctamente (si no hubo errores de red o autenticación)."

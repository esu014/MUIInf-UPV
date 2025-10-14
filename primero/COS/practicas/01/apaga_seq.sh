#!/bin/bash

echo "Empieza el programa: enciende todas las salidas secuencialmente"

# Dirección IP del dispositivo
HOST="158.42.181.244"

# Número total de salidas
NUM_SALIDAS=8

# Tiempo de retardo entre apagados (en segundos)
RETRASO=1

# Crear la secuencia de comandos que se enviarán por telnet
for ((i=1; i<=NUM_SALIDAS; i++))
do
  echo "Activando salida $i..."

  {
    printf "practica\n"
    printf "cos\n"
    printf "1\n"
    printf "$i\n"
    printf "2\n"
    printf "yes\n"
    printf "\n"
    printf "\033\0334\n"
  } | telnet "$HOST"

  sleep $RETRASO
done

echo "Programa finalizado"


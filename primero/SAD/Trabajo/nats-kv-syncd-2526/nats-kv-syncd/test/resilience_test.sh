#!/bin/bash

# Configuración de URLs (Ajusta si usas localhost o nombres de red)
NATS_A="nats://nats-a:5222" # nats://localhost:4223
NATS_B="nats://nats-b:5222" # nats://localhost:4224

echo "--------------------------------------------------------"
echo "INICIANDO TEST DE RESILIENCIA (VALIDACIÓN AUTOMÁTICA)"
echo "--------------------------------------------------------"

# 1. Preparación inicial
echo "1. Configurando valores iniciales en nats-b..."
nats --server $NATS_B kv add usuarios
nats --server $NATS_B kv put SYSTEM_REGISTRY usuarios "active"

nats --server $NATS_B kv put usuarios user "username" > /dev/null
nats --server $NATS_B kv put config theme "white" > /dev/null
nats --server $NATS_B kv put usuarios admin "username2" > /dev/null

echo ""
echo "Ahora PARA el contenedor nats-a-1"
echo "Comando: docker stop <nombre_contenedor>"
read -p "Presiona [ENTER] cuando el Nodo A esté offline"

echo -e "\n\n2. Realizando cambios en aislamiento (Nodo A está caído)..."
nats --server $NATS_B kv put config theme "black" > /dev/null
nats --server $NATS_B kv put usuarios user "username2" > /dev/null
nats --server $NATS_B kv del usuarios admin --force > /dev/null

echo "--------------------------------------------------------"
echo "OPERACIONES COMPLETADAS EN NATS-B"
echo "--------------------------------------------------------"
echo "PASO FINAL: Levanta el contenedor nats-a-1 ahora."
read -p "Presiona [ENTER] cuando el Nodo A esté online y el agente corriendo..."

echo "Esperando 10 segundos para la sincronización de Anti-Entropía..."
sleep 10

echo "--------------------------------------------------------"
echo "VERIFICANDO ESTADO FINAL EN NODO A..."
echo "--------------------------------------------------------"

# Recuperar valores del Nodo A
VALOR_THEME=$(nats --server $NATS_A kv get config theme --raw 2>/dev/null)
VALOR_USER=$(nats --server $NATS_A kv get usuarios user --raw 2>/dev/null)
# Comprobamos si 'admin' sigue existiendo
nats --server $NATS_A kv get usuarios admin > /dev/null 2>&1
STATUS_ADMIN=$?

ERRORES=0

# Validación de Theme
if [ "$VALOR_THEME" == "black" ]; then
    echo "Theme: OK (black)"
else
    echo "Theme: ERROR (Esperado: black, Recibido: $VALOR_THEME)"
    ERRORES=$((ERRORES+1))
fi

# Validación de User
if [ "$VALOR_USER" == "username2" ]; then
    echo "User: OK (username2)"
else
    echo "User: ERROR (Esperado: username2, Recibido: $VALOR_USER)"
    ERRORES=$((ERRORES+1))
fi

# Validación de Borrado (Admin)
if [ $STATUS_ADMIN -ne 0 ]; then
    echo "Admin (Tombstone): OK (Eliminado correctamente)"
else
    echo "Admin (Tombstone): ERROR (El registro aún existe en Nodo A)"
    ERRORES=$((ERRORES+1))
fi

echo "--------------------------------------------------------"
if [ $ERRORES -eq 0 ]; then
    echo "RESULTADO FINAL: TEST DE RESILIENCIA SUPERADO"
    echo "El Nodo A ha recuperado todo el histórico correctamente."
else
    echo "RESULTADO FINAL: TEST FALLIDO"
    echo "Se han detectado $ERRORES discrepancias en la sincronización."
fi
echo "--------------------------------------------------------"
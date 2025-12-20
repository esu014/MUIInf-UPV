#!/bin/bash

# Configuración de URLs (ajusta según tus puertos mapeados)
NATS_A="nats://nats-a:5222" # nats://localhost:4223
NATS_B="nats://nats-b:5222" # nats://localhost:4224
NUEVO_BUCKET="inventario"

echo "--------------------------------------------------------"
echo "TEST DE DESCUBRIMIENTO DINÁMICO (MULTI-BUCKET)"
echo "--------------------------------------------------------"

# 1. Crear el bucket físicamente en el servidor NATS
echo "1. Creando bucket '$NUEVO_BUCKET' en el servidor..."
nats --server $NATS_A kv add $NUEVO_BUCKET

# 2. Registrar el bucket en el SYSTEM_REGISTRY para avisar a los agentes
echo "2. Registrando en SYSTEM_REGISTRY..."
nats --server $NATS_A kv put SYSTEM_REGISTRY $NUEVO_BUCKET "active"

echo "Esperando 5 segundos a que los agentes inicialicen los watchers..."
sleep 5

# 3. Realizar una operación en el nuevo bucket desde el Nodo A
echo "3. Insertando dato en Nodo A -> $NUEVO_BUCKET: stock=50"
nats --server $NATS_A kv put $NUEVO_BUCKET stock "50"

echo "Esperando sincronización..."
sleep 5

# 4. Verificar si el Nodo B ha recibido el dato
VALOR_B=$(nats --server $NATS_B kv get $NUEVO_BUCKET stock --raw 2>/dev/null)

if [ "$VALOR_B" == "50" ]; then
    echo "--------------------------------------------------------"
    echo "RESULTADO: TEST SUPERADO"
    echo "El Nodo B descubrió el bucket y sincronizó el valor: $VALOR_B"
    echo "--------------------------------------------------------"
else
    echo "--------------------------------------------------------"
    echo "RESULTADO: TEST FALLIDO"
    echo "El Nodo B no tiene el valor. Valor actual: '$VALOR_B'"
    echo "--------------------------------------------------------"
fi
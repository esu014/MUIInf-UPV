#!/bin/bash

NATS_A="nats://nats-a:5222" # nats://localhost:4223
NATS_B="nats://nats-b:5222" # nats://localhost:4224
BUCKET="config"

echo "--------------------------------------------------------"
echo "TEST DE RESOLUCIÓN DE CONFLICTOS (LWW)"
echo "--------------------------------------------------------"

# 1. Limpiar estado previo
echo "1. Preparando clave 'prioridad'..."
nats --server $NATS_A kv put $BUCKET prioridad "inicial"
sleep 1

# 2. Simular actualizaciones rápidas desde ambos nodos
echo "2. Ejecutando escrituras en conflicto..."
echo "[Nodo A] Escribiendo: ALTA"
nats --server $NATS_A kv put $BUCKET prioridad "ALTA"
# No ponemos sleep o ponemos uno muy corto para simular cercanía
echo "[Nodo B] Escribiendo: CRÍTICA"
nats --server $NATS_B kv put $BUCKET prioridad "CRÍTICA"

echo "Esperando convergencia..."
sleep 3

# 3. Verificar consistencia
FINAL_A=$(nats --server $NATS_A kv get $BUCKET prioridad --raw)
FINAL_B=$(nats --server $NATS_B kv get $BUCKET prioridad --raw)

echo "Estado final en Nodo A: $FINAL_A"
echo "Estado final en Nodo B: $FINAL_B"

if [ "$FINAL_A" == "$FINAL_B" ]; then
    echo "--------------------------------------------------------"
    echo "RESULTADO: TEST SUPERADO"
    echo "Ambos nodos han convergido al mismo valor: $FINAL_A"
    echo "--------------------------------------------------------"
else
    echo "--------------------------------------------------------"
    echo "RESULTADO: TEST FALLIDO"
    echo "Los nodos tienen valores diferentes. ¡Hay divergencia!"
    echo "--------------------------------------------------------"
fi
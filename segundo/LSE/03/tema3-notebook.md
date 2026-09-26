# Guía de Estudio Teórica: Gestión de Inventarios y Almacenes (LSE)

## 1. Fundamentos y Clasificación de Existencias

En el ámbito de la ingeniería de organización, el stock no debe entenderse meramente como una acumulación física de productos, sino como un regulador estratégico que permite el **desacoplamiento** entre las fases de suministro, producción y demanda. Una gestión eficiente minimiza el **capital inmovilizado** y optimiza el nivel de servicio.

### 1.1. Estrategias de Producción y Suministro

La configuración del sistema logístico depende de dónde se sitúe el punto de desacoplamiento (*decoupling point*):

- **Make to Stock (MTS):** Producción orientada al inventario. La empresa fabrica productos terminados de forma independiente a los pedidos en firme. Se aplica a productos de alto volumen y nula personalización, asumiendo un riesgo de inventario para garantizar disponibilidad inmediata.
- **Assemble to Order (ATO):** El producto final se configura a partir de componentes estándar previamente almacenados. El proceso de personalización (ensamblaje) solo se inicia tras recibir el pedido, permitiendo un equilibrio entre agilidad y variedad.
- **Fabricación bajo pedido (Make to Order - MTO):** La producción comienza exclusivamente tras la confirmación del cliente. Esta estrategia elimina el riesgo de obsolescencia de producto terminado, desplazando el punto de desacoplamiento al inicio del proceso. Es característica de la maquinaria especial o bienes de alta complejidad.

### 1.2. Clasificación Funcional del Stock

- **Stock por anticipación:** Reservas acumuladas ante incrementos previstos de la demanda, promociones comerciales o paradas técnicas programadas.
- **Stock por tamaño de lote:** Surge al procesar cantidades superiores a la demanda inmediata para amortizar los costes fijos de emisión o configuración de maquinaria.
- **Stock en tránsito:** Existencias en movimiento dentro de la red logística, necesarias para salvar la distancia física entre eslabones.
- **Stock de seguridad ($SS$):** Nivel de inventario destinado a proteger el sistema frente a la variabilidad de la demanda o retrasos inesperados en el tiempo de suministro.

### 1.3. Clasificación según Proceso de Fabricación

1. **Materias primas:** Recursos que no han sufrido transformación en la planta.
2. **Productos en curso (WIP):** Componentes en fases intermedias de transformación o espera.
3. **Productos acabados:** Bienes finales destinados a la comercialización.
4. **Piezas de repuesto:** Elementos críticos para el mantenimiento que garantizan la disponibilidad de los activos productivos.
5. **Suministros industriales:** Materiales necesarios para el proceso (disolventes, lubricantes, energía) que no se integran físicamente en el producto final.
6. **Ítems de fabricación ajena:** Componentes cuya adquisición externa resulta más eficiente que la producción propia.

### 1.4. Naturaleza de la Demanda

- **Demanda independiente:** Sujeta a fluctuaciones externas del mercado (productos terminados).
- **Demanda dependiente:** Se deriva directamente de planes de producción internos (componentes y materias primas).

## 2. Análisis y Procedimiento ABC (Pareto)

La clasificación ABC es una técnica de gestión selectiva basada en el principio de Pareto, que permite enfocar los recursos de control en los artículos con mayor impacto económico.

### 2.1. Metodología de Clasificación

1. **Identificación:** Registro de la demanda anual ($D$) y el coste unitario ($c_a$) de cada referencia.
2. **Valoración del Consumo:** Cálculo del valor monetario anual para cada ítem ($V_i = c_a \cdot D$).
3. **Jerarquización:** Ordenación de los artículos de mayor a menor valor de consumo.
4. **Acumulación:** Cálculo del porcentaje individual sobre el valor total y del porcentaje acumulado de la inversión.

### 2.2. Categorización de Artículos

Siguiendo los estándares de la asignatura LSE (basados en el análisis de referencias tipo LogiParts), se establecen los siguientes umbrales:

| Clase | % de Inversión Acumulada | Descripción |
| --- | --- | --- |
| **A** | Hasta $\approx 81{,}3\%$ | Artículos críticos. Representan la mayor inversión en capital inmovilizado. |
| **B** | Hasta $\approx 95{,}7\%$ | Artículos de importancia intermedia. |
| **C** | Hasta $100\%$ | Artículos de escaso valor económico pero muy numerosos. |

### 2.3. Políticas de Control según Clase

- **Clase A:** Seguimiento continuo y riguroso. Se busca minimizar el stock de seguridad y maximizar la rotación para reducir el **Coste de Oportunidad** del capital.
- **Clase B:** Control intermedio con revisiones periódicas programadas.
- **Clase C:** Control simplificado (ej. sistema de dos cajones). El coste administrativo de un control exhaustivo no compensa el valor del inventario.

## 3. Estructura de Costes de Inventario

El objetivo fundamental es la minimización del Coste Total Anual ($CT$), equilibrando los costes de posesión frente a los de gestión.

### 3.1. Definición de Parámetros de Coste

Es imperativo diferenciar entre costes unitarios y sus magnitudes anuales totales:

- **Coste de Adquisición ($C_a$):** Valor total de compra.
  - $C_a = c_a \cdot D$, donde $c_a$ es el precio unitario.
- **Coste de Emisión o Pedido ($C_e$):** Coste anual de lanzar órdenes al proveedor.
  - $C_e = K \cdot \frac{D}{Q}$, donde $K$ es el coste fijo por cada pedido individual.
- **Coste de Posesión o Mantenimiento ($C_p$):** Coste anual derivado de mantener stock en almacén.
  - $C_p = h \cdot \bar{I}$, donde $h$ es el coste de mantenimiento por unidad y año, e $\bar{I}$ es el inventario medio. El valor de $h$ es independiente del proveedor y refleja el coste de oportunidad.
- **Coste de Ruptura o Faltante ($C_r$ o $B$):** Penalización económica por no satisfacer la demanda.
  - $B$ se define como el coste de faltante por unidad y año.

### 3.2. Ecuación del Coste Total ($CT$)

Para un modelo determinista básico, la función de coste a minimizar es:

$$
CT = c_a \cdot D + K \cdot \frac{D}{Q} + h \cdot \frac{Q}{2}
$$

## 4. Parámetros Operacionales y Sistemas de Control

### 4.1. Variables Técnicas

- **Tiempo de Suministro ($T_s$):** Plazo entre la emisión del pedido y su disponibilidad en almacén.
- **Tiempo de Reaprovisionamiento o Ciclo ($T_r$):** Tiempo entre dos recepciones consecutivas ($T_r = \frac{Q}{D/t}$).
- **Lote de Pedido ($Q$):** Cantidad de unidades solicitadas en cada orden.

**Nota de Cátedra sobre la Base Temporal ($t$):** En la resolución de ejercicios LSE, es crítico verificar el número de días operativos. Si se indica "($\text{Año} = 365\ \text{días}$)", la demanda diaria es $\frac{D}{365}$. En entornos industriales con fines de semana no laborables, se suele aplicar $t = 250$ días.

### 4.2. El Punto de Pedido ($P_p$)

El $P_p$ determina el nivel de inventario que activa el proceso de compra. Según el **Formulario LSE**, se debe aplicar la fórmula de precisión para cualquier relación entre el tiempo de suministro y el tiempo de ciclo:

$$
P_p = (T_s - E \cdot T_r) \cdot \frac{D}{t} + SS
$$

Donde $E$ representa el número de ciclos completos que transcurren durante el tiempo de espera (la parte entera de $\frac{T_s}{T_r}$).

- Si $T_s < T_r$, entonces $E = 0$, reduciéndose la fórmula a: $P_p = T_s \cdot \frac{D}{t} + SS$.

### 4.3. Sistemas de Revisión

- **Revisión Continua (Sistema $Q$):** Se monitoriza el nivel de stock en tiempo real. Se pide una cantidad fija $Q$ cuando se alcanza el $P_p$.
- **Revisión Periódica (Sistema P):** Se revisa el stock cada intervalo de tiempo fijo y se pide la cantidad necesaria para alcanzar un nivel objetivo.

## 5. Modelos Deterministas de Gestión de Stocks (EOQ)

### 5.1. Modelo EOQ Clásico (Lote Económico de Wilson)

Basado en demanda constante, entrega inmediata y ausencia de escasez.

- **Lote Óptimo ($Q^{*}$):** $Q^{*} = \sqrt{\frac{2 \cdot D \cdot K}{h}}$
- **Número de pedidos/año:** $N = \frac{D}{Q^{*}}$
- **Tiempo entre pedidos ($T_r$):** $T_r = \frac{Q^{*}}{D}$ (años) o $T_r = \frac{t}{N}$ (días).

### 5.2. EOQ con Escasez Planificada (Backorders)

Se permite diferir la entrega de pedidos si el coste de mantenimiento es significativamente superior al coste de faltante ($B$).

- **Lote Óptimo ($Q^{*}$):** $Q^{*} = \sqrt{\frac{2 \cdot D \cdot K}{h} \cdot \left( \frac{h+B}{B} \right)}$
- **Máximo nivel de escasez ($S^{*}$):** $S^{*} = Q^{*} \cdot \left( \frac{h}{h+B} \right)$
- **Stock Máximo ($I_{\max}$):** $I_{\max} = Q^{*} - S^{*}$
- **Tiempos del ciclo:**
  - $t_1 = \frac{Q^{*} - S^{*}}{D}$ (Tiempo con existencias).
  - $t_2 = \frac{S^{*}}{D}$ (Tiempo en situación de escasez).

### 5.3. EOQ con Descuentos por Cantidad

Procedimiento para determinar si el ahorro en el coste de adquisición compensa el incremento en el coste de mantenimiento:

1. **Cálculo de $Q^{*}$:** Calcular el lote óptimo de Wilson para cada tramo de precio utilizando el $h$ correspondiente (si este depende del precio).
2. **Validación de Factibilidad:**
   - Si el $Q^{*}$ calculado está dentro del rango del tramo, es **factible**.
   - Si el $Q^{*}$ es inferior al límite mínimo del tramo, el candidato factible para ese precio es el **límite inferior** (punto de quiebre o *price break*).
   - Si el $Q^{*}$ es superior al límite máximo, ese tramo se descarta (ya que el $Q^{*}$ del tramo siguiente, con menor precio, será más favorable).
3. **Comparación de Costes Totales:** Calcular el $CT$ para todos los $Q$ factibles identificados, incluyendo obligatoriamente el coste de adquisición ($c_a \cdot D$). Se selecciona la opción con el menor $CT$ anual.

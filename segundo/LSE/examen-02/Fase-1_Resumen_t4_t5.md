---
title: "Fase 1 - Resumen"
lang: es-ES
papersize: a4
geometry:
  - top=2cm
  - bottom=2cm
  - left=1.5cm
  - right=1.5cm
fontsize: 11pt
mainfont: DejaVu Serif
---

## 1. Mapa general antes de estudiar

Piensa que los dos temas responden a dos preguntas diferentes:

**Tema 4 — ¿Dónde y por dónde?**

- ¿Desde qué origen envío mercancía a cada destino? → **Transporte**

- ¿Dónde coloco instalaciones? → **Localización**

- ¿Dónde coloco instalaciones para cubrir clientes? → **Cubrimiento**

- ¿Qué ruta debe hacer un viajante? → **TSP**

- ¿Qué rutas hacen vehículos con capacidad limitada? → **VRP**

- ¿Cómo encuentro soluciones buenas rápidamente? → **Heurísticas**

**Tema 5 — ¿Quién hace qué y cuándo?**

- ¿Qué recurso realiza cada tarea? → **Asignación**

- ¿En qué orden se realizan? → **Secuenciación / Scheduling**

- ¿Cómo clasifico un problema de scheduling? → **$\alpha$ | $\beta$ | $\gamma$**

- ¿Qué regla sencilla puedo usar? → **Reglas de prioridad**

- ¿Cómo consigo buenas soluciones cuando resolver exactamente es difícil? → **Heurísticas**

- ¿Cómo supero los óptimos locales? → **Metaheurísticas**

Scheduling se define precisamente como la **asignación de recursos a tareas a lo largo del tiempo con el objetivo de optimizar uno o varios criterios**.


# TEMA 4 — RUTAS, LOCALIZACIÓN Y TRANSPORTE

## 2. Problema de transporte

Tenemos:

**Orígenes** → donde existe oferta o disponibilidad.

**Destinos** → donde existe demanda.

**$c_{ij}$** → coste de transportar una unidad desde el origen $i$ al destino $j$.

La pregunta es:

> ¿Cuánto envío desde cada origen a cada destino para satisfacer las demandas al menor coste?

Los apuntes definen precisamente esos tres elementos: oferta conocida en los orígenes, demanda conocida en los destinos y costes conocidos entre cada pareja origen-destino.

La variable fundamental es:

$$
x_{ij}=\text{cantidad enviada del origen }i\text{ al destino }j
$$

Y se minimiza:

$$
\sum_i \sum_j c_{ij}x_{ij}
$$

Las dos restricciones importantes conceptualmente son:

**Oferta**

$$
\sum_j x_{ij}\leq a_i
$$

No puedo sacar de un origen más producto del disponible.

**Demanda**

$$
\sum_i x_{ij}\geq b_j
$$

Cada destino tiene que recibir al menos lo que necesita.

El objetivo del modelo es precisamente minimizar el coste total de transporte.

**Trampa típica de test:** oferta y demanda no son lo mismo. Oferta pertenece al origen; demanda pertenece al destino.


## 3. Localización de instalaciones

Es una ampliación del transporte.

Ahora no solo decidimos **cuánto transportar**, sino también:

> ¿Qué instalaciones construyo?

Aparecen dos clases de variables:

$$
x_{ij}=\text{cantidad enviada desde instalación }i\text{ a cliente }j
$$

$$
y_i=
\begin{cases}
1 & \text{si construyo la instalación }i\\
0 & \text{si no}
\end{cases}
$$

Por tanto, la función objetivo incorpora:

**costes fijos de abrir instalaciones + costes de transporte.**

$$
\min \sum_i \left(f_i y_i+\sum_jc_{ij}x_{ij}\right)
$$

La restricción clave es:

$$
\sum_jx_{ij}\leq a_i y_i
$$

Entiéndela muy bien:

- si $y_i=0$, el lado derecho vale 0 → esa instalación **no puede producir/enviar nada**;

- si $y_i=1$, puede producir hasta su capacidad $a_i$.

Este mecanismo de conectar una variable binaria con otra variable aparece muchas veces en optimización. El modelo completo de localización de los apuntes combina precisamente $x_{ij}$ con una variable binaria $y_i$.


## 4. Tres familias de problemas de localización

Aquí hay una diferenciación perfecta para tipo test.

### Mediana — Minisum

Se quiere minimizar:

> **la suma de las distancias** entre instalaciones y clientes.

Ejemplo sencillo: una empresa quiere que, globalmente, todos sus clientes recorran pocos kilómetros.

### Centro — Minimax

Se quiere minimizar:

> **la mayor distancia** de cualquier cliente a su instalación.

Ejemplo: ambulancias. Puede interesarme que el cliente peor atendido tampoco esté demasiado lejos.

### Cubrimiento

Un cliente está cubierto cuando:

$$
\text{distancia} \leq \text{umbral}
$$

Por ejemplo:

> Una ambulancia cubre una zona si puede llegar en menos de 10 minutos.

Los apuntes distinguen explícitamente **minisum, minimax y cubrimiento** de esta manera.

**Muy preguntable:**

- Mediana → suma.

- Centro → máximo.

- Cubrimiento → umbral.


## 5. Problema de Weber

Es un problema clásico de localización de **una instalación/servidor**.

Tenemos puntos ya conocidos y buscamos un punto del plano que minimice la suma de costes/distancias hacia ellos.

En el problema original las distancias están además **ponderadas**.

Ejemplo:

Tres poblaciones generan 100, 500 y 1000 envíos.

No necesariamente interesa situar el almacén en el centro geométrico: la población que genera 1000 envíos debería tener más peso.


## 6. Variables enteras y binarias

Variable entera:

$$
x\in\{\ldots,-1,0,1,2,\ldots\}
$$

Variable binaria:

$$
y\in\{0,1\}
$$

Una binaria representa normalmente decisiones del estilo:

- abrir/no abrir;

- seleccionar/no seleccionar;

- usar/no usar;

- arco pertenece/no pertenece a una ruta.

Los apuntes remarcan que las binarias son un caso especial de variables enteras.

Hay cuatro relaciones que **conviene memorizar hasta reconocerlas instantáneamente**:

$$
Y_1+Y_2\le1
$$

→ como máximo una.

$$
Y_1+Y_2\ge1
$$

→ al menos una.

$$
Y_1\le Y_2
$$

→ si elijo 1, necesariamente elijo 2.

$$
Y_1\ge Y_2
$$

→ si elijo 2, necesariamente elijo 1.

Son exactamente las relaciones utilizadas en los apuntes.


## 7. Big-M: conectar variable entera y binaria

Muy importante.

Supongamos:

- $X_j$ = número de supermercados abiertos.

- $Y_j$ = 1 si operamos en esa provincia.

Queremos que:

> Si $X_j>0$, entonces $Y_j=1$.

Podemos imponer:

$$
X_j\le M Y_j
$$

Si $Y_j=0$:

$$
X_j\le0
$$

por lo que necesariamente $X_j=0$.

Si queremos además forzar la relación inversa:

$$
Y_j\le X_j
$$

Los apuntes resumen la relación como:

$$
Y_j\le X_j\le M Y_j
$$

donde $M$ es un valor suficientemente grande o, mejor aún, un máximo conocido del problema.

Esta es carne de pregunta tipo test.


## 8. TSP — Traveling Salesman Problem

Este concepto tiene que quedar cristalino.

Un viajante:

1. parte de un origen/depósito;

2. visita **cada ciudad exactamente una vez**;

3. vuelve al origen;

4. quiere minimizar el coste total.

El resultado tiene que ser **un único ciclo**, llamado ciclo o circuito Hamiltoniano.

No puede haber pequeños ciclos independientes.

Además, el TSP es **NP-hard**.

Ejemplo correcto:

$$
0\rightarrow2\rightarrow3\rightarrow1\rightarrow4\rightarrow0
$$

Incorrecto:

$$
0\rightarrow2\rightarrow0
$$

y

$$
1\rightarrow3\rightarrow4\rightarrow1
$$

Aunque todos tengan una entrada y una salida, hay **dos ciclos separados**.


## 9. Formulación del TSP

Variable:

$$
x_{ij}=
\begin{cases}
1 & \text{si utilizamos el arco }(i,j)\\
0 & \text{en otro caso}
\end{cases}
$$

Objetivo:

$$
\min \sum_{i,j}c_{ij}x_{ij}
$$

Y necesitamos que:

- de cada nodo salga exactamente un arco;

- a cada nodo llegue exactamente un arco;

- no existan subtours.

Para eliminar esos ciclos intermedios aparecen las restricciones **MTZ — Miller-Tucker-Zemlin**.

Los apuntes dejan claro que las restricciones de entrada/salida no bastan: las MTZ son las que impiden los ciclos intermedios.

**Pregunta típica:**

> ¿Para qué sirven las restricciones MTZ?

Respuesta:

**Para eliminar subtours/ciclos intermedios.**

No para minimizar distancia, ni para obligar a visitar cada nodo: eso ya lo hacen otras restricciones.


## 10. ¿Qué es una heurística?

Esta sí puede ser perfectamente la pregunta abierta.

Una definición sencilla y válida:

> **Una heurística es un procedimiento que busca obtener una buena solución a un problema en un tiempo de computación razonable, sin garantizar que esa solución sea óptima.**

Esa última parte es esencial:

**buena solución ≠ solución óptima garantizada.**

Los propios apuntes la definen de esa forma.

Un buen heurístico debe ser:

**Eficiente** → coste computacional razonable.

**Eficaz/bueno** → soluciones próximas al óptimo en promedio.

**Robusto** → baja probabilidad de producir soluciones muy malas.


## 11. Tipos básicos de heurísticas

### Reglas de despacho

Ordenaciones sencillas.

### Constructivas

Empiezan **desde cero** y van añadiendo elementos hasta construir una solución.

Ejemplos:

- vecino más próximo;

- inserción;

- ahorros.

### Búsqueda local

Empieza con una **solución completa existente** y trata de mejorarla.

Los apuntes hacen exactamente esta separación entre constructivas y búsqueda local.

Esta diferencia seguramente aparecerá varias veces durante Tema 5.


## 12. Búsqueda local

Supongamos que tenemos una solución $S$.

Su **vecindario $N(S)$** es el conjunto de soluciones que podemos obtener aplicando determinados movimientos a $S$.

Ejemplo:

$$
S=(1,2,3,4,5)
$$

Si nuestro movimiento es intercambiar dos elementos:

$$
S'=(1,3,2,4,5)
$$

puede ser un vecino.

La búsqueda local intenta encontrar un vecino mejor, moverse hasta él y repetir el proceso.

### First improvement

En cuanto encontramos **el primer vecino que mejora**, nos movemos.

### Best improvement

Evaluamos todos los vecinos posibles y elegimos **el mejor**.

### VNS

Utiliza diferentes vecindarios secuencialmente. Si encuentra una mejora, vuelve a empezar desde el primer vecindario.

Ojo:

**first improvement no significa elegir el mejor de todos.**


## 13. VRP — Vehicle Routing Problem

Puedes pensar:

> **VRP = TSP + reparto + capacidad del vehículo.**

Existe:

- depósito;

- clientes;

- demanda $d_j$ de cada cliente;

- vehículo con capacidad $C$;

- costes $c_{ij}$.

Queremos satisfacer todas las demandas minimizando el coste.

Como el vehículo tiene capacidad limitada, puede necesitar:

$$
0\rightarrow \text{clientes}\rightarrow0
$$

y después salir de nuevo:

$$
0\rightarrow \text{otros clientes}\rightarrow0
$$

Los apuntes destacan precisamente que puede ser necesario realizar varias rutas regresando al depósito para recargar. Tema4-RoutingProblemsVRP_Clase 5

### Diferencia esencial TSP / VRP

**TSP:** normalmente una ruta que visita todos los nodos.

**VRP:** puede haber varias rutas debido principalmente a restricciones como capacidad.


## 14. Restricciones VRP

Además de las condiciones de entrada y salida aparecen restricciones relacionadas con la **capacidad**.

Las variables $u_i$ representan la cantidad entregada/acumulada hasta alcanzar determinado nodo.

Cuando:

$$
x_{ij}=1
$$

se fuerza algo equivalente a:

$$
u_j\geq u_i+d_j
$$

Por tanto se controla la carga acumulada y simultáneamente se ayudan a eliminar ciclos intermedios.

Los apuntes indican expresamente que esta extensión de MTZ impone capacidad y rompe ciclos intermedios. Tema4-RoutingProblemsVRP_Clase 5


## 15. Extensiones del VRP

Pueden aparecer:

- varios vehículos;

- vehículos con diferentes capacidades/velocidades → **HVRP**;

- ventanas temporales → **VRP with Time Windows**;

- tiempos de carga/descarga;

- determinar tamaño de flota;

- pickup and delivery.

Tema4-RoutingProblemsVRP_Clase 5


## 16. Clarke & Wright — Heurística de ahorros

Muy importante porque esta sí podría convertirse perfectamente en ejercicio abierto.

Idea:

Inicialmente cada cliente tiene su propia ruta:

$$
0\rightarrow i\rightarrow0
$$

$$
0\rightarrow j\rightarrow0
$$

Coste:

$$
c_{0i}+c_{i0}+c_{0j}+c_{j0}
$$

Si unimos ambos:

$$
0\rightarrow i\rightarrow j\rightarrow0
$$

ahorramos viajes al depósito.

El ahorro es:

$$
\boxed{s(i,j)=c(0,i)+c(0,j)-c(i,j)}
$$

Después:

1. calculamos todos los ahorros;

2. los ordenamos de mayor a menor;

3. empezamos por los mayores;

4. combinamos rutas siempre que sea posible;

5. nunca podemos violar la capacidad del vehículo.

Es exactamente el procedimiento indicado en las diapositivas. Tema4-RoutingProblemsVRP_Clase 5

**Idea fundamental:**

> Un ahorro grande significa que resulta especialmente interesante conectar directamente esos dos clientes.


# TEMA 5 — PLANIFICACIÓN Y ASIGNACIÓN OPTIMIZADA DE RECURSOS

## 17. Scheduling

Scheduling significa:

> asignar recursos a tareas a lo largo del tiempo para optimizar uno o varios objetivos.

Los elementos fundamentales son:

**Recursos:** máquinas, procesadores, pistas de aeropuerto...

**Tareas:** trabajos, programas, aterrizajes...

**Objetivos:** cumplir fechas, reducir tiempo de finalización, etc.

Y hay que distinguir:

**Asignación**

> ¿Qué recurso realiza cada tarea?

**Secuenciación**

> ¿En qué orden se realizan las tareas?

Los apuntes definen el problema de asignación como encontrar la correspondencia óptima entre órdenes y recursos.


## 18. Diagrama de Gantt

Representación gráfica de un schedule.

- eje X → tiempo;

- eje Y → máquinas;

- barras → operaciones.

Las operaciones correspondientes a una misma tarea pueden identificarse mediante color o textura.

No es un algoritmo: **es una representación** de la planificación.


## 19. Notación $\alpha$ | $\beta$ | $\gamma$

Esta va a ser muy importante para el test.

$$
\boxed{\alpha\mid\beta\mid\gamma}
$$

**$\alpha$** → características de las **máquinas**.

**$\beta$** → características/restricciones de las **tareas**.

**$\gamma$** → **objetivo** que queremos optimizar.

Los apuntes presentan exactamente esta clasificación.


## 20. $\alpha$ — Entorno de máquinas

### Una máquina

Cada trabajo se procesa en esa única máquina.

### Máquinas paralelas

Cada trabajo necesita procesarse en **una** de las máquinas disponibles.

### Sistemas multi-etapa

Cada job pasa por varias máquinas.

Dentro de estos:

**Flow-shop**

Todos los trabajos siguen **la misma ruta de máquinas**.

Ejemplo:

$$
M_1\rightarrow M_2\rightarrow M_3
$$

para todos.

**Job-shop**

Cada trabajo puede seguir **su propia ruta**.

Ejemplo:

$$
J_1:M_1\rightarrow M_3\rightarrow M_2
$$

$$
J_2:M_2\rightarrow M_1\rightarrow M_3
$$

Los apuntes resumen precisamente flow-shop como misma ruta y job-shop como ruta propia de cada tarea.


## 21. $\beta$ — Características de los trabajos

Aquí pueden aparecer condiciones adicionales, por ejemplo:

- fechas de disponibilidad $r_j$;

- fechas de entrega $d_j$;

- pesos $w_j$;

- tiempos de preparación/setup;

- almacenamiento o bloqueo;

- no-wait;

- precedencias;

- recursos adicionales;

- transporte entre máquinas.

Concepto interesante:

### No-wait

Una vez que el trabajo empieza, no puede quedarse esperando entre determinadas operaciones.

### Blocking

Si no existe almacenamiento intermedio, una tarea puede bloquear una máquina hasta poder pasar a la siguiente.

### Setup anticipativo

La preparación de una máquina puede realizarse antes de que llegue el trabajo.

### Setup no anticipativo

Hay que esperar a que el trabajo esté disponible.

Estos detalles suelen ser buenos candidatos a afirmaciones verdadero/falso.


## 22. $\gamma$ — Objetivo

Algunos de los símbolos fundamentales:

$$
C_j
$$

Tiempo de finalización del trabajo $j$.

$$
C_{max}
$$

**Makespan**: momento en que termina el último trabajo.

$$
\sum C_j
$$

Suma de tiempos de completación.

$$
\sum w_jC_j
$$

Suma ponderada de tiempos de completación.

Los apuntes incluyen estos tres objetivos dentro de $\gamma$.

No confundas:

**$C_{max}$** ≠ suma de tiempos.

Es solo:

> el tiempo en el que termina el último trabajo.


## 23. Complejidad: por qué necesitamos heurísticas

Aquí aparece la razón de fondo del Tema 5.

Para ciertos problemas pequeños o fáciles podemos utilizar algoritmos exactos.

Pero muchos problemas de scheduling son **NP-hard**.

Los algoritmos exactos garantizan el óptimo, pero pueden volverse computacionalmente inviables cuando crece el problema.

Por eso aparecen los heurísticos:

> buscan soluciones buenas en tiempos razonables.

Este contraste entre algoritmos exactos y heurísticos es central en las diapositivas del tema.


## 24. Reglas de prioridad o reglas de despacho

Son reglas sencillas que proporcionan **un orden para secuenciar trabajos u operaciones**.

Cuando una máquina queda disponible:

> se selecciona qué trabajo pendiente procesar según alguna prioridad.

Los apuntes las denominan también **reglas de despacho**.

Aquí vas a tener que memorizar varias asociaciones.


## 25. SPT

**Shortest Processing Time**

Ordenamos por:

$$
p_j \text{ creciente}
$$

Es decir:

> primero el trabajo más corto.

Se utiliza para:

$$
1||\sum C_j
$$

y minimiza la suma de tiempos de completación en ese problema.

Los apuntes derivan esta regla precisamente de que los trabajos colocados primero afectan a más términos de $\sum C_j$.


## 26. WSPT / Regla de Smith

**Weighted Shortest Processing Time**

Ordenar por:

$$
\frac{p_j}{w_j}
$$

**creciente**.

Se utiliza para:

$$
1||\sum w_jC_j
$$

Memoria rápida:

**SPT → $p$**

**WSPT → $p/w$**


## 27. EDD / Regla de Jackson

**Earliest Due Date**

Ordenar por:

$$
d_j \text{ creciente}
$$

Es decir:

> primero el que tiene la fecha de entrega más temprana.

Se utiliza para minimizar:

$$
L_{max}
$$

Los apuntes la presentan como Regla EDD o Regla de Jackson.


## 28. LPT

**Longest Processing Time**

Orden:

$$
p_j \text{ no creciente}
$$

o, dicho de forma sencilla:

> primero los trabajos más largos.

Se usa en el ejemplo de máquinas paralelas para reducir:

$$
C_{max}
$$

Esto es fácil de confundir:

**SPT → cortos primero.**

**LPT → largos primero.**


## 29. Otras reglas

En tus diapositivas aparecen también reglas como:

**SIRO** → seleccionar aleatoriamente.

**ERD** → menor fecha de disponibilidad $r_j$.

**MS** → minimum slack, menor holgura.

**SST** → menor tiempo de setup.

Y en problemas con elegibilidad de máquinas aparece **LFJ**, que prioriza los trabajos menos flexibles.

No intentaría memorizarlas todavía aisladas; durante los tests las iremos fijando mediante situaciones prácticas.


## 30. Heurística vs metaheurística

Esta diferencia es fundamental.

Una **heurística** suele estar más vinculada a un mecanismo concreto para obtener una buena solución.

Una **metaheurística** es un esquema de búsqueda más general que guía heurísticas o búsquedas locales para explorar mejor el espacio de soluciones.

Tus apuntes presentan las metaheurísticas como procedimientos genéricos basados, de una forma u otra, en búsqueda local.

Ejemplos:

- Simulated Annealing;

- Genetic Algorithms;

- Iterated Local Search;

- Iterated Greedy;

- VNS;

- etc.


## 31. Búsqueda local y óptimo local

La búsqueda local:

1. parte de una solución;

2. genera vecinos;

3. busca uno mejor;

4. se mueve hasta él;

5. repite.

Si ya ningún vecino mejora la solución:

> hemos encontrado un **óptimo local respecto a ese vecindario**.

No significa necesariamente óptimo global.

Esta es la principal debilidad o **miopía** de la búsqueda local.

Ejemplo:

Estamos en una montaña pequeña. Todos los pasos cercanos bajan.

Parece que estamos en la cima.

Pero puede existir otra montaña mucho más alta al otro lado del valle.


## 32. Simulated Annealing — SA

**Recocido simulado.**

Es búsqueda local con una diferencia crucial:

> **puede aceptar temporalmente soluciones peores.**

¿Por qué?

Para poder escapar de óptimos locales.

Al comienzo, con una temperatura $T$ alta:

→ hay mayor probabilidad de aceptar empeoramientos.

Conforme el algoritmo se enfría:

→ esa probabilidad disminuye.

El algoritmo utiliza para un empeoramiento $d$ una probabilidad del tipo:

$$
p=e^{-d/T}
$$

Por tanto:

- $T$ alta → mayor aceptación;

- $T$ baja → menor aceptación;

- empeoramiento grande → menor aceptación.

El concepto central del SA en los apuntes es exactamente aceptar peores soluciones con probabilidad decreciente según avanza el enfriamiento.

Parámetros fundamentales:

**Initemp** → temperatura inicial.

**r** → ritmo de enfriamiento.

**Cooling schedule** → forma en que disminuye la temperatura.

**L** → número de iteraciones realizadas a una temperatura determinada.


## 33. Algoritmos genéticos

En vez de trabajar únicamente con una solución, utilizan una **población de soluciones**.

La idea procede de evolución biológica.

Elementos fundamentales:

**Individuo/cromosoma** → una solución.

**Fitness** → calidad de esa solución.

**Selección** → elegir individuos para reproducirse.

**Cruce/crossover** → combinar información de dos soluciones.

**Mutación** → realizar cambios aleatorios.

**Nueva generación** → nuevas soluciones obtenidas.

Idea esencial:

> las soluciones buenas tienen más posibilidades de transmitir características, pero se mantiene diversidad mediante mecanismos como mutación.

Cuando hagamos tests veremos las diferencias con búsqueda local y SA, porque son muy preguntables.


## 34. Iterated Local Search — ILS

Problema:

La búsqueda local llega a un óptimo local y se queda atrapada.

ILS hace:

$$
\text{solución}
\rightarrow
\text{búsqueda local}
\rightarrow
\text{perturbación}
\rightarrow
\text{búsqueda local}
\rightarrow\dots
$$

La **perturbación** modifica la solución para intentar entrar en otra región del espacio.

Pero hay equilibrio:

**perturbación demasiado débil**

→ probablemente volvemos al mismo óptimo local.

**demasiado fuerte**

→ prácticamente hacemos búsqueda aleatoria.

Después existe un **criterio de aceptación**, que decide si conservar la nueva solución.


## 35. Iterated Greedy — IG

Parecida conceptualmente a ILS, pero la perturbación se hace de manera diferente.

IG:

1. toma una solución;

2. **destruye parcialmente** la solución eliminando algunos elementos;

3. vuelve a **reinsertarlos** mediante una heurística constructiva;

4. puede aplicar búsqueda local;

5. decide si acepta el nuevo resultado.

Diferencia muy buena para test:

**ILS → perturba la solución.**

**IG → destruye parcialmente + reconstruye.**


## 36. Calidad de las soluciones heurísticas

Como una heurística **no garantiza optimalidad**, necesitamos comprobar qué tan buena es.

Tus apuntes mencionan:

- comparación con solución óptima;

- comparación con una cota inferior/superior conocida;

- comparación con otros heurísticos.

También aparece la desviación porcentual respecto a la mejor solución conocida:

$$
RPD=
\frac{Heu_{sol}-Best_{sol}}
{Best_{sol}}
\cdot100
$$

En un problema de minimización:

**RPD = 0 %**

→ hemos igualado la mejor solución conocida.

Cuanto mayor sea RPD:

→ peor respecto a esa referencia.


## 37. La idea que conecta TODO el examen

Si tuvieras que reducir ambos temas a una sola lógica sería esta:

**Modelo exacto**

> Describe matemáticamente todas las decisiones y restricciones y busca garantizar el óptimo.
  
**Heurística**

> Sacrifica la garantía de optimalidad para conseguir una buena solución rápidamente.

**Búsqueda local**

> Mejora una solución explorando sus vecinos, pero puede atascarse en un óptimo local.

**Metaheurística**

> Añade mecanismos para explorar de manera más inteligente y evitar ese atasco.

Tus últimas diapositivas resumen precisamente que las metaheurísticas suelen ser más eficaces y generales que las heurísticas, pueden acercarse mucho al óptimo, pero son más complejas y normalmente más lentas que una heurística sencilla, aunque más rápidas que los métodos exactos.

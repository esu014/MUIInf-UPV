**UNIDAD 2 · Integración y manipulación de datos**

**1. Sistemas transaccionales y analíticos**

| | **OLTP: transaccional** | **OLAP: analítico** |
|---|---|---|
| Objetivo | Gestionar operaciones habituales. | Analizar y apoyar decisiones. |
| Datos | Actuales y detallados. | Históricos, detallados y agregados. |
| Organización | Normalizados, evitando redundancia. | Redundancia y precálculos para facilitar consultas. |
| Operaciones | Repetitivas; actualizaciones frecuentes. | Consultas complejas e impredecibles. |
| Respuesta habitual | Milisegundos–segundos. | Segundos–horas. |
| Decisiones y usuarios | Sistemáticas; muchos usuarios. | Estratégicas; menos usuarios. |

Son diferencias del **modelo tradicional**, no reglas absolutas. Los repositorios analíticos también pueden recibir actualizaciones mediante cargas y refrescos.

**2. Data warehouse y OLAP**

Un **data warehouse** organiza datos para el análisis. En el modelo multidimensional:

- **Dimensiones:** perspectivas desde las que analizamos: producto, tienda, tiempo.
- **Medidas:** cantidades que analizamos: importe vendido, unidades.
- **Jerarquías:** niveles de detalle de una dimensión: día → mes → trimestre → año.
- **Datamart:** esquema o subconjunto orientado a un área, como ventas o producción.

Operaciones:

- **Drill-down:** aumentar detalle. Año → trimestre → mes.
- **Roll-up:** agregar y reducir detalle. Mes → trimestre → año.

**OLAP consulta y resume; no infiere patrones por sí mismo.**

- «¿Cuál es el gasto medio de los clientes que se marcharon?» → **consulta/OLAP**.
- «¿Qué clientes se marcharán y qué factores lo predicen?» → **minería de datos**.

**No es obligatorio construir un data warehouse para hacer minería.** Puede resultar demasiado costoso para un proyecto puntual, y quizá necesitemos datos más detallados o fuentes externas.

**3. Fuentes y repositorios**

Los proyectos pueden combinar datos internos con datos externos: demografía, economía, competencia, meteorología, calendarios o tráfico.

Los distintos repositorios o **silos** necesitan conexiones. Las tecnologías nuevas suelen complementar a las anteriores: añadir NoSQL no elimina necesariamente las bases relacionales.

**Reunir los datos en un repositorio no basta:** todavía hay que comprenderlos, limpiarlos, transformarlos y seleccionarlos.

**4. ETL: extracción, transformación y carga**

ETL sirve tanto para la **carga inicial** como para el **refresco posterior**.

| Fase | Qué hace |
|---|---|
| **Extracción** | Obtiene los datos de sus fuentes. |
| **Transformación** | Homogeneiza códigos, formatos, unidades y estructuras. |
| **Carga** | Incorpora los datos al repositorio de destino. |

Herramientas de extracción:

- **SQL y scripts:** bases de datos.
- **API:** acceso ofrecido por una aplicación o servicio.
- **Wrapper:** extracción cuando no hay una API disponible.
- **Databot:** búsqueda y recogida de información en Internet.

Si las fuentes cambian, podemos detectar cambios mediante **comparaciones, marcas temporales, triggers o logs**, o volver a cargar todo.

El **almacenamiento intermedio** permite transformar sin detener las fuentes, guardar metadatos y facilitar la integración.

La carga puede hacerse en **ventanas de baja actividad**, ser incremental y eliminar datos demasiado antiguos para mantener una ventana histórica.

**5. Vista minable**

Es el conjunto que contiene **todas y solo las variables necesarias para el problema, en el formato adecuado**.

Requiere datos **preparados, limpios y seleccionados**, junto con una tarea clara. Para texto, multimedia y otros datos complejos se utiliza también **minable dataset**.

Ejemplos:

- Predecir si un cliente devolverá un crédito → **clasificación**.
- Predecir cuántos televisores se venderán → **regresión**.
- Encontrar tipos de empleados → **clustering**.
- Descubrir productos que se compran juntos → **asociación**.

Clasificación y regresión son **predictivas**; clustering y asociación son **descriptivas**.

**6. Limpieza de datos**

Trata problemas como **valores ausentes, inconsistencias y valores atípicos**.

Posibles actuaciones:

- Mantener los datos si el problema es tolerable.
- Eliminar filas o columnas.
- Sustituir valores por una media o una predicción.
- Separar registros correctos y problemáticos.
- Discretizar.
- Mejorar la política de recogida para futuras ocasiones.

**No hay una solución universal. Un valor atípico no es necesariamente un error.** Eliminar o sustituir requiere interpretar el contexto.

**7. Transformación, selección y reducción**

| Operación | Qué cambia |
|---|---|
| **Crear atributos** | Añade variables derivadas, como deuda/ingresos o población/superficie. El conocimiento del dominio es fundamental. |
| **Discretizar** | Convierte una variable numérica en intervalos o categorías: edad → joven/adulto/mayor. |
| **Numerizar 1→1** | Asigna un número por categoría: bajo/medio/alto → 1/2/3. Puede introducir orden y distancias artificiales. |
| **Numerizar 1→n** | Crea indicadores binarios por categoría: tipo de tarjeta → columnas VISA, Maestro, etc. También aparece la variante n−1. |
| **Normalizar** | Ajusta la escala de valores numéricos. |
| **Seleccionar atributos** | Conserva algunas columnas originales. |
| **PCA** | Transforma las variables originales en componentes y permite reducir dimensión. |
| **Muestrear** | Reduce filas o instancias. |

**PCA frente a selección:** PCA crea nuevas variables; la selección conserva variables originales. Los componentes de PCA están ordenados por varianza explicada y son **no correlacionados** —la diapositiva los llama “independientes”, una simplificación—.

Selección de características:

- **Filter:** selecciona sin utilizar un modelo de minería como evaluador.
- **Wrapper:** utiliza un modelo para evaluar conjuntos de variables.

Direcciones:

- **Vertical:** columnas → selección de características.
- **Horizontal:** filas → muestreo.

Muestreo:

- **Aleatorio simple:** selección aleatoria del conjunto.
- **Estratificado:** selección dentro de los distintos estratos.
- **Por grupos:** selección de grupos completos.
- **Exhaustivo:** incluye todos los casos.

**8. Privacidad, propiedad, ética y seguridad**

Son cuestiones relacionadas, pero diferentes:

- **Propiedad y derechos de uso:** qué podemos hacer con los datos y para qué finalidad se autorizaron.
- **Privacidad:** qué información personal se recoge, infiere o revela.
- **Ética:** si resulta aceptable utilizarla de determinada manera y con qué consecuencias.
- **Seguridad:** protección frente a accesos y usos no autorizados.

Ideas clave:

- **Acceso público no equivale a permiso para cualquier uso.** Los datos abiertos también pueden tener restricciones.
- La personalización requiere información y puede revelar preferencias o situaciones sensibles.
- Hay que valorar tanto el **patrón descubierto** como el **uso y comunicación** de ese patrón.
- **Anonimizar o agregar no garantiza que sea imposible reidentificar.** Los casos de Netflix y AOL ilustran ese riesgo.
- Los datos anonimizados también necesitan seguridad.
- Confiar en una organización incluye valorar si protege adecuadamente lo que almacena.

**9. Visualización de información**

Representa datos gráficamente para facilitar **comparaciones, reconocimiento de patrones y detección de cambios**.

Debe ser legible y permitir aprender algo de los datos. Sirve para resumir grandes conjuntos, mostrar perspectivas y niveles de detalle y comunicar resultados.

**Elegir el gráfico:**

| Gráfico | Uso principal |
|---|---|
| **Líneas** | Evolución sobre un eje ordenado, especialmente tiempo. |
| **Barras** | Comparar valores entre categorías. |
| **Dispersión** | Examinar la relación entre dos variables. |
| **Sectores** | Comparar proporciones entre pocas partes de un total. |
| **Mapas** | Representar información geográfica. |

**10. Tipos de datos y canales visuales**

Primero identificamos el tipo de variable; después elegimos cómo representarla.

- **Nominal:** categorías sin orden: ciudad, marca, continente.
- **Ordinal:** categorías ordenadas sin distancias medibles entre niveles: bajo, medio, alto.
- **Cuantitativa:** magnitudes numéricas: distancia, duración, ingresos.

Canales visuales: **posición X/Y, tamaño, textura, forma, orientación, luminosidad y tono de color**.

Correspondencias importantes:

- **Tono de color:** distingue categorías; no expresa un orden natural.
- **Luminosidad:** sugiere orden: más claro/más oscuro.
- **Tamaño:** sugiere magnitud: mayor tamaño → mayor cantidad.
- **Posición:** permite comparar valores con precisión.

Según la figura de las diapositivas, la precisión perceptiva disminuye aproximadamente así:

**Posición → longitud → ángulo/pendiente → área → volumen → color/densidad.**

Para comparar cantidades con precisión, posición y longitud suelen funcionar mejor que áreas o volúmenes.

**11. Representar varias variables**

- **Una variable:** representar su distribución o sus valores.
- **Dos variables:** por ejemplo, dispersión con una en X y otra en Y.
- **Tres o más:** añadir tamaño, color u otros canales.
- **Muchas variables:** matrices de dispersión y coordenadas paralelas.

Ejemplo: **X/Y = ubicación; color = continente; tamaño = número de medallas**.

**La clave es que cada canal visual represente una variable de forma adecuada y que la imagen siga siendo legible.**
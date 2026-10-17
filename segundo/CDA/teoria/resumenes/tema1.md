**UNIDAD 1 · Introducción a la ciencia de datos**

**1. Ciencia de datos y profesionales**

La **ciencia de datos** estudia cómo extraer conocimiento generalizable de los datos para mejorar decisiones. Se conoce también como **D2K: Data to Knowledge**.

- **Data Mining:** técnicas y herramientas para obtener patrones y modelos.
- **KDD:** descubrimiento de conocimiento; enfatiza el proceso completo.
- **Data Analysis / Analytics:** análisis de datos.
- **Big Data:** problemas cuyas características dificultan tratarlos con herramientas convencionales. **No toda ciencia de datos necesita Big Data ni todo Big Data implica analítica.**

Roles:

- **CIO:** responsable de tecnologías y sistemas de información.
- **Data Manager:** responsable de gestionar bases de datos.
- **CDO:** responsable de la gobernanza y aprovechamiento de la información como activo.
- **Data Scientist:** combina matemáticas, estadística, programación, aprendizaje automático y bases de datos; sabe formular el problema y diseñar soluciones.

**2. El valor de los datos**

Los datos pueden generar valor dentro o fuera de una organización:

| Flujo | Significado | Ejemplo |
|---|---|---|
| **in → in** | Datos propios para beneficio propio. | Predecir compras con el historial de clientes. |
| **out → in** | Datos externos para beneficio propio. | Analizar redes sociales para tomar decisiones. |
| **in → out** | Datos propios que generan valor para terceros. | Ofrecer información de movilidad a otras empresas. |
| **out → out** | Datos externos para generar valor a terceros. | Analizar información pública y vender resultados. |
| **∅ → out** | Recoger nuevos datos para crear valor. | Crear un servicio con información aportada por conductores. |

Se pueden **vender datos o vender conocimiento y servicios derivados**. Los usuarios también producen datos valiosos.

Ejemplos de monetización: monitorización remota, acciones predictivas, recomendaciones, precios personalizados y venta de datos de máquinas.

**3. D2K: datos, conocimiento, procesos y recursos**

Antes de elegir tecnología hay que estudiar **D, K y 2**. El objetivo es obtener conocimiento útil para decidir.

**D: ¿qué datos tenemos?**

- **Procedencia:** internos o externos.
- **Estructura:** estructurados —incluyen tablas, árboles, listas y grafos—; semiestructurados —XML, código—; no estructurados —texto natural—. También multimedia, hipermedia y semánticos.
- **Generador:** personas o máquinas —sensores, registros de actividad, generadores—.
- **Calidad:** representatividad, precisión, ausentes e inconsistencias. **Estar bien registrado no garantiza ser representativo.**
- **Cambio:** estáticos o en flujo/tiempo real.
- **Acumulación:** incrementales —el pasado casi no cambia— o modificables —pueden corregirse datos anteriores—.
- **Acceso:** abiertos, restringidos o personales.
- **Tamaño y complejidad:** importan tanto el número de registros como el de atributos, la regularidad y la posibilidad de muestreo. **Los GB por sí solos no describen la dificultad.**

**K: ¿qué conocimiento buscamos?**

Puede adoptar forma de indicadores estadísticos, reglas, probabilidades o modelos complejos. Su representación puede ser **gráfica, declarativa —reglas— o matemática**.

- **Descriptivo:** permite entender los datos.
- **Predictivo:** permite estimar valores desconocidos.

Propiedades que debemos valorar:

- **Exactitud:** acierta suficientemente.
- **Confiabilidad:** su error está bien estimado y acotado.
- **Equidad:** su comportamiento es adecuado para los grupos protegidos.
- **Comprensibilidad:** podemos entender y revisar el modelo.
- **Explicabilidad:** podemos explicar su comportamiento, incluso si es una caja negra.
- **Trazabilidad:** podemos relacionar resultados con datos y objetivos.
- **Utilidad operativa:** sirve para actuar y decidir.
- **Robustez:** resiste manipulaciones de las entradas.

**Un modelo preciso no es necesariamente comprensible, equitativo ni útil.**

**2: ¿cómo y con qué recursos lo hacemos?**

- **Centralizado o distribuido:** datos y procesamiento pueden estar juntos o repartidos. Puede convenir llevar el procesamiento hasta los datos.
- **Infraestructura propia o nube:** la propia puede quedar infrautilizada o saturarse; la nube facilita ajustar capacidad, con cuestiones de privacidad.
- **Herramientas:** consultas, plataformas numéricas, programación, servicios web o suites gráficas.
- **Responsables:** una persona, un equipo, proveedores externos o crowdsourcing. Cambian coordinación, costes, control y responsabilidades.
- **Frecuencia:** un análisis recurrente justifica más inversión en repositorios y herramientas que uno ocasional.
- **Enfoque:** dirigido por un objetivo concreto o por la exploración de los datos.
- **Usuarios y afectados:** quién utilizará los resultados y qué efectos tendrá la recogida y el uso de información.

**4. Del dato a la decisión**

**Fuentes → integración → repositorio → preparación → vista minable → minería → patrones → evaluación → conocimiento → despliegue → decisiones.**

La **vista minable** contiene los datos preparados para la tarea.

**No siempre hace falta minería de datos:** si bastan agregaciones y consultas, pueden ser suficientes SQL, OLAP y visualización. La minería se utiliza cuando necesitamos inferir patrones o construir modelos.

**5. CRISP-DM**

Metodología **iterativa** de seis fases: se puede volver a fases anteriores.

| Fase | Finalidad y actividades |
|---|---|
| **1. Comprensión del negocio** | Definir el problema, los objetivos y qué resultado sería útil. |
| **2. Comprensión de los datos** | Recoger, describir, explorar y comprobar su calidad. |
| **3. Preparación de los datos** | Seleccionar, limpiar, construir atributos, integrar y dar formato. Obtener la vista minable. |
| **4. Modelado** | Elegir técnica y supuestos, diseñar las pruebas, ajustar parámetros, construir y evaluar técnicamente modelos. |
| **5. Evaluación** | Comprobar si los resultados responden al objetivo del negocio, revisar el proceso y decidir los siguientes pasos. |
| **6. Despliegue** | Utilizar los resultados; planificar implantación, seguimiento y mantenimiento; elaborar informes y revisar el proyecto. |

**Diferencia clave:** evaluar técnicamente un modelo pertenece al modelado; comprobar que resuelve el problema del negocio corresponde a la fase de evaluación.

**Desplegar no exige crear una aplicación:** puede consistir en entregar un informe e incorporar sus conclusiones a las decisiones.

**6. Big Data**

No existe un tamaño universal a partir del cual los datos sean “Big Data”. La dificultad depende de sus características y de los recursos disponibles.

Clasificación de las diapositivas:

| Enfoque | Vs |
|---|---|
| **Big Data 1.0: capacidad** | **Volumen, velocidad, variedad.** |
| **Big Data 2.0: calidad** | Añade **veracidad y variabilidad**. |
| **Big Data 3.0: aplicabilidad** | Añade **valor, volatilidad, versatilidad y visualización**. |

La necesidad de soluciones específicas surge de la **combinación de características**, no únicamente del volumen.

**7. Elegir soluciones**

Tres familias:

- **Infraestructura:** almacenamiento y procesamiento; data warehouses, NoSQL, sistemas distribuidos y nube.
- **Curación:** integración, ETL, limpieza, calidad, metadatos, privacidad, propiedad y seguridad. Consume gran parte del trabajo.
- **Analítica:** SQL, OLAP, visualización, estadística, minería y aprendizaje automático.

**Primero se define el problema y se examinan D, K y 2; después se elige la tecnología.** Un CSV, una consulta o un modelo sencillo pueden bastar. Una solución más compleja solo compensa si aporta una mejora que justifique su coste.
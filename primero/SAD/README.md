# SAD - Sistemas y Aplicaciones Distribuidas (2025-2026)

Este repositorio centraliza todos los materiales, ejercicios prácticos y proyectos desarrollados durante la asignatura de **Sistemas de Aplicaciones Distribuidas** en el curso académico 2025-2026.

## 📂 Contenidos del Repositorio

### 🚀 [Trabajo](./Trabajo/)
Esta carpeta contiene el proyecto principal de la asignatura: el **Agente Orquestador NATS JetStream**.

Se trata de un sistema avanzado de sincronización de datos distribuida con las siguientes capacidades técnicas:
* **Sincronización Multi-bucket**: Gestión dinámica y automática de múltiples almacenes de datos.
* **Estrategia Híbrida de Replicación**: Replicación en tiempo real mediante eventos y ciclo de respaldo de **Anti-Entropía** (cada 5 minutos).
* **Consistencia Eventual (LWW)**: Algoritmo de resolución de conflictos basado en *Last Writer Wins* con desempate determinista por ID de nodo.
* **Autosanación JIT**: Capacidad de creación de infraestructura *Just-In-Time* al detectar tráfico de datos desconocido.
* **Arquitectura de Leafnodes**: Diseñado para operar en entornos con sedes aisladas y conectividad intermitente.

### 📝 [Ejercicios](./Ejercicios/)
Esta carpeta contiene todas las tareas y ejercicios realizados durante las sesiones de clase. Incluye prácticas sobre:
* Configuración de clústeres NATS.
* Uso de Key-Value Stores y JetStream.
* Protocolos de replicación y persistencia de datos.
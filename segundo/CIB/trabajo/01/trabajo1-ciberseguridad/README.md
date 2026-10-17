# Trabajo 1 · Actualidad en ciberseguridad

Plantilla modular en español, clase `report`, con cinco casos independientes. Todos los campos `[PENDIENTE]` y `[texto entre corchetes]` deben sustituirse antes de entregar. No se han seleccionado incidentes ni añadido referencias ficticias.

## Correspondencia con el enunciado

El documento adjunto exige **al menos cinco security issues**, ocurridos a partir del inicio del curso, justificando selección e impacto. Por caso pide tipo de fallo, CVE, CVSS (intentar calcularlo si no está disponible), impacto en la sociedad y prevención o mitigación. El contenido se adapta al caso. El enunciado admite además soluciones o legislación, aunque esta plantilla sigue la elección de cinco incidentes.

La nota «También se puede utilizar incidentes ocurridos en 2022» figura en el original: confirmar con el docente su vigencia antes de usar esa excepción. La fecha de inicio del curso y el plazo de entrega no aparecen en el PDF; introducir los datos oficiales. El plazo de 30 de noviembre mencionado en la conversación no se ha fijado como requisito documental.

El enunciado habla de una sección por incidente. Se utiliza un capítulo por caso, con secciones internas, según la estructura solicitada por el estudiante. La comparación, metodología, análisis crítico y anexos refuerzan el rigor; no implican requisitos adicionales del enunciado ni garantizan una calificación.

## Estructura

- `main.tex`: configuración, datos de portada, índice y orden de inclusión.
- `chapters/01-introduccion.tex` y `02-metodologia.tex`.
- `chapters/03-incidente-1.tex` a `07-incidente-5.tex`.
- `chapters/08-comparativa.tex`, `09-conclusiones.tex` y `10-anexos.tex`.
- `referencias.bib`: base bibliográfica intencionadamente vacía.
- `.gitignore`: excluye resultados de compilación; las fuentes quedan versionadas.

## Compilación

Requiere una distribución TeX con pdfLaTeX, latexmk, Biber, biblatex, babel español, Latin Modern, microtype, geometry, setspace, booktabs, tabularx, longtable, xcolor, fancyhdr, hyperref y bookmark (por ejemplo, TeX Live con sus paquetes LaTeX y de español).

Desde la carpeta que contiene `main.tex`:

```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

Alternativa manual, también necesaria después de añadir las primeras citas:

```sh
pdflatex -interaction=nonstopmode -halt-on-error main.tex
biber main
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

El resultado es `main.pdf`. Sin referencias todavía puede aparecer un aviso de bibliografía vacía; es esperado. En Overleaf, subir la carpeta completa, elegir `main.tex` como documento principal y pdfLaTeX como compilador; el flujo automático gestiona Biber.

Para limpiar auxiliares conservando el PDF: `latexmk -c`. Para eliminarlos junto con el PDF: `latexmk -C`.

## Investigación y citas

1. Completar metadatos, objetivos y periodo de selección.
2. Aplicar criterios de selección y registrar candidatos y descartes.
3. Investigar cada caso con fuentes primarias y contraste independiente.
4. Añadir entradas reales a `referencias.bib`; usar `\cite{clave}` o `\autocite{clave}` junto a la afirmación sustentada. No dejar claves de ejemplo activas.
5. Registrar versión, vector, puntuación y emisor de CVSS. Si falta, intentar una evaluación propia documentada cuando aplique; marcar sus supuestos. Si no aplica, justificarlo. No asignar un CVE inventado.
6. Completar comparación y conclusiones después de los casos. Sustituir el aviso provisional de bibliografía en `main.tex` cuando existan referencias.
7. Buscar `PENDIENTE` y corchetes en todos los archivos; revisar citas, cifras, tablas, enlaces y PDF final. Atribuir herramientas de apoyo según las reglas académicas aplicables.

## Versionado en Git

Copiar esta carpeta al repositorio elegido, incluidos `.gitignore` y `referencias.bib`. Desde su raíz, si aún no es un repositorio:

```sh
git init
git add .
git commit -m "Añadir plantilla del Trabajo 1 de ciberseguridad"
```

Si ya existe un repositorio, omitir `git init` y revisar los cambios antes de añadirlos. El PDF de ejemplo se entrega fuera de esta carpeta; `main.pdf` está ignorado. No se ha creado ningún repositorio ni publicado contenido. Mantener commits pequeños por caso o revisión de fuentes; evitar subir datos personales o evidencias sensibles.

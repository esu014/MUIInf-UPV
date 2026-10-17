# Trabajo 2 · Cifrado de la información

Plantilla modular en español para completar con prácticas y análisis propios. Clase `report`, portada, índice, capítulos con secciones, bibliografía y anexos. Se mantiene el estilo de la plantilla del Trabajo 1.

## Archivos
- `main.tex`: portada, formato y orden de capítulos.
- `chapters/`: introducción, fundamentos, metodología, ficheros, PGP, LUKS, discusión, conclusiones, entrega y anexos.
- `referencias.bib`: bibliografía vacía, sin fuentes ficticias.
- `PENDIENTES.md`: requisitos, decisiones, mejoras y lista de revisión, fuera del PDF.
- `evidencias/`: instrucciones para registrar resultados propios.
- `enunciado.pdf`: copia del enunciado recuperado del chat.
- `.gitignore`: auxiliares y patrones de material privado.

## Compilar
Requiere TeX Live o equivalente con pdfLaTeX, latexmk, Biber, biblatex, babel español, lmodern, geometry, microtype, setspace, booktabs, tabularx, longtable, array, xcolor, fancyhdr, csquotes, hyperref y bookmark.

Desde esta carpeta:
```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

También puede usarse pdfLaTeX, Biber y dos pasadas más de pdfLaTeX. En Overleaf, subir la carpeta y elegir `main.tex` con pdfLaTeX. La bibliografía vacía produce un aviso esperado; cuando añadas citas reales, revisar que Biber se ejecute y no queden referencias sin resolver.

## Completar
1. Revisar `PENDIENTES.md` y editar datos de portada.
2. Consultar fuentes oficiales vigentes antes de elegir herramientas y parámetros; añadir referencias reales y citarlas con `\autocite{clave}`.
3. Ejecutar las prácticas, guardar evidencias y sustituir las instrucciones por análisis propio. No presentar el texto de planificación como resultados.
4. Completar discusión y conclusiones a partir de las pruebas.
5. Retirar todos los avisos PENDIENTE, incluido el de bibliografía, y revisar el PDF final.
6. Entregar por las dos vías exigidas.

## Repositorio
Copiar esta carpeta completa al repositorio elegido, incluidos los archivos ocultos. Revisar los cambios y el material sensible antes de confirmar y subir. No se ha creado ni publicado ningún repositorio, generado claves, modificado discos ni enviado correo. La vista previa se entrega aparte; `main.pdf` está ignorado.

## Alcance de esta entrega
Es una estructura preparada para trabajar y una reconstrucción documentada del contexto disponible, no la recuperación literal de las respuestas anteriores. Las soluciones, los parámetros criptográficos, las pruebas y las fuentes siguen pendientes. La fecha del 30 de noviembre procede de la conversación y requiere confirmación oficial.

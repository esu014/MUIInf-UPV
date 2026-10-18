# Conversión de Markdown a PDF con Pandoc

Guía rápida para compilar archivos Markdown (`.md`) a documentos PDF manteniendo un control preciso sobre los márgenes y la tipografía mediante el motor LaTeX de Pandoc.

---

## 1. Requisitos e Instalación

Para generar los PDFs se requiere **Pandoc** y un entorno base de **LaTeX** (`pdflatex`).

### En Linux (Ubuntu / Debian)
```bash
sudo apt update
sudo apt install pandoc texlive-latex-base texlive-fonts-recommended texlive-extra-utils
```

### En macOS (Homebrew)
```bash
brew install pandoc
brew install --cask basictex
```

---

## 2. Plantilla y Formato del Documento

Para definir el título, tamaño de página y márgenes reducidos sin necesidad de añadir parámetros largos en la terminal, incluye este bloque YAML al inicio de tu archivo `.md`:

```yaml
---
title: "Titulo"
papersize: a4
geometry:
  - top=2cm
  - bottom=2cm
  - left=1.5cm
  - right=1.5cm
---
```

> **Nota:** La indentación de dos espacios dentro de `geometry:` es obligatoria para que el parser YAML interprete correctamente la lista de propiedades.

---

## 3. Comando de Conversión

Ejecuta el siguiente comando en la terminal desde la carpeta donde se encuentra el documento:

```bash
pandoc entrada.md -o salida.pdf
```

### Opciones útiles adicionales

* **Sobrescribir márgenes desde la CLI (sin editar el archivo):**
  ```bash
  pandoc entrada.md -o salida.pdf -V geometry:margin=1.5cm
  ```

* **Añadir numeración a las secciones e índice de contenidos:**
  ```bash
  pandoc entrada.md -o salida.pdf --number-sections --toc
  ```

* **Cambiar el tema de resaltado de código sintáctico:**
  ```bash
  pandoc entrada.md -o salida.pdf --highlight-style=kate
  ```
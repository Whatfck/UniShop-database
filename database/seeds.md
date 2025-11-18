# 🌱 Seeds Database - UniShop (UCC Campus Pasto)

## 📋 Especificaciones para Generación de Seeds

### Usuarios
- **Total:** 21 usuarios (20 estudiantes/profesores + 1 admin)
- **Admin:** `admin@unishop.com` / `password` (sin productos)
- **Estudiantes/Profesores:** 20 usuarios con emails `@campusucc.edu.co`
- **Distribución por carreras:**
  - Ingeniería de Software: 4 usuarios
  - Enfermería: 4 usuarios
  - Derecho: 4 usuarios
  - Medicina: 4 usuarios
  - Odontología: 4 usuarios

### Productos por Usuario
- **Cantidad:** 5 productos por usuario (100 productos totales)
- **Estado:** Todos `ACTIVE`
- **Condición:** Aleatoria (`Nuevo` o `Usado`)
- **Fechas:** Aleatorias entre 1 septiembre 2025 y 12 noviembre 2025
- **Categorías:** Basadas en la carrera del usuario
- **Imágenes:** 5 imágenes aleatorias por producto (URLs de Picsum)

### Contenido por Carrera

#### Ingeniería de Software
- **Libros:** Clean Code, Design Patterns, Algorithms, Database Concepts
- **Equipos:** Laptops, Arduino, Raspberry Pi, calculadoras
- **Software:** Licencias IDE, Office, Docker
- **Precios:** $65.000 - $2.800.000

#### Enfermería
- **Libros:** Fundamentos, Semiología, Farmacología, Microbiología
- **Equipos:** Estetoscopios, tensiómetros, termómetros, kits venopunción
- **Material:** Guantes, jeringas, alcohol gel, maniquíes
- **Precios:** $8.000 - $450.000

#### Derecho
- **Libros:** Teoría Estado, Constitucional, Penal, Procesal
- **Equipos:** Tablets, grabadoras, impresoras
- **Software:** Jurídico SAP, Office 365, bases datos
- **Precios:** $45.000 - $250.000

#### Medicina
- **Libros:** Harrison, Guyton, Robbins, Semiología
- **Equipos:** Estetoscopios, otoscopios, oftalmoscopios
- **Instrumental:** Kits diagnóstico, maniquíes, microscopios
- **Precios:** $20.000 - $450.000

#### Odontología
- **Libros:** Patología Oral, Periodoncia, Endodoncia, Ortodoncia
- **Equipos:** Turbinas, micromotores, radiográficos, autoclaves
- **Instrumental:** Fresadoras, láser, blanqueamiento
- **Precios:** $65.000 - $1.200.000

### Formato de Output
- Generar SQL INSERT statements completos
- Usar IDs secuenciales empezando desde 1
- Fechas en formato `YYYY-MM-DD HH:MM:SS`
- Imágenes: `https://picsum.photos/400/300?random={número}`
- Números random únicos para cada imagen (200-1309)

### Estadísticas Esperadas
- **Usuarios:** 21 totales
- **Productos:** 100 totales
- **Imágenes:** 500 totales
- **Condiciones:** ~50% Nuevo, ~50% Usado
- **Rango precios:** $8.000 - $2.800.000
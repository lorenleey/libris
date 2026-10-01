# Libris

**Libris** es un proyecto desarrollado con **SQL Server 2025** para crear una biblioteca inteligente capaz de realizar búsquedas semánticas, búsquedas Full-Text y recomendaciones personalizadas a partir de los gustos e historial de cada usuario.

El proyecto se plantea como mini proyecto para trabajar contenidos de **DP-800: SQL AI Developer Associate**, intentando dejar primero un **Nivel 2 completamente funcional** y, después, ampliar la solución a **Nivel 3 con RAG**.

## Objetivo

La idea principal es que un usuario no tenga que conocer el título exacto de un libro para encontrar algo que le interese.

Por ejemplo:

> "Quiero una novela de ciencia ficción sobre política y poder en el espacio"

Libris podrá transformar esa consulta en un embedding, compararlo con los embeddings almacenados de los libros y devolver los resultados más relacionados por significado.

Además, el ranking podrá tener en cuenta información del propio usuario, como libros prestados y valoraciones anteriores.

## Arquitectura prevista

```text
                         Usuario
                            |
                     consulta en texto
                            |
                            v
                     SQL Server 2025
                  /                     \
                 /                       \
        Full-Text Search            Vector Search
                 \                       /
                  \                     /
                   ---- Hybrid Search ---
                            |
                           RRF
                            |
                   Personalización
                            |
                     ranking final
                            |
                +-----------+-----------+
                |                       |
          resultados                 contexto RAG
                                        |
                                        v
                                      Caddy
                                        |
                                     Ollama
                                        |
                                        v
                                respuesta del LLM
```

Para la generación de embeddings se utiliza un modelo local ejecutado con Ollama:

```text
SQL Server 2025
      |
      | HTTPS
      v
    Caddy
      |
      | HTTP
      v
    Ollama
      |
      v
 all-minilm
```

## Entorno validado

Actualmente se ha comprobado correctamente:

- SQL Server 2025.
- Base de datos con nivel de compatibilidad **170**.
- Full-Text Search instalado.
- Idioma español disponible para Full-Text Search.
- Ollama funcionando en local.
- Modelo `all-minilm`.
- Embeddings de **384 dimensiones**.
- Caddy funcionando como proxy HTTPS entre SQL Server y Ollama.
- Comunicación desde SQL Server mediante `sp_invoke_external_rest_endpoint`.
- Creación de un `EXTERNAL MODEL` conectado a Ollama.
- Generación de embeddings desde T-SQL con `AI_GENERATE_EMBEDDINGS`.

El modelo actual utiliza vectores:

```sql
VECTOR(384)
```

## Modelo de datos previsto

La base de datos tendrá como mínimo las siguientes entidades:

| Tabla | Función |
| --- | --- |
| `Books` | Catálogo principal de libros y embedding |
| `Authors` | Información de autores |
| `BookAuthors` | Relación N:M entre libros y autores |
| `Genres` | Géneros disponibles |
| `BookGenres` | Relación N:M entre libros y géneros |
| `Members` | Usuarios/socios de la biblioteca |
| `Loans` | Historial de préstamos |
| `Ratings` | Valoraciones realizadas por los usuarios |

El embedding de cada libro se generará a partir de información textual como:

```text
Título
Autor
Género
Sinopsis
```

## Funcionalidades principales

### Diseño y desarrollo SQL

Se implementarán:

- PRIMARY KEY y FOREIGN KEY.
- CHECK y otras constraints necesarias.
- Índices.
- Views.
- Stored Procedures.
- Functions.
- Triggers.
- Datos de prueba suficientes para probar la búsqueda y las recomendaciones.

### T-SQL avanzado

El proyecto incluirá ejemplos de:

- CTE.
- Window Functions.
- JSON.
- Expresiones regulares.
- Fuzzy String Matching.
- Consultas correlacionadas cuando tenga sentido dentro del proyecto.

El fuzzy matching se utilizará principalmente para tolerar errores al buscar autores o títulos.

### Búsqueda Full-Text

Full-Text Search permitirá buscar por contenido textual usando las capacidades lingüísticas de SQL Server.

Se configurará el idioma español para las columnas indexadas.

### Búsqueda vectorial

Los libros almacenarán un embedding generado mediante Ollama y `AI_GENERATE_EMBEDDINGS`.

La búsqueda principal se realizará inicialmente con:

```sql
VECTOR_DISTANCE('cosine', ...)
```

Esto permite hacer una búsqueda exacta sobre un catálogo pequeño sin depender de funcionalidades preview.

Como ampliación se estudiará:

- `CREATE VECTOR INDEX`.
- `VECTOR_SEARCH`.

Estas funciones requieren activar `PREVIEW_FEATURES` en SQL Server 2025, por lo que no forman parte del mínimo necesario para que Libris funcione.

### Búsqueda híbrida

Libris combinará dos rankings:

```text
Full-Text Search
       +
Vector Search
       |
       v
      RRF
       |
       v
ranking combinado
```

Para fusionarlos se utilizará **Reciprocal Rank Fusion (RRF)** en lugar de sumar directamente las puntuaciones de Full-Text y distancia vectorial, ya que ambas utilizan escalas diferentes.

La idea será trabajar por posición:

```text
RRF = 1 / (k + posición)
```

y combinar posteriormente los rankings obtenidos.

### Personalización

Las recomendaciones podrán utilizar como señales:

- Libros prestados anteriormente.
- Valoraciones de cada usuario.
- Géneros mejor valorados.
- Similitud con libros que el usuario ha puntuado positivamente.

Se excluirán de las recomendaciones los libros que corresponda según el caso y se utilizarán CTE y Window Functions para construir el ranking personalizado.

## Seguridad

Se implementarán al menos estos mecanismos:

- Roles y permisos mediante `GRANT`, `DENY` y `REVOKE`.
- Row-Level Security para que cada socio pueda consultar únicamente sus propios préstamos.
- Dynamic Data Masking para proteger información como el email.

Las diferencias entre usuarios se probarán utilizando `EXECUTE AS USER` y `REVERT`.

## IA asistiendo al desarrollo

Durante el desarrollo se utilizará Copilot como apoyo para tareas como:

- Proponer consultas.
- Revisar T-SQL.
- Generar datos de prueba.
- Proponer índices.
- Detectar errores.
- Ayudar con documentación.

Las pruebas relevantes se documentarán indicando:

1. Prompt utilizado.
2. Respuesta de la IA.
3. Qué parte se aceptó.
4. Qué parte se corrigió.
5. Cómo se comprobó el resultado.

## RAG

El objetivo avanzado del proyecto es incorporar una pequeña solución RAG.

El flujo previsto es:

```text
Pregunta
   |
   v
AI_GENERATE_EMBEDDINGS
   |
   v
SQL Server
   |
   v
recuperación de libros relevantes
   |
   v
construcción del contexto
   |
   v
Caddy
   |
   v
LLM local en Ollama
   |
   v
respuesta final
```

La recuperación de documentos y la construcción del contexto se podrán demostrar desde SQL Server aunque finalmente no se desarrolle una interfaz gráfica.

La interfaz tipo chat queda como ampliación opcional.

## Nivel del proyecto

### Nivel 2 - objetivo mínimo

- Diseño de base de datos.
- T-SQL.
- Seguridad.
- Embeddings.
- Tipo `VECTOR`.
- Búsqueda semántica.
- Full-Text Search.
- Búsqueda híbrida.
- Personalización.

### Nivel 3 - objetivo final

Además de lo anterior:

- Retrieval-Augmented Generation (RAG).
- Recuperación de contexto desde SQL Server.
- LLM local mediante Ollama.
- Respuesta generada utilizando los datos recuperados.

## Fases

### Fase 1 - entorno

Configuración y validación de SQL Server 2025, Full-Text Search, Ollama, Caddy y el modelo de embeddings.

**Estado:** completada.

### Fase 2 - base de datos

Creación del modelo relacional, tablas, relaciones, constraints y datos de prueba.

### Fase 3 - objetos T-SQL

Creación de views, procedures, functions, triggers y consultas avanzadas.

### Fase 4 - seguridad

Configuración de usuarios, roles, permisos, RLS y Dynamic Data Masking.

### Fase 5 - embeddings y búsqueda semántica

Generación y almacenamiento de embeddings en SQL Server y búsqueda mediante distancia coseno.

### Fase 6 - búsqueda híbrida y recomendaciones

Implementación de Full-Text Search, RRF y personalización por usuario.

### Fase 7 - RAG

Recuperación de libros relevantes, construcción del contexto y llamada a un LLM local.

### Fase 8 - pruebas y documentación

Pruebas reproducibles, capturas, README, informe técnico y presentación.

## Estructura prevista del repositorio

```text
libris/
|
├── README.md
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_data.sql
│   ├── 04_views.sql
│   ├── 05_functions.sql
│   ├── 06_procedures.sql
│   ├── 07_triggers.sql
│   ├── 08_fulltext.sql
│   ├── 09_security.sql
│   └── 10_indexes.sql
|
├── ai/
│   ├── 01_external_model.sql
│   ├── 02_embeddings.sql
│   ├── 03_vector_search.sql
│   ├── 04_hybrid_search.sql
│   └── 05_rag.sql
|
├── data/
├── tests/
├── docs/
│   └── ai-assisted-log.md
|
└── setup/
    └── Caddyfile
```

La estructura puede cambiar durante el desarrollo según las necesidades reales del proyecto.

## Tecnologías

- SQL Server 2025
- SQL Server Management Studio
- T-SQL
- Full-Text Search
- VECTOR
- Ollama
- all-minilm
- Caddy
- Git
- GitHub
- GitHub Copilot / Copilot en SSMS

## Estado actual

La conexión SQL Server → Caddy → Ollama ya ha sido validada y SQL Server puede generar embeddings correctamente mediante el modelo externo.

El siguiente paso del proyecto es comenzar con el **modelo relacional y la creación de las tablas de Libris**.

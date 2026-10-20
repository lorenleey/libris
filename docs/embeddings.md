# Embeddings en Libris (Bloque E)

Este documento responde a lo que pide el enunciado: qué modelo se usa, con qué
columnas, qué dimensión tiene el vector, cómo se generan y cómo se almacenan.
Completa los apartados marcados con *(rellenar)* cuando hayas ejecutado
`ai/01_generate_embeddings.sql`.

## 1. Modelo utilizado

- Modelo de embeddings: `bge-m3` (multilingüe, más de 100 idiomas), ejecutado en
  local con Ollama.
- Registro en SQL Server 2025: `CREATE EXTERNAL MODEL OllamaBgeM3`
  (tipo `EMBEDDINGS`, formato de API `Ollama`).
- El endpoint es HTTPS (`https://localhost:11435/api/embed`) porque SQL Server solo
  acepta endpoints HTTPS. Un proxy local (Caddy) añade TLS delante de Ollama,
  que escucha en HTTP (puerto 11434).

### Por qué bge-m3 y no all-minilm

La primera versión usó `all-minilm` (384 dimensiones), el modelo del ejemplo
oficial. Con sinopsis en español no distinguía bien el significado: por ejemplo,
para la pregunta "un mundo vigilado donde castigan pensar distinto" devolvía
La mano izquierda de la oscuridad, Don Quijote y Un mago de Terramar, y dejaba
1984 en quinta posición. Con `bge-m3` el primer resultado fue 1984 y el segundo
Fahrenheit 451. La comparación está en `ai/02_compare_embedding_models.sql`.

Resultados de `usp_CompareModels` (top 5 por distancia coseno, 15 libros):

| Pregunta | Libros esperados | all-minilm (384) | bge-m3 (1024) |
|---|---|---|---|
| Novela sobre política y poder en el espacio | Dune y ciencia ficción | Ciencia ficción, pero con un libro de misterio en el top 5; Dune no aparece | Los 5 son ciencia ficción o distopía; Dune no aparece |
| Un mundo vigilado donde castigan pensar distinto | 1984, Fahrenheit 451 | 1984 en 5.ª posición; Fahrenheit 451 no aparece | 1984 en 1.ª y Fahrenheit 451 en 2.ª |
| Detective que resuelve un crimen | Orient Express, El nombre de la rosa, Los hombres que no amaban a las mujeres | 2 de 3 (puestos 1 y 4) | 3 de 3 (puestos 1, 2 y 5) |
| Aventura con magos y dragones | El Hobbit, Un mago de Terramar | 2 de 2 (puestos 1 y 2) | 2 de 2 (puestos 1 y 2) |

Es una prueba cualitativa con 4 preguntas y 15 libros, no un benchmark. Aun así,
`bge-m3` fue igual o mejor en las cuatro y claramente mejor en dos, por lo que se
adopta como modelo definitivo.

*(añade aquí las capturas de la comparación)*

## 2. Columnas que forman el texto

El texto de cada libro se guarda en `Books.EmbeddingText` y combina:

```text
Título: ... . Autor: ... . Géneros: ... . Sinopsis: ...
```

Se construye a partir de `vw_BookCatalog` (título, autores y géneros agrupados) y de
la sinopsis. Así el vector recoge más información semántica que la sinopsis sola.
El texto se conserva para poder auditar y regenerar los embeddings.

## 3. Dimensión del vector

- 1024 dimensiones (`Books.Embedding` es `VECTOR(1024)`, tipo base float32; SQL
  Server admite hasta 1998 con float32).
- Verificado con `VECTORPROPERTY(Embedding, 'Dimensions')`: *(rellenar)*.
- Si se cambia de modelo, hay que cambiar la dimensión de la columna y regenerar
  los vectores (`ai/03_migrate_to_bge_m3.sql` es un ejemplo de esa migración).

## 4. Cómo se generan

Con `AI_GENERATE_EMBEDDINGS`, que envía el texto al modelo externo y devuelve el
vector:

```sql
UPDATE b
SET Embedding = AI_GENERATE_EMBEDDINGS(b.EmbeddingText USE MODEL OllamaBgeM3)
FROM dbo.Books b
WHERE b.EmbeddingText IS NOT NULL AND b.Embedding IS NULL;
```

## 5. Cómo se almacenan

En la columna `Books.Embedding` de tipo `VECTOR(1024)`, junto al resto de datos del
libro. La similitud se calcula con `VECTOR_DISTANCE('cosine', ...)`: menor distancia
significa mayor parecido. Se usa la distancia coseno porque compara la dirección de
los vectores y no su longitud, que es lo habitual con embeddings de texto.

## 6. Evidencias para el informe

- [ ] Captura del `CREATE EXTERNAL MODEL`
- [ ] Captura de la comparación all-minilm frente a bge-m3
- [ ] Captura del contenido de `EmbeddingText` (15 libros)
- [ ] Captura del recuento: 15 libros con embedding y 0 sin embedding
- [ ] Captura de los libros más parecidos a "Dune" *(rellenar con el resultado)*

## 7. Limitaciones observadas

*(rellenar: por ejemplo, necesidad de tener Caddy abierto, problemas de certificado
y cómo se resolvieron, y que con solo 15 libros no es posible crear un índice
vectorial porque requiere al menos 100 filas con vector)*

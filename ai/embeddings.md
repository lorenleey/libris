# Embeddings en Libris (Bloque E)

Este documento responde a lo que pide el enunciado: qué modelo se usa, con qué
columnas, qué dimensión tiene el vector, cómo se generan y cómo se almacenan.
Completa los apartados marcados con *(rellenar)* cuando hayas ejecutado
`ai/01_generate_embeddings.sql`.

## 1. Modelo utilizado

- Modelo de embeddings: `all-minilm`, ejecutado en local con Ollama.
- Registro en SQL Server 2025: `CREATE EXTERNAL MODEL OllamaEmbeddings`
  (tipo `EMBEDDINGS`, formato de API `Ollama`).
- El endpoint es HTTPS (`https://localhost:11435/api/embed`) porque SQL Server solo
  acepta endpoints HTTPS. Un proxy local (Caddy) añade TLS delante de Ollama,
  que escucha en HTTP (puerto 11434).

## 2. Columnas que forman el texto

El texto de cada libro se guarda en `Books.EmbeddingText` y combina:

```text
Título: ... . Autor: ... . Géneros: ... . Sinopsis: ...
```

Se construye a partir de `vw_BookCatalog` (título, autores y géneros agrupados) y de
la sinopsis. Así el vector recoge más información semántica que la sinopsis sola.

## 3. Dimensión del vector

- 384 dimensiones (`Books.Embedding` es `VECTOR(384)`).
- Verificado con `VECTORPROPERTY(Embedding, 'Dimensions')`: *(rellenar)*.
- Si se cambia de modelo, hay que cambiar la dimensión de la columna.

## 4. Cómo se generan

Con `AI_GENERATE_EMBEDDINGS`, que envía el texto al modelo externo y devuelve el
vector:

```sql
UPDATE b
SET Embedding = AI_GENERATE_EMBEDDINGS(b.EmbeddingText USE MODEL OllamaEmbeddings)
FROM dbo.Books b
WHERE b.EmbeddingText IS NOT NULL AND b.Embedding IS NULL;
```

## 5. Cómo se almacenan

En la columna `Books.Embedding` de tipo `VECTOR(384)`, junto al resto de datos del
libro. La similitud se calcula con `VECTOR_DISTANCE('cosine', ...)`: menor distancia
significa mayor parecido. Se usa la distancia coseno porque compara la dirección de
los vectores y no su longitud, que es lo habitual con embeddings de texto.

## 6. Evidencias para el informe

- [ ] Captura del `CREATE EXTERNAL MODEL`
- [ ] Captura del primer embedding generado
- [ ] Captura del contenido de `EmbeddingText` (15 libros)
- [ ] Captura del recuento: 15 libros con embedding y 0 sin embedding
- [ ] Captura de los libros más parecidos a "Dune" *(rellenar con el resultado)*

## 7. Limitaciones observadas

*(rellenar: por ejemplo, calidad con sinopsis en español, necesidad de tener Caddy
abierto, problemas de certificado y cómo se resolvieron)*

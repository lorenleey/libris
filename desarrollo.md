

## Fase 6 - Pruebas:


Se decidió a la hora de llegar a la fase 6: test, cambiar el modelo de ollama que estamos usando para las busquedas semánticas a `bge-m3` ya que este sí es un modelo lingual con más de 100 idiomas y esto nos garantiza mayor certeza al comparar y recomendar libros semejantes a descripciones o entre sí. 

``` 
ollama pull bge-m3
$r = Invoke-RestMethod -Uri https://localhost:11435/api/embed -Method Post -ContentType 'application/json' -Body '{"model":"bge-m3","input":"hola"}'
$r.embeddings[0].Count
``` 

Para esto fue necesario transformar nuestros embeddings de VECTOR(384) a VECTOR(1024) que se pudo llevar a cabo ejecutando (ai/01_compare_embedding_models.sql)
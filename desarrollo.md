

## Fase 6 - Pruebas:


Se decidió a la hora de llegar a la fase 6: test, cambiar el modelo de ollama que estamos usando para las busquedas semánticas a `bge-m3` ya que este sí es un modelo lingual con más de 100 idiomas y esto nos garantiza mayor certeza al comparar y recomendar libros semejantes a descripciones o entre sí. 

``` 
ollama pull bge-m3
$r = Invoke-RestMethod -Uri https://localhost:11435/api/embed -Method Post -ContentType 'application/json' -Body '{"model":"bge-m3","input":"hola"}'
$r.embeddings[0].Count
``` 

Para esto fue necesario transformar nuestros embeddings de VECTOR(384) a VECTOR(1024) que se pudo llevar a cabo ejecutando (ai/01_compare_embedding_models.sql)

Ficheros actualizados: `02_create_tables.sql`
                        `03_generate_embeddings_bge_m3.sql` 

# Libris · Fase 7: RAG local

## Qué construye

SQL Server recibe una pregunta, genera su embedding con `OllamaBgeM3`
(BGE-M3, 1024 dimensiones), recupera los cinco libros más próximos por distancia
coseno y construye un contexto. Ese contexto y la pregunta se envían al modelo
de chat de Ollama mediante Caddy. La respuesta debe apoyarse en las sinopsis y
citar los identificadores `[Libro N]` de las fuentes recuperadas.

Aquí se utiliza recuperación vectorial exacta, sin personalización ni RRF.
La búsqueda híbrida de fase 6 se conserva como funcionalidad independiente.
No se necesita índice vectorial ni activar nuevas funciones preview.

## Preparación y orden

1. Completar la migración a BGE-M3 y comprobar que los 15 libros tienen sus
   vectores BGE-M3 de 1024 dimensiones. No basta con cambiar el tamaño de columna.
2. Tener `OllamaBgeM3` registrado con el modelo `bge-m3`, la vista
   `dbo.vw_BookCatalog` y el certificado HTTPS ya validados.
3. Arrancar Ollama y Caddy. Su configuración debe reenviar `/api/chat` además
   de `/api/embed`, por ejemplo un reverse proxy para todas las rutas.
4. Descargar un modelo de chat. El ejemplo configurable es:

```powershell
ollama pull qwen2.5:3b
ollama list
```

Qwen2.5 admite español; la variante 3B publicada en Ollama ocupa aproximadamente
1,9 GB de descarga. El consumo de memoria real es mayor y comparte recursos con
SQL Server y BGE-M3. Es una elección inicial de prueba; el rendimiento se mide
sobre el equipo de la demo. Se puede cambiar `@ChatModel` sin regenerar embeddings.

Probar el endpoint completo antes de ejecutar SQL:

```powershell
$body = @{
    model = 'qwen2.5:3b'
    stream = $false
    messages = @(@{ role = 'user'; content = 'Responde en español: hola.' })
    options = @{ num_predict = 40; num_ctx = 4096 }
    keep_alive = '0'
} | ConvertTo-Json -Depth 5

$r = Invoke-RestMethod -Uri 'https://localhost:11435/api/chat' `
    -Method Post -ContentType 'application/json; charset=utf-8' `
    -Body ([System.Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 230
$r.message.content
```

5. En SSMS, ejecutar `ai/03_rag.sql` completo como dbo.
6. Ejecutar `tests/fase7_tests.sql` POR BLOQUES: primero 0–2 (recuperación),
   después 3–5 (chat). No se necesita repetir la instalación de las tablas.

La instalación usa `CREATE OR ALTER`, no ejecuta chats, no altera los datos
existentes ni concede permisos. La demo está pensada para dbo. No basta con
conceder EXECUTE al socio para habilitar REST; esto necesita un diseño de permisos
específico. Se requiere `EXECUTE ANY EXTERNAL ENDPOINT` para la llamada REST y la
configuración `external rest endpoint enabled = 1`, normalmente ya activada en
la fase de entorno. No se cambian automáticamente desde este paquete.

## Objetos y uso

- `usp_GetRAGContext`: genera el embedding, recupera fuentes y devuelve el contexto
  y los documentos JSON en parámetros OUTPUT. No necesita el modelo de chat.
- `usp_AskLibris`: llama al anterior, construye JSON correctamente escapado,
  consulta `/api/chat` y devuelve la respuesta por OUTPUT y como resultado.
- `@ShowEvidence = 1`: muestra pregunta, fuentes, contexto, petición y respuesta.
- `@Top`: 1–5 libros; `@MaxTokens`: 64–1200; `@Timeout`: 1–230 segundos.
- `stream = false`: recibir un solo JSON en vez de fragmentos de streaming.
- `keep_alive = '0'`: liberar el modelo de chat después de responder; reduce
  memoria retenida, pero la siguiente llamada puede tardar más en cargarlo.

```sql
DECLARE @respuesta NVARCHAR(MAX);
EXEC dbo.usp_AskLibris
    @Question = N'¿Qué libros con magos y aventuras me recomiendas?',
    @Answer = @respuesta OUTPUT,
    @ChatModel = N'qwen2.5:3b',
    @ShowEvidence = 1;
```

Para leer textos extensos, SSMS > Resultados en texto (Ctrl+T) y ampliar el máximo
de caracteres por columna en las opciones de resultados; la petición JSON o el
contexto pueden truncarse solo en la visualización. OPENJSON extrae la respuesta
como NVARCHAR(MAX), evitando el límite habitual de JSON_VALUE para texto largo.

## Evidencias y criterio de cierre

Guardar una captura legible de: pregunta, tabla de fuentes con sus distancias,
contexto, petición (incluido modelo), respuesta y citas. Comprobar manualmente:

- Cada cita existe en las fuentes de esa llamada.
- Los títulos, autores, disponibilidad y explicaciones corresponden a los datos.
- Una pregunta fuera del contenido produce abstención, sin horarios inventados.
- No aparecen datos de socios: no se recuperan esas tablas para el contexto.
- `MotivoFin = length` indica posible respuesta cortada; reducir longitud pedida
  o aumentar `@MaxTokens` dentro del rango, y volver a evaluar.

Una respuesta no vacía confirma integración, no exactitud: la evaluación del
contenido y de sus citas sigue siendo necesaria.

## Límites y errores

- Es un catálogo de 15 sinopsis, no los textos completos de los libros.
- Se recupera un top K sin umbral calibrado: también habrá candidatos para
  preguntas ajenas al catálogo. La abstención se solicita en el prompt; no está
  garantizada por el SQL. No se demuestra exhaustividad de todo el catálogo.
- Las instrucciones de citar y no inventar reducen errores, no los eliminan.
- Este RAG no usa historial conversacional, recomendaciones personales ni
  registra preguntas en SearchHistory (su CHECK admite solo texto/vectorial/hibrida).
- HTTP 404: revisar `ollama list` y el nombre exacto de `@ChatModel`.
- Error de modelo externo: comprobar el nombre `OllamaBgeM3`; cambiarlo en
  `USE MODEL` si la migración conservó otro nombre para BGE-M3.
- Timeout: precargar el chat con la prueba PowerShell, reducir @Top o
  @MaxTokens, y revisar RAM. No subir @Timeout por encima de 230.
- Certificado o conexión: comprobar Caddy y la confianza del servicio SQL Server.
- La respuesta REST está envuelta por SQL Server en `result`; la extracción
  usa `$.result.message.content`, no `$.message.content`.

## Validación del paquete

Revisión estática de las entradas, dimensiones, JSON, rutas de extracción y
códigos de error. No se ha ejecutado en tu instancia de SQL Server ni en tu
Ollama: la validación real se realiza con los tests adjuntos.

## Referencias oficiales

- https://learn.microsoft.com/sql/relational-databases/system-stored-procedures/sp-invoke-external-rest-endpoint-transact-sql?view=sql-server-ver17
- https://docs.ollama.com/api/chat
- https://ollama.com/library/qwen2.5:3b

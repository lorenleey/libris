# Libris · interfaz de biblioteca

1. Detén Streamlit con Ctrl+C.
2. Sustituye app.py y copia la carpeta .streamlit junto a él. Conserva tu .env actual.
3. Desde esa carpeta ejecuta: python -m streamlit run app.py

Incluye requirements.txt y env.example como referencias; no incluye credenciales.

La cabecera, estantería y colores se dibujan con HTML y CSS: no requieren imágenes ni fuentes externas. Los selectores CSS de Streamlit pueden necesitar ajustes si cambia su estructura interna.

Cada pregunta es independiente: el historial visual no se envía al modelo. La conexión y el cursor se cierran al finalizar cada petición. Los resultados se identifican por sus columnas, incluso si vienen vacíos. Se conserva la llamada SQL parametrizada a usp_AskLibris.

Validación: sintaxis Python y prueba de interfaz con SQL simulado. La conexión a tu SQL Server, Ollama y Caddy debe verificarse en tu equipo.

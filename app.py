"""
Libris - Interfaz de chat para el RAG (usp_AskLibris).

Toda la lógica (recuperación, contexto, llamada al LLM) vive en SQL Server.
Este script solo llama al procedimiento, reparte sus resultsets y los pinta.
No hace falta leer el parámetro OUTPUT @Answer: la última consulta que
hace usp_AskLibris ya devuelve la respuesta en la columna "Respuesta".

Ejecutar:
    pip install -r requirements.txt
    streamlit run app.py

Requiere SQL_CONN_STRING en el entorno (ver .env.example) y, para que el
RAG funcione, Ollama y Caddy en marcha (igual que en SSMS).
"""
import os
from pathlib import Path
from time import perf_counter

import pyodbc
import streamlit as st
from dotenv import load_dotenv

load_dotenv(Path(__file__).with_name(".env"))

CONN_STRING = os.environ.get("SQL_CONN_STRING")
DEFAULT_CHAT_MODEL = os.environ.get("LIBRIS_CHAT_MODEL", "qwen2.5:3b")

# Resultsets que devuelve usp_AskLibris cuando @ShowEvidence = 1
# (viene de su llamada interna a usp_GetRAGContext + sus propias SELECT):
#   0: Pregunta, ModeloEmbedding
#   1: BookId, Title, Authors, Genres, DistanciaCoseno, IsAvailable   <- documentos
#   2: ContextoRecuperado                                            <- contexto
#   3: ModeloChat, PeticionEnviada                                   <- payload enviado
#   4: Pregunta, ModeloSolicitado, ModeloRespondio, Respuesta, ...   <- respuesta final
IDX_DOCUMENTOS = 1
IDX_CONTEXTO = 2
IDX_RESPUESTA_FINAL = -1

st.set_page_config(page_title="Libris · tu próxima lectura", page_icon="📖", layout="centered")
st.markdown("""
<style>
.stApp {background:#fff2d9;color:#421c19;}
h1,h2,h3 {font-family:Georgia,'Times New Roman',serif!important;color:#421c19!important;}
[data-testid="stSidebar"] {background:#ead8b8;border-right:1px solid #c7a77b;}
[data-testid="stHeader"] {background:transparent;}
[data-testid="stChatMessage"] {background:#fff9ee;border:1px solid #dfc7a2;border-radius:8px;padding:1.3rem;}
[data-testid="stBottom"] > div {background:#fff2d9;}
.stButton > button {border:1px solid #9d6451;border-radius:5px;background:#fff9ee;color:#57261f;}
.stButton > button:hover {border-color:#84372e;background:#f1dfc2;color:#421c19;}
.hero {background:#421c19;border:10px solid #84372e;border-top:18px solid #84372e;color:#fff2d9;padding:34px 26px 0;text-align:center;box-shadow:0 4px 0 #b46b49;margin:8px 0 30px;}
.hero h1 {font-family:Georgia,serif!important;font-size:76px!important;color:#fff2d9!important;letter-spacing:-3px;margin:0;line-height:1.15;}
.hero p {color:#f2dcb8;font-size:16px;margin:14px 0 28px;}
.eyebrow {font-size:11px;letter-spacing:4px;text-transform:uppercase;color:#ddae71;}
.shelf {display:flex;align-items:flex-end;justify-content:center;gap:5px;border-bottom:9px solid #9b4839;height:62px;margin:0 -26px;overflow:hidden;}
.book {width:20px;height:43px;background:#bd4337;border-top:3px solid #f9dfac;border-bottom:5px solid #f9dfac;box-shadow:inset 3px 0 #ffffff22;}
.book:nth-child(3n) {height:52px;background:#447b8a;}
.book:nth-child(3n+1) {height:39px;background:#8d579a;}
.book:nth-child(4n) {height:48px;background:#8c8533;}
.book:nth-child(5n) {background:#d68b40;transform:rotate(5deg);margin:0 3px;}
.intro {font-family:Georgia,serif;font-size:25px;text-align:center;margin:12px 0 6px;}
.note {font-size:13px;text-align:center;color:#795b4b;margin-bottom:24px;}
@media(max-width:600px) {.hero h1 {font-size:56px!important;}.hero {padding-top:25px;}}
</style>
""", unsafe_allow_html=True)
st.markdown('<div class="hero"><div class="eyebrow">biblioteca personal</div><h1>Libris</h1><p>Hay un libro para lo que tienes en mente.</p><div class="shelf">' + '<span class="book"></span>' * 23 + '</div></div>', unsafe_allow_html=True)

if not CONN_STRING:
    st.error("Falta SQL_CONN_STRING. Copia .env.example a .env y complétalo.")
    st.stop()


def get_connection():
    cnxn = pyodbc.connect(CONN_STRING, autocommit=True)
    cnxn.timeout = 300  # segundos; el modelo de chat puede tardar
    return cnxn


def ask_libris(question: str, chat_model: str, top: int):
    """Llama a usp_AskLibris y devuelve todos sus resultsets."""
    connection = get_connection()
    cursor = None
    try:
        cursor = connection.cursor()
        cursor.execute("""
            SET NOCOUNT ON;
            DECLARE @Answer NVARCHAR(MAX);
            EXEC dbo.usp_AskLibris
                @Question = ?, @Answer = @Answer OUTPUT,
                @ChatModel = ?, @Top = ?, @ShowEvidence = 1;
        """, (question, chat_model, top))
        resultsets = []
        while True:
            if cursor.description:
                columns = [c[0] for c in cursor.description]
                resultsets.append((set(columns), [dict(zip(columns, row)) for row in cursor.fetchall()]))
            if not cursor.nextset():
                break
        return resultsets
    finally:
        try:
            if cursor is not None:
                cursor.close()
        finally:
            connection.close()


def extract_results(resultsets):
    def find(required):
        for columns, rows in reversed(resultsets):
            if required <= columns:
                return rows
        raise ValueError("SQL no devolvió las columnas esperadas: " + ", ".join(sorted(required)))
    documents = find({"BookId", "Title"})
    context_rows = find({"ContextoRecuperado"})
    final_rows = find({"Respuesta"})
    if not final_rows or not final_rows[0]["Respuesta"]:
        raise ValueError("El procedimiento devolvió una respuesta vacía.")
    context = context_rows[0]["ContextoRecuperado"] if context_rows else ""
    return documents, context, final_rows[0]["Respuesta"]


if "history" not in st.session_state:
    st.session_state.history = []

with st.sidebar:
    st.header("Tu rincón de lectura")
    st.write("Describe una historia, un tema o el tipo de libro que te apetece descubrir.")
    top = st.slider("Libros que consultar", min_value=1, max_value=5, value=5)
    with st.expander("Configuración"):
        chat_model = st.text_input("Modelo de chat", value=DEFAULT_CHAT_MODEL)
        st.caption("Requiere Ollama y Caddy en marcha.")
    if st.button("Empezar de nuevo", use_container_width=True):
        st.session_state.history = []
        st.rerun()
    st.caption("Cada pregunta se consulta de forma independiente. El historial permanece durante esta sesión.")


def render_evidence(documents, context):
    with st.expander("Libros consultados y contexto"):
        st.markdown("**En las estanterías**")
        st.dataframe(documents, use_container_width=True, hide_index=True)
        st.markdown("**Contexto enviado al modelo**")
        st.text(context)


suggestion = None
if not st.session_state.history:
    st.markdown('<div class="intro">¿Qué te apetece leer?</div><div class="note">Empieza con una idea. Libris buscará en su catálogo.</div>', unsafe_allow_html=True)
    examples = ["Una novela de fantasía", "Misterio y suspense", "Un viaje inolvidable"]
    for column, example in zip(st.columns(3), examples):
        if column.button(example, use_container_width=True):
            suggestion = "Recomiéndame un libro sobre: " + example

# Historial de la sesión
for turn in st.session_state.history:
    with st.chat_message("user"):
        st.write(turn["question"])
    with st.chat_message("assistant"):
        if turn.get("error"):
            st.error(turn["error"])
        else:
            st.write(turn["answer"])
            render_evidence(turn["documents"], turn["context"])

question = st.chat_input("Cuéntame qué te gustaría encontrar…", max_chars=1000) or suggestion
if question:
    with st.chat_message("user"):
        st.write(question)

    with st.chat_message("assistant"):
        with st.spinner("Consultando las estanterías y preparando tu recomendación…"):
            try:
                started = perf_counter()
                resultsets = ask_libris(question, chat_model, top)
                documents, context, answer = extract_results(resultsets)
                elapsed = perf_counter() - started

                st.write(answer)
                st.caption(f"Consulta completada en {elapsed:.1f} s")
                render_evidence(documents, context)

                st.session_state.history.append(
                    {
                        "question": question,
                        "answer": answer,
                        "documents": documents,
                        "context": context,
                    }
                )
            except (pyodbc.Error, IndexError, KeyError, ValueError) as exc:
                error_message = str(exc)
                st.error(
                    "No se pudo responder. Comprueba que Ollama y Caddy estén en "
                    f"marcha, y que el modelo '{chat_model}' esté descargado.\n\n"
                    f"Detalle: {error_message}"
                )
                st.session_state.history.append(
                    {"question": question, "error": error_message}
                )

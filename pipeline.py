"""Pipeline ETL de StreamPlus: reproducciones.csv -> DuckDB -> tabla_final."""

from pathlib import Path

import duckdb

# Rutas absolutas, calculadas a partir de la ubicación de este archivo.
# Así el pipeline funciona sin importar desde qué carpeta se ejecute
# (por ejemplo, desde Airflow).
BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "pipeline.duckdb"
SQL_DIR = BASE_DIR / "consultas"
CSV_PATH = BASE_DIR / "data" / "reproducciones.csv"


def ejecutar_sql(nombre):
    """Lee consultas/<nombre>.sql y lo ejecuta sobre la base DuckDB."""
    sql = (SQL_DIR / f"{nombre}.sql").read_text(encoding="utf-8")
    # extract.sql usa una ruta relativa; se cambia por la absoluta.
    sql = sql.replace("data/reproducciones.csv", CSV_PATH.as_posix())

    con = duckdb.connect(str(DB_PATH))
    try:
        con.execute(sql)
    finally:
        con.close()


def extraer_y_cargar():
    """Pasos 1 y 2: lee el CSV y lo carga tal cual en raw_reproducciones."""
    ejecutar_sql("extract")


def validar():
    """Pasos 3 y 4: aplica las reglas y separa validos / rechazados."""
    ejecutar_sql("validar")


def limpiar():
    """Paso 5: corrige los rechazados y arma rechazados_limpios."""
    ejecutar_sql("limpiar")


def unir():
    """Paso 6: une validos + rechazados_limpios en tabla_final."""
    ejecutar_sql("unir")


def responder_preguntas():
    """Paso 7: crea las tablas respuesta_1 ... respuesta_5."""
    ejecutar_sql("preguntas")


def mostrar_resumen():
    """Imprime cuántas filas dejó cada etapa."""
    con = duckdb.connect(str(DB_PATH), read_only=True)
    try:
        for tabla in ["raw_reproducciones", "validos", "rechazados",
                      "rechazados_limpios", "tabla_final"]:
            filas = con.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]
            print(f"{tabla}: {filas} filas")
    finally:
        con.close()


def main():
    pasos = [
        ("extraer y cargar", extraer_y_cargar),
        ("validar", validar),
        ("limpiar", limpiar),
        ("unir", unir),
        ("responder preguntas", responder_preguntas),
    ]
    for nombre, funcion in pasos:
        print(f"-> {nombre}...")
        funcion()
    print("Pipeline terminado.\n")
    mostrar_resumen()


if __name__ == "__main__":
    main()
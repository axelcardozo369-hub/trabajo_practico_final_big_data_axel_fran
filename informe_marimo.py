import marimo

__generated_with = "0.25.2"
app = marimo.App(width="medium")


@app.cell
def _():
    return


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell
def _():
    import duckdb

    # Base que genera pipeline.py (solo lectura: cerrar el notebook antes de
    # volver a correr el pipeline, porque DuckDB bloquea el archivo).
    con = duckdb.connect(
        "pipeline.duckdb",
        read_only=True,
    )
    return (con,)


@app.cell
def _(mo):
    mo.md(r"""
    ### 1. ¿Cuántos minutos se vieron por género?
    """)
    return


@app.cell
def _(con, mo):
    _df = mo.sql(
        f"""
        SELECT
            genero,
            sum(minutos_vistos) AS minutos_totales
        FROM tabla_final
        GROUP BY genero
        ORDER BY minutos_totales DESC;
        """,
        engine=con
    )
    return


@app.cell
def _(mo):
    mo.md(r"""
    Los primeros 3 generos con los minutos mas visto son: comedia con 49.320 minutos, comedia con 44.070 y terror con 25.453
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ### 2. ¿Cuáles son los 5 títulos más vistos (por cantidad de reproducciones)?
    """)
    return


@app.cell
def _(con, mo):
    _df = mo.sql(
        f"""
        SELECT
            titulo,
            count(*) AS reproducciones
        FROM tabla_final
        GROUP BY titulo
        ORDER BY reproducciones DESC, titulo
        LIMIT 5;
        """,
        engine=con
    )
    return


@app.cell
def _(mo):
    mo.md(r"""
    Los 5 titulos mas vistos son Comedia Familiar, Stranger Cosas, La Casa de Papel, Noche de Terror y El Gran Heist. La que mas reproducciones tiene es Stranger Cosas con 268 reproducciones.
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ### 3. ¿Cuántos usuarios distintos hay por plan?
    """)
    return


@app.cell
def _(con, mo):
    _df = mo.sql(
        f"""
        SELECT
            plan,
            count(DISTINCT id_usuario) AS usuarios_distintos
        FROM tabla_final
        GROUP BY plan
        ORDER BY usuarios_distintos DESC;
        """,
        engine=con
    )
    return


@app.cell
def _(mo):
    mo.md(r"""
    Se puede ver que el plan basico tiene 433 usuarios, el estandar 413 y el premiun con 368.
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ### 4. ¿Cuál es el dispositivo más usado?
    """)
    return


@app.cell
def _(con, mo):
    _df = mo.sql(
        f"""
        SELECT
            dispositivo,
            count(*) AS reproducciones
        FROM tabla_final
        GROUP BY dispositivo
        ORDER BY reproducciones DESC
        LIMIT 5;
        """,
        engine=con
    )
    return


@app.cell
def _(mo):
    mo.md(r"""
    El dispositivo mas usado es la Smart_tv
    """)
    return


@app.cell
def _(mo):
    mo.md(r"""
    ### 5. ¿Cuál es el promedio de minutos vistos por tipo de contenido?
    """)
    return


@app.cell
def _(con, mo):
    _df = mo.sql(
        f"""
        SELECT
            tipo_contenido,
            round(avg(minutos_vistos), 2) AS promedio_minutos
        FROM tabla_final
        GROUP BY tipo_contenido
        ORDER BY promedio_minutos DESC;
        """,
        engine=con
    )
    return


@app.cell
def _(mo):
    mo.md(r"""
    El promedio de minutos vistos por contenido son: pelicula 91,77, documental 89,81 y serie con 89,66
    """)
    return


if __name__ == "__main__":
    app.run()

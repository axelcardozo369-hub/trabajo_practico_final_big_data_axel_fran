"""DAG de Airflow: corre el pipeline ETL de StreamPlus todos los días a las 2:00 AM."""

import sys
from pathlib import Path

import pendulum
from airflow.sdk import dag, task

# Este archivo vive en <proyecto>/dags/ y pipeline.py en <proyecto>/.
# Se agrega la carpeta del proyecto al path para poder importarlo.
PROJECT_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_DIR))

import pipeline  # noqa: E402


# Cada función del ETL se convierte en una tarea con el decorador @task.
@task
def extraer_y_cargar():
    pipeline.extraer_y_cargar()


@task
def validar():
    pipeline.validar()


@task
def limpiar():
    pipeline.limpiar()


@task
def unir():
    pipeline.unir()


@task
def responder_preguntas():
    pipeline.responder_preguntas()


@dag(
    dag_id="pipeline_streamplus",
    # Con la zona horaria de Argentina, "2:00" es hora local y no UTC.
    start_date=pendulum.datetime(2026, 11, 1, tz="America/Argentina/Buenos_Aires"),
    schedule="0 2 * * *",   # minuto 0, hora 2, todos los días
    catchup=False,
    max_active_runs=1,
    
)
def main():
    extraccion = extraer_y_cargar()
    validacion = validar()
    limpieza = limpiar()
    union = unir()
    preguntas = responder_preguntas()

    extraccion >> validacion >> limpieza >> union >> preguntas


main()
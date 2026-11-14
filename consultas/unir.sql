CREATE OR REPLACE TABLE tabla_final AS
WITH unidos AS (
    SELECT
        trim(id_reproduccion)           AS id_reproduccion,
        CAST(fecha AS DATE)             AS fecha,
        CAST(id_usuario AS INTEGER)     AS id_usuario,
        plan,
        titulo,
        tipo_contenido,
        genero,
        CAST(minutos_vistos AS INTEGER) AS minutos_vistos,
        dispositivo,
        pais
    FROM validos

    UNION ALL

    SELECT
        id_reproduccion, fecha, id_usuario, plan, titulo,
        tipo_contenido, genero, minutos_vistos, dispositivo, pais
    FROM rechazados_limpios
)
SELECT *
FROM unidos
QUALIFY row_number() OVER (PARTITION BY id_reproduccion ORDER BY fecha) = 1;
CREATE OR REPLACE TABLE validacion AS
SELECT
    *,
    concat_ws('; ',
        CASE WHEN id_reproduccion IS NULL OR trim(id_reproduccion) = ''
             THEN 'id_no_nulo' END,
        CASE WHEN row_number() OVER (PARTITION BY id_reproduccion
                                     ORDER BY fecha, id_usuario, titulo) > 1
             THEN 'id_unico' END,
        CASE WHEN try_strptime(fecha, '%Y-%m-%d') IS NULL
             THEN 'fecha_valida' END,
        CASE WHEN try_cast(id_usuario AS INTEGER) IS NULL
             THEN 'usuario_valido' END,
        CASE WHEN plan IS NULL OR plan NOT IN ('basico','estandar','premium')
             THEN 'plan_permitido' END,
        CASE WHEN tipo_contenido IS NULL OR tipo_contenido NOT IN ('pelicula','serie','documental')
             THEN 'tipo_permitido' END,
        CASE WHEN try_cast(minutos_vistos AS INTEGER) IS NULL OR try_cast(minutos_vistos AS INTEGER) <= 0
             THEN 'minutos_positivos' END,
        CASE WHEN dispositivo IS NULL OR dispositivo NOT IN ('smart_tv','celular','tablet','notebook')
             THEN 'dispositivo_permitido' END,
             CASE WHEN titulo IS NULL OR trim(titulo) = ''
             THEN 'titulo_no_nulo' END,
        CASE WHEN genero IS NULL OR trim(genero) = ''
             THEN 'genero_no_nulo' END,
        CASE WHEN pais IS NULL OR trim(pais) = ''
             THEN 'pais_no_nulo' END
    ) AS motivo_rechazo
FROM raw_reproducciones;

CREATE OR REPLACE TABLE validos AS
SELECT * EXCLUDE (motivo_rechazo)
FROM validacion
WHERE motivo_rechazo = '';

CREATE OR REPLACE TABLE rechazados AS
SELECT *
FROM validacion
WHERE motivo_rechazo <> '';
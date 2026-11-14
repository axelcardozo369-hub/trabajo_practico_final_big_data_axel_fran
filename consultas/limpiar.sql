    CREATE OR REPLACE TABLE rechazados_limpios AS
WITH

-- Catálogo de títulos: el tipo y el género de cada título, sacado de las
-- filas que sí los tienen. mode() devuelve el valor más frecuente.
catalogo AS (
    SELECT
        trim(titulo)                                   AS titulo,
        mode(nullif(lower(trim(tipo_contenido)), ''))  AS tipo_contenido,
        mode(nullif(lower(trim(genero)), ''))          AS genero
    FROM raw_reproducciones
    WHERE titulo IS NOT NULL
    GROUP BY trim(titulo)
),

-- Se corrige cada columna de los rechazados.
corregidos AS (
    SELECT
        trim(r.id_reproduccion)                                AS id_reproduccion,

        -- Primero prueba AAAA-MM-DD; si no, DD/MM/AAAA.
        coalesce(
            try_cast(trim(r.fecha) AS DATE),
            try_strptime(trim(r.fecha), '%d/%m/%Y')::DATE
        )                                                      AS fecha,

        try_cast(trim(r.id_usuario) AS INTEGER)                AS id_usuario,
        lower(trim(r.plan))                                    AS plan,
        trim(r.titulo)                                         AS titulo,

        -- Si viene vacío, se completa con el del catálogo.
        coalesce(nullif(lower(trim(r.tipo_contenido)), ''), c.tipo_contenido) AS tipo_contenido,
        coalesce(nullif(lower(trim(r.genero)), ''),         c.genero)         AS genero,

        abs(try_cast(trim(r.minutos_vistos) AS INTEGER))       AS minutos_vistos,

        -- Si no es ninguna variante conocida queda NULL y la fila se descarta.
        CASE
            WHEN lower(trim(r.dispositivo)) IN ('celular', 'cel', 'movil')                THEN 'celular'
            WHEN lower(trim(r.dispositivo)) IN ('tablet')                                 THEN 'tablet'
            WHEN lower(trim(r.dispositivo)) IN ('notebook', 'laptop', 'pc')               THEN 'notebook'
            WHEN lower(trim(r.dispositivo)) IN ('smart_tv', 'smarttv', 'smart tv', 'tv')  THEN 'smart_tv'
        END                                                    AS dispositivo,

        trim(r.pais)                                           AS pais
    FROM rechazados AS r
    LEFT JOIN catalogo AS c
        ON trim(r.titulo) = c.titulo
)

SELECT *
FROM corregidos
WHERE
    -- Ya corregidas, tienen que cumplir las mismas reglas que validar.sql
    regexp_full_match(id_reproduccion, 'R[0-9]{6}')
    AND fecha IS NOT NULL
    AND fecha <= current_date
    AND id_usuario > 0
    AND plan IN ('basico', 'estandar', 'premium')
    AND titulo IS NOT NULL AND titulo <> ''
    AND tipo_contenido IN ('pelicula', 'serie', 'documental')
    AND genero IN ('accion', 'comedia', 'terror', 'ciencia_ficcion',
                   'suspenso', 'naturaleza', 'tecnologia', 'romance')
    AND minutos_vistos > 0
    AND dispositivo IS NOT NULL
    AND pais IN ('Argentina', 'Chile', 'Mexico', 'Colombia')

    -- Duplicados: si el id ya está en validos, esta fila es una copia
    AND NOT EXISTS (
        SELECT 1
        FROM validos AS v
        WHERE trim(v.id_reproduccion) = corregidos.id_reproduccion
    )

-- Y si el mismo id quedó más de una vez acá, se queda una sola fila.
QUALIFY row_number() OVER (PARTITION BY id_reproduccion ORDER BY fecha) = 1;

--coalesce:devuelve el primero que no sea NULL
--nullif:si x es '' devuelve NULL; si no, devuelve x
--Date:forma corta de CAST(... AS DATE)
--try_strptime:convierte texto a fecha diciéndole el formato; si no coincide, devuelve NULL
--try_cast: convierte al tipo; si no puede, devuelve NULL en vez de dar error
--abs(x): valor absoluto
--lower(x):	pasa todo a minúscula
--trim(x): 	saca los espacios del principio y del final
--mode() devuelve el valor más frecuente.
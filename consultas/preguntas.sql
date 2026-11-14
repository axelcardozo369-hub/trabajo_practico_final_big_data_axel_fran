CREATE OR REPLACE TABLE respuesta_1 AS
SELECT
    genero,
    sum(minutos_vistos) AS minutos_totales
FROM tabla_final
GROUP BY genero
ORDER BY minutos_totales DESC;


-- 2. ¿Cuáles son los 5 títulos más vistos (por cantidad de reproducciones)?
--    El segundo criterio (titulo) desempata para que el orden sea siempre el mismo.
CREATE OR REPLACE TABLE respuesta_2 AS
SELECT
    titulo,
    count(*) AS reproducciones
FROM tabla_final
GROUP BY titulo
ORDER BY reproducciones DESC, titulo
LIMIT 5;


-- 3. ¿Cuántos usuarios distintos hay por plan?
--    count(DISTINCT ...) cuenta cada usuario una sola vez dentro de cada plan.
CREATE OR REPLACE TABLE respuesta_3 AS
SELECT
    plan,
    count(DISTINCT id_usuario) AS usuarios_distintos
FROM tabla_final
GROUP BY plan
ORDER BY usuarios_distintos DESC;


-- 4. ¿Cuál es el dispositivo más usado?
--    "Más usado" = el que tiene más reproducciones.
CREATE OR REPLACE TABLE respuesta_4 AS
SELECT
    dispositivo,
    count(*) AS reproducciones
FROM tabla_final
GROUP BY dispositivo
ORDER BY reproducciones DESC
LIMIT 1;


-- 5. ¿Cuál es el promedio de minutos vistos por tipo de contenido?
CREATE OR REPLACE TABLE respuesta_5 AS
SELECT
    tipo_contenido,
    round(avg(minutos_vistos), 2) AS promedio_minutos
FROM tabla_final
GROUP BY tipo_contenido
ORDER BY promedio_minutos DESC;
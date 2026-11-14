CREATE OR REPLACE TABLE raw_reproducciones AS
SELECT * FROM read_csv('data/reproducciones.csv', all_varchar = true);
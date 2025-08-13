
-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? --

SELECT *																									-- 1. Pin zdrojové tabulky
FROM t_ondrej_romaniuk_project_sql_primary_final;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q3_slowest_price_growth AS										-- 2. Tabulka s odpovědí
WITH
  roky AS (
    SELECT 
      MIN(rok) AS min_rok, 
      MAX(rok) AS max_rok
    FROM t_ondrej_romaniuk_project_sql_primary_final
  ),

  cena_start AS (
    SELECT
      category_code,
      value_cp AS cena_st
    FROM t_ondrej_romaniuk_project_sql_primary_final,
         roky
    WHERE rok = roky.min_rok
  ),

  cena_end AS (
    SELECT
      category_code,
      value_cp AS cena_ed
    FROM t_ondrej_romaniuk_project_sql_primary_final,
         roky
    WHERE rok = roky.max_rok
  ),

  procenta AS (
    SELECT
      cs.category_code,
      ROUND(((ce.cena_ed - cs.cena_st) / cs.cena_st) * 100, 2) || '%' AS procentualni_narust
    FROM cena_start cs
    JOIN cena_end ce ON cs.category_code = ce.category_code
  )

SELECT
  p.category_code,
  cpc.name,
  p.procentualni_narust
FROM procenta p
LEFT JOIN czechia_price_category cpc ON p.category_code = cpc.code
ORDER BY CAST(REPLACE(p.procentualni_narust, '%', '') AS NUMERIC) ASC
LIMIT 1;


SELECT *																									-- 3. Volání tabulky
FROM t_Ondrej_Romaniuk_project_SQL_Q3_slowest_price_growth;



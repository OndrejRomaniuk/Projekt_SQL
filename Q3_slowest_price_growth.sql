-- Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? --

SELECT *																									-- 1. Pin zdrojové tabulky
FROM t_ondrej_romaniuk_project_sql_primary_final;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q3_slowest_price_growth AS										-- 2. Tabulka s odpovědí
WITH
  mezirocni_narust AS (
    SELECT
        category_code,
        rok,
        ROUND(
            ((value_cp - LAG(value_cp) OVER (PARTITION BY category_code ORDER BY rok))
            / LAG(value_cp) OVER (PARTITION BY category_code ORDER BY rok)) * 100,
            2
        ) AS mezirocni_narust_procent
    FROM t_ondrej_romaniuk_project_sql_primary_final
  ),

  procenta AS (
    SELECT
      mn.category_code,
      mn.rok,
      COALESCE(mn.mezirocni_narust_procent, 0) || '%' AS procentualni_narust
    FROM mezirocni_narust mn
  )

SELECT
  p.category_code,
  cpc.name,
  p.rok,
  p.procentualni_narust
FROM procenta p
LEFT JOIN czechia_price_category cpc ON p.category_code = cpc.code
ORDER BY CAST(REPLACE(p.procentualni_narust, '%', '') AS NUMERIC) ASC
LIMIT 1;


SELECT *																									-- 3. Volání tabulky
FROM t_Ondrej_Romaniuk_project_SQL_Q3_slowest_price_growth;

DROP TABLE t_Ondrej_Romaniuk_project_SQL_Q3_slowest_price_growth;


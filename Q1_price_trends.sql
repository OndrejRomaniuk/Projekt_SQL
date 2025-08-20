
-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? --

SELECT *																									-- 1. Pin zdrojové tabulky
FROM t_ondrej_romaniuk_project_sql_primary_final;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q1_price_trends AS   											-- 2. Tabulka s odpovědí
WITH
  roky AS (
    SELECT 
    MIN(rok) AS min_rok, 
    MAX(rok) AS max_rok 
    FROM t_ondrej_romaniuk_project_sql_primary_final 
  ),
  plat_start AS (
    SELECT industry_branch_code, value_pay AS plat_start
    FROM t_ondrej_romaniuk_project_sql_primary_final, roky
    WHERE rok = roky.min_rok
  ),
  plat_end AS (
    SELECT industry_branch_code, value_pay AS plat_end
    FROM t_ondrej_romaniuk_project_sql_primary_final, roky
    WHERE rok = roky.max_rok
  )
SELECT
  p_start.industry_branch_code,
  cpib.name,
  CASE 
    WHEN p_end.plat_end > p_start.plat_start THEN 'ANO'
    ELSE 'NE'
  END AS rostou_platy
FROM plat_start p_start
JOIN plat_end AS p_end 
	ON p_start.industry_branch_code = p_end.industry_branch_code
LEFT JOIN czechia_payroll_industry_branch AS cpib
	ON p_start.industry_branch_code = cpib.code
ORDER BY p_start.industry_branch_code;

SELECT *																									-- 3. Volání tabulky
FROM t_Ondrej_Romaniuk_project_SQL_Q1_price_trends;

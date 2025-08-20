
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd? --

SELECT *																									-- 1. Pin zdrojové tabulky
FROM t_ondrej_romaniuk_project_sql_primary_final;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q2_bread_meat_affordability AS									-- 2. Tabulka s odpovědí
WITH
  roky AS (																									-- min rok je 2006
    SELECT 																									-- max rok je 2018
      MIN(rok) AS min_rok, 
      MAX(rok) AS max_rok 
    FROM t_ondrej_romaniuk_project_sql_primary_final
  ),
  
  plat_start AS (																							-- plat / odvětví / 2006
    SELECT industry_branch_code, value_pay AS plat_start
    FROM t_ondrej_romaniuk_project_sql_primary_final, roky
    WHERE rok = roky.min_rok
  ),
  
  plat_end AS (																								-- plat / odvětví / 2018
    SELECT industry_branch_code, value_pay AS plat_end
    FROM t_ondrej_romaniuk_project_sql_primary_final, roky
    WHERE rok = roky.max_rok
  ),
  
  cena_chleba AS (																							-- kategorie zboží - chleba
    SELECT rok, value_cp AS cena_chleba
    FROM t_ondrej_romaniuk_project_sql_primary_final
    WHERE category_code = '111301'
  ),
  
  cena_mleka AS (																							-- kategorie zboží - mléko
    SELECT rok, value_cp AS cena_mleka
    FROM t_ondrej_romaniuk_project_sql_primary_final
    WHERE category_code = '114201'
  ),
  
  chleba_afford AS (																						-- plat / kg chleba
    SELECT
      ps.industry_branch_code,
      ROUND(ps.plat_start / cch_start.cena_chleba, 2) AS chleba_kg_start_2006,
      ROUND(pe.plat_end / cch_end.cena_chleba, 2) AS chleba_kg_end_2018
    FROM plat_start ps
    JOIN plat_end pe ON ps.industry_branch_code = pe.industry_branch_code
    JOIN roky r ON 1=1
    JOIN cena_chleba cch_start ON cch_start.rok = r.min_rok
    JOIN cena_chleba cch_end ON cch_end.rok = r.max_rok
  ),
  
  mleko_afford AS (																							-- plat / kg chleba
    SELECT
      ps.industry_branch_code,
      ROUND(ps.plat_start / cm_start.cena_mleka, 2) AS mleko_kg_start_2006,
      ROUND(pe.plat_end / cm_end.cena_mleka, 2) AS mleko_kg_end_2018
    FROM plat_start ps
    JOIN plat_end pe ON ps.industry_branch_code = pe.industry_branch_code
    JOIN roky r ON 1=1
    JOIN cena_mleka cm_start ON cm_start.rok = r.min_rok
    JOIN cena_mleka cm_end ON cm_end.rok = r.max_rok
  )

SELECT
  ch.industry_branch_code,
  cpib.name,
  ch.chleba_kg_start_2006,
  ch.chleba_kg_end_2018,
  ml.mleko_kg_start_2006,
  ml.mleko_kg_end_2018
FROM chleba_afford ch
LEFT JOIN mleko_afford ml ON ch.industry_branch_code = ml.industry_branch_code
LEFT JOIN czechia_payroll_industry_branch cpib ON ch.industry_branch_code = cpib.code
ORDER BY ch.industry_branch_code;


SELECT *																									-- 3. Volání tabulky
FROM t_Ondrej_Romaniuk_project_SQL_Q2_bread_meat_affordability;

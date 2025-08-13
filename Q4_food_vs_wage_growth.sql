
-- Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)? --

SELECT *																									-- 1. Pin zdrojové tabulky
FROM t_ondrej_romaniuk_project_sql_primary_final;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q4_food_vs_wage_growth AS										-- 2. Tabulka s odpovědí
WITH
	prumer_zbozi AS (
		SELECT 
			rok, 
			AVG(value_cp) AS zbozi_rok
		FROM t_ondrej_romaniuk_project_sql_primary_final
		GROUP BY rok 
	),
	
	prumer_mzdy AS (
		SELECT 
			rok, 
			AVG(value_pay) AS mzdy_rok
		FROM t_ondrej_romaniuk_project_sql_primary_final
		GROUP BY rok 
	),
	
	narust_zbozi AS (
	    SELECT
	        rok,
	        zbozi_rok,
	        COALESCE(
	            ROUND(
	                ((zbozi_rok - LAG(zbozi_rok) OVER (ORDER BY rok))
	                / LAG(zbozi_rok) OVER (ORDER BY rok)) * 100,
	            2),
	            0
	        ) AS zbozi_mezirocni_narust_procent
	    FROM prumer_zbozi
	),
	
	narust_mezd AS (
	    SELECT
	        rok,
	        mzdy_rok,
	        COALESCE(
	            ROUND(
	                ((mzdy_rok - LAG(mzdy_rok) OVER (ORDER BY rok))
	                / LAG(mzdy_rok) OVER (ORDER BY rok)) * 100,
	            2),
	            0
	        ) AS mzdy_mezirocni_narust_procent
	    FROM prumer_mzdy
	),

	srovnani AS (
	    SELECT
	        z.rok,
	        z.zbozi_mezirocni_narust_procent,
	        m.mzdy_mezirocni_narust_procent,
	        (z.zbozi_mezirocni_narust_procent - m.mzdy_mezirocni_narust_procent) AS rozdil
	    FROM narust_zbozi z
	    JOIN narust_mezd m ON z.rok = m.rok
	    -- WHERE (z.zbozi_mezirocni_narust_procent - m.mzdy_mezirocni_narust_procent) > 10
	)
	
SELECT * FROM srovnani;

SELECT *																									-- 3. Volání tabulky				
FROM t_Ondrej_Romaniuk_project_SQL_Q4_food_vs_wage_growth
ORDER BY rozdil DESC;

	
	
	

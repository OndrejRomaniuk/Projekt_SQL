
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce,
-- projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

SELECT *																									-- 1. Pin zdrojových tabulek
FROM t_Ondrej_Romaniuk_project_SQL_secondary_final;

SELECT *
FROM t_Ondrej_Romaniuk_project_SQL_Q4_food_vs_wage_growth;

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_Q5_gdp_vs_growth AS												-- 2. Tabulka s odpovědí
WITH
narust_hdp AS (
    SELECT
        year,
        gdp,
        COALESCE(
            ROUND(
                (
                    ((gdp - LAG(gdp) OVER (ORDER BY year))
                    / LAG(gdp) OVER (ORDER BY year)) * 100
                )::numeric,
            2
        ), 0) AS gdp_growth
    FROM t_Ondrej_Romaniuk_project_SQL_secondary_final
),
data_srovnani AS (
    SELECT
        nh.year,
        nh.gdp_growth,
        tbQ4.mzdy_mezirocni_narust_procent AS mzdy_growth,
        tbQ4.zbozi_mezirocni_narust_procent AS ceny_growth,

        -- Současný rok - mzdy
        CASE
            WHEN nh.gdp_growth < 5 THEN 'HDP výrazně tento rok nerostlo'
            WHEN tbQ4.mzdy_mezirocni_narust_procent > 0 THEN 'Mzdy rostly'
            ELSE 'Mzdy nerostly'
        END AS soucasny_rok_mzdy,

        -- Současný rok - ceny
        CASE
            WHEN nh.gdp_growth < 5 THEN 'HDP výrazně tento rok nerostlo'
            WHEN tbQ4.zbozi_mezirocni_narust_procent > 0 THEN 'Ceny rostly'
            ELSE 'Ceny nerostly'
        END AS soucasny_rok_ceny,

        -- Následující rok - mzdy
        CASE
            WHEN nh.gdp_growth < 5 THEN 'HDP výrazně tento rok nerostlo'
            WHEN LEAD(tbQ4.mzdy_mezirocni_narust_procent) OVER (ORDER BY nh.year) > 0 THEN 'Mzdy rostly'
            ELSE 'Mzdy nerostly'
        END AS nasledujici_rok_mzdy,

        -- Následující rok - ceny
        CASE
            WHEN nh.gdp_growth < 5 THEN 'HDP výrazně tento rok nerostlo'
            WHEN LEAD(tbQ4.zbozi_mezirocni_narust_procent) OVER (ORDER BY nh.year) > 0 THEN 'Ceny rostly'
            ELSE 'Ceny nerostly'
        END AS nasledujici_rok_ceny

    FROM narust_hdp nh
    LEFT JOIN t_Ondrej_Romaniuk_project_SQL_Q4_food_vs_wage_growth tbQ4
        ON nh.year = tbQ4.rok
)
SELECT *
FROM data_srovnani
ORDER BY
	soucasny_rok_mzdy DESC;
    
SELECT *																									-- 3. Volaní tabulky
FROM t_Ondrej_Romaniuk_project_SQL_Q5_gdp_vs_growth;

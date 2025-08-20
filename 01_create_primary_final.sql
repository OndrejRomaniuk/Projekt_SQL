
-- TVORBA VIEWS --

-- CZECHIA_PAYROLL DATASET

CREATE OR REPLACE VIEW v_payroll_basic_view AS   					-- payroll vyselektovaný na stejnou časovou
SELECT                              								-- řadu jako má price tj. 2006 - 2008
	id AS id_pay,													-- na odpovídající hodnoty viz níže
	value AS value_pay,												-- a ořezaný o nadbytečné sloupce
	industry_branch_code,
	payroll_year AS rok
FROM czechia_payroll                  
WHERE
	value_type_code = 5958 										    -- Průměrná hrubá mzda na zaměstnance
	AND unit_code = 200										    	-- tis. osob (tis. os.)
	AND calculation_code = 200								    	-- přepočtený (FTE – Full Time Equivalent)
	AND payroll_year BETWEEN 2006 AND 2018;  

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_payroll_basic_view;
				
				DROP VIEW v_payroll_basic_view;
				
				----------------------------------------------------

CREATE OR REPLACE VIEW v_payroll_no_quarter AS  					-- průměrování kvartálních hodnot na roční
SELECT
	round(avg(value_pay):: NUMERIC, 2) AS value_pay,
	industry_branch_code,
	rok
FROM v_payroll_basic_view
GROUP BY
	industry_branch_code,
	rok
ORDER BY
	industry_branch_code,
	rok;

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_payroll_no_quarter;
				
				DROP VIEW v_payroll_no_quarter;
				
				----------------------------------------------------

CREATE OR REPLACE VIEW v_payroll_id_column_addition AS				-- doplnění custom ID sloupce pro potřeby
SELECT 																-- joinu ve spojení finální tabulky
	rok::TEXT || '_' || industry_branch_code::TEXT AS custom_id_pay,
	value_pay,
	industry_branch_code,
	rok
FROM v_payroll_no_quarter;

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_payroll_id_column_addition;
				
				DROP VIEW v_payroll_id_column_addition;
				
				----------------------------------------------------

-- CZECHIA_PRICE DATASET

CREATE OR REPLACE VIEW v_price_data_format AS						-- formátování časového údaje na roky (date_from)
SELECT 																-- odstranění nadbytečných sloupců
	id AS id_cp,
	value AS value_cp,
	category_code,
	EXTRACT(YEAR FROM date_from)::int AS rok
FROM czechia_price cp; 

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_price_data_format;
				
				DROP VIEW v_price_data_format;
				
				----------------------------------------------------

CREATE OR REPLACE VIEW v_price_region_avg AS						-- průměrování hodnot z regionálního měřítka
SELECT																-- na celorepublikové tj. shodné s payroll
	rok,													
	category_code,
	round(avg(value_cp):: NUMERIC, 2) AS value_cp
FROM v_price_data_format
GROUP BY
	rok, 
	category_code
ORDER BY
	rok,
	category_code;

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_price_region_avg;
				
				DROP VIEW v_price_region_avg;
				
				----------------------------------------------------

CREATE OR REPLACE VIEW v_price_id_column_addition AS				-- doplnění custom ID sloupce pro potřeby
SELECT 																-- joinu ve spojení finální tabulky
	rok::TEXT || '_' || category_code::TEXT AS custom_id_cp,
	rok,
	category_code,
	value_cp
FROM v_price_region_avg;

				--- EDITAČNÍ OBSLUHA VIEW  ---
				
				SELECT *
				FROM v_price_id_column_addition;
				
				DROP VIEW v_price_id_column_addition;

----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- TVORBA SPOLEČNÉ TABULKY --

CREATE TABLE t_Ondrej_Romaniuk_project_SQL_primary_final AS
WITH 
-- 1. Ceny s očíslováním podle roku z view
ceny_q AS (
    SELECT
        custom_id_cp,
        rok,
        category_code,
        value_cp,
        ROW_NUMBER() OVER (
            PARTITION BY rok
            ORDER BY custom_id_cp
        ) AS rn
    FROM v_price_id_column_addition
),

-- 2. Mzdy s očíslováním podle roku z view
mzdy_q AS (
    SELECT
        custom_id_pay,
        value_pay,
        industry_branch_code,
        rok,
        ROW_NUMBER() OVER (
            PARTITION BY rok
            ORDER BY custom_id_pay
        ) AS rn
    FROM v_payroll_id_column_addition
)

-- 3. Finální propojení upravených dat z czechia_payroll a czechia_price do společné tabulky
SELECT
    m.custom_id_pay,
    m.value_pay,
    m.industry_branch_code,
    COALESCE(m.rok, c.rok) AS rok,
    c.custom_id_cp,
    c.category_code,
    c.value_cp
FROM mzdy_q m
FULL OUTER JOIN ceny_q c
    ON m.rok = c.rok
    AND m.rn = c.rn
ORDER BY rok, custom_id_pay NULLS LAST, custom_id_cp NULLS LAST;


				--- EDITAČNÍ OBSLUHA TABULKY ---
				
				SELECT *
				FROM t_Ondrej_Romaniuk_project_SQL_primary_final;
				
				DROP TABLE IF EXISTS t_Ondrej_Romaniuk_project_SQL_primary_final;
				
				----------------------------------------------------

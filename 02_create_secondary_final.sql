CREATE TABLE t_Ondrej_Romaniuk_project_SQL_secondary_final AS					-- vyselektování dat pro ČR a roky 2006 - 2018
SELECT *
FROM economies
WHERE
    YEAR BETWEEN 2006 AND 2018
    AND country = 'Czech Republic';

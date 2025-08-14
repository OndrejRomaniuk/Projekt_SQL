# 📊 SQL Projekt: Dostupnost základních potravin a mzdový vývoj v ČR

## 1️⃣ Úvod do projektu
Tento projekt vznikl v rámci studia SQL (ENGETO) a jeho cílem je:
- analyzovat dostupnost základních potravin v ČR v kontextu průměrných příjmů,
- porovnat cenový a mzdový vývoj za vybrané období,
- doplnit srovnání z dat evropských států

---

## 2️⃣ Použitá data

### Primární zdroje
- **Mzdová data** (czechia_payroll) – informace o mzdách v různých odvětvích za několik let. *Zdroj: Open data z data.gov.cz, Říjen 2021.*
- **Cenová data** (czechia_price) – informace o cenách vybraných potravin za několik let. *Zdroj: Open data z data.gov.cz, Říjen 2021.*
- Číselníky kategorií potravin, odvětví a dalších pomocných dat pro propojení.

### Dodatečné zdroje
- Tabulka `countries` – základní údaje o zemích. *Zdroj: Databáze Engeto.*
- Tabulka `economies` – ukazatele HDP, GINI, daňová zátěž atd. pro evropské státy. *Zdroj: Databáze Engeto.*

> **Poznámka:** Data nebyla měněna v původních tabulkách. Všechny transformace probíhaly až při tvorbě nových tabulek.

---

## 3️⃣ Struktura projektu a metodologie

```plaintext
sql-food-prices-salaries-project/
│
├── sql/
│   ├── 01_create_primary_final.sql          # Sjednocení mzdových a cenových dat pro ČR
│   ├── 02_create_secondary_final.sql        # Evropské státy - HDP, GINI, populace
│   ├── Q1_price_trends.sql                  # Odpověď na otázku 1
│   ├── Q2_bread_meat_affordability.sql      # Odpověď na otázku 2
│   ├── Q3_slowest_price_growth.sql          # Odpověď na otázku 3
│   ├── Q4_food_vs_wage_growth.sql           # Odpověď na otázku 4
│   ├── Q5_gdp_influence.sql                 # Odpověď na otázku 5
│
└── README.md
```
---

**Schéma tvorby základní datové sady**
```plaintext
+----------------------+          +----------------------+
|   CZECHIA_PAYROLL    |          |    CZECHIA_PRICE     |
|----------------------|          |----------------------|
| id                   |          | id                   |
| value                |          | value                |
| value_type_code      |          | category_code        |
| unit_code            |          | date_from            |
| calculation_code     |          | date_to              |
| industry_branch_code |          | region_code          |
| payroll_year         |          |                      |
| payroll_quarter      |          |                      |
+----------------------+          +----------------------+
   | (filtr průměrná mzda,           | (datum převeden na rok,
   | jednotka tis. osob,             | odstraněny kvartály (vyskytovaly se pouze Q1/Q4),
   | přepočteno na FTE,              | regiony zprůměrovány na celorepubliku)
   | omezení 2006–2018)              | 
   v                                 v
+----------------------+          +----------------------+
| v_payroll_basic_view |          | v_price_data_format  |
|----------------------|          |----------------------|
| id_pay               |          | id_cp                |
| value_pay            |          | value_cp             |
| industry_branch_code |          | category_code        |
| rok                  |          | rok                  |
+----------------------+          +----------------------+
   | (průměrování kvartálních        | (průměrování regionálních
   | hodnot na roční)                | hodnot na celorepublikové)
   v                                 v
+----------------------+          +----------------------+
| v_payroll_no_quarter |          | v_price_region_avg   |
|----------------------|          |----------------------|
| value_pay            |          | value_cp             |
| industry_branch_code |          | category_code        |
| rok                  |          | rok                  |
+----------------------+          +----------------------+
   | (doplnění custom ID)            | (doplnění custom ID)
   v                                 v
+----------------------+          +----------------------+
| v_payroll_id_column_ |          | v_price_id_column_   |
| addition             |          | addition             |
|----------------------|          |----------------------|
| custom_id_pay        |          | custom_id_cp         |
| value_pay            |          | value_cp             |
| industry_branch_code |          | category_code        |
| rok                  |          | rok                  |
+----------------------+          +----------------------+
          \                                /
           \                              /
            \       FULL OUTER JOIN      /
             \--------------------------/
                          |
                          v
+--------------------------------------------------+
| t_Ondrej_Romaniuk_project_SQL_primary_final      |
|--------------------------------------------------|
| custom_id_pay                                    |
| value_pay                                        |
| industry_branch_code                             |
| rok                                              |
| custom_id_cp                                     |
| category_code                                    |
| value_cp                                         |
+--------------------------------------------------+
(Payroll má méně hodnot než Price kvůli menšímu počtu kategorií)

```
---

## 4️⃣ Výzkumné otázky a shrnutí odpovědí

### Q1 – Růst cen v jednotlivých letech a odvětvích
*Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*

**Shrnutí výsledků:**  
*Při srovnání dat počátečních a konečných let z dostupné časové řady vyplynulo, že mzdy vzrostly ve všech defaultně nastavených pracovních odvětvích.*

---

### Q2 – Kupní síla (kolik kg chleba a kg masa lze koupit)
*Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?*

**Shrnutí výsledků:**  
*Během sledovaného období vzrostla kupní síla pracovníků ve většině odvětví, pokud se hodnotí podle množství chleba a mléka, které si mohli koupit za průměrnou mzdu. Největší nárůst zaznamenala odvětví peněžnictví a pojišťovnictví, informační a komunikační činnosti a profesní, vědecké a technické činnosti. Naopak menší odvětví či „ostatní“ vykazují jen mírný růst.*

*Celkově data ukazují, že růst mezd se projevil nerovnoměrně a reálná kupní síla se v jednotlivých sektorech zvyšovala různou rychlostí.*

---

### Q3 – Nejpomalejší růst cen
*Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*

**Shrnutí výsledků:**  
*Nejpomaleji zdražující kategorií jsou **rajská jablka červená kulatá**, která v roce 2007 meziročně dokonce **zlevnila o 30,28 %**. To ukazuje, že i v rámci obecného růstu cen potravin mohou některé produkty zaznamenat výrazný pokles, pravděpodobně vlivem sezónních nebo tržních faktorů.*

---

### Q4 – Roky s růstem cen >10 % oproti mzdám
*Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*

**Shrnutí výsledků:**  
*Podle dat žádný rok nevykazuje meziroční nárůst cen potravin výrazně vyšší než růst mezd o více než 10 %.*

*Nejvyšší hodnota rozdílu je v roce **2013**, kdy ceny potravin rostly meziročně o **5,10 %**, mzdy klesly o **1,49 %**, což dává rozdíl **6,59 %**. I přesto je rozdíl nižší než hranice 10 %, takže ani tento rok nesplňuje kritérium „výrazně vyšší nárůst cen než mezd“.*

---

### Q5 – Vliv HDP na ceny a mzdy
*Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*

**Shrnutí výsledků:**  
*Výraznější růst HDP se obecně projevuje zvýšením mezd, což zvyšuje kupní sílu pracovníků. Například v letech **2007 a 2017**, kdy HDP vzrostlo výrazněji než 5 %, rostly mzdy i ceny potravin souběžně. Naopak v roce **2015**, přestože HDP také výrazně vzrostlo, mzdy rostly, ale ceny potravin stagnovaly či klesaly. To ukazuje, že ekonomický růst má spolehlivější vliv na mzdy než na ceny potravin.*

---

## 5️⃣ Jak spustit projekt

1. **Načti data** z původních tabulek (poskytnuté v rámci projektu).
2. **Spusť skripty** v adresáři `/sql` v tomto pořadí:
   - `01_create_primary_final.sql`
   - `02_create_secondary_final.sql`
   - `Q1_price_trends.sql` až `Q5_gdp_influence.sql` podle potřeby.
3. **Prohlédni výsledky** – každý skript pro otázku vrací datovou sadu, která odpovídá na výzkumnou otázku.
4. **Případně selectuj přímo odpovědní tabulky** - viz databáze - t_ondrej_romaniuk_project_sql_qx_xxxxx_xxxxxx

---

## 6️⃣ Poznámky k datům
- Některé roky neobsahují kompletní data pro všechny kategorie potravin.
- U mzdových dat chybí údaje za některé okresy v počátečních letech.
- Všechny ceny jsou v Kč, mzdy jsou průměrné měsíční hrubé.

Během analýzy se ukázalo, že v tabulce czechia_payroll existují záznamy, které obsahují platnou hodnotu (value), ale u příslušného odvětví (industry_branch) je hodnota NULL.
Tyto záznamy odpovídaly nekategorizovaným datům nebo spadaly do defaultní kategorie „ostatní“. Protože nešlo jednoznačně určit, ke kterému odvětví patří, byly z analýzy vynechány.
Důvodem je, že zahrnutí takových záznamů by mohlo zkreslit výsledky srovnání jednotlivých odvětví, a zároveň by jejich přítomnost neumožnila smysluplné interpretace.

---

## 7️⃣ Autor
**Jméno:** *Ondřej Romaniuk* 
**Datum:** *08/2025*
**Kontakt:** *[LinkedIn](https://www.linkedin.com/in/ond%C5%99ej-romaniuk/) / [GitHub](https://github.com/OndrejRomaniuk)*






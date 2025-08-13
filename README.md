# 📊 SQL Projekt: Dostupnost základních potravin a mzdový vývoj v ČR a Evropě

## 1️⃣ Úvod do projektu
Tento projekt vznikl v rámci studia SQL (ENGETO) a jeho cílem je:
- analyzovat dostupnost základních potravin v ČR v kontextu průměrných příjmů,
- porovnat cenový a mzdový vývoj za vybrané období,
- doplnit srovnání s dalšími evropskými státy pomocí ukazatelů HDP, GINI a populace.

---

## 2️⃣ Použitá data

### Primární zdroje
- **Mzdová data** (czechia_payroll) – informace o mzdách v různých odvětvích za několik let. Zdroj: Open data z data.gov.cz, Říjen 2021.
- **Cenová data** (czechia_price) – informace o cenách vybraných potravin za několik let. Zdroj: Open data z data.gov.cz, Říjen 2021.
- Číselníky kategorií potravin, odvětví a dalších pomocných dat pro propojení.

### Dodatečné zdroje
- Tabulka `countries` – základní údaje o zemích. Zdroj: Databáze Engeto.
- Tabulka `economic_indicators` – ukazatele HDP, GINI, daňová zátěž atd. pro evropské státy. Zdroj: Databáze Engeto.

> **Poznámka:** Data nebyla měněna v původních tabulkách. Všechny transformace probíhaly až při tvorbě nových tabulek.

---

## 3️⃣ Struktura projektu a metodologie

```plaintext
sql-food-prices-project/
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
   | (odstraněny kvartály,            | (převeden date_from na rok,
   | zprůměrováno po odvětvích        | Q1 a Q4 odstraněny,
   | za rok, omezeno 2006–2018,       | regiony zprůměrovány
   | vytvořeno nové ID)               | na celorepublikové hodnoty,
   |                                  | vytvořeno nové ID)
   v                                  v
+----------------------+          +----------------------+
| v_payroll_basic_view |          | v_price_data_format  |
|----------------------|          |----------------------|
| id_pay               |          | rok                  |
| value_pay            |          | průměrná_cena        |
| industry_branch_code |          | id_new               |
| rok                  |          |                      |
+----------------------+          +----------------------+

+----------------------+          +----------------------+
| v_payroll_no_quarter |          |   Ceny_Q (CTE)       |
|----------------------|          |----------------------|
| value_pay            |          | rok                  |
| industry_branch_code |          | id_new               |
| rok                  |          |                      |
+----------------------+          +----------------------+

+----------------------+          +----------------------+
| v_payroll_id_column_ |          |   Ceny_Q (CTE)       |
| addition             |          |
|----------------------|          |----------------------|
| custom_id_pay        |          | průměrná_cena        |
| value_pay            |          | id_new               |
| industry_branch_code |          |                      |
| rok                  |          |                      |
+----------------------+          +----------------------+


          \                                /
           \                              /
            \     FULL OUTER JOIN (rok)  /
             \--------------------------/
                          |
                          v
+----------------------------------------------+
| t_Ondrej_Romaniuk_project_SQL_primary_final |
|----------------------------------------------|
| rok                                          |
| průměrná_mzda                                |
| průměrná_cena                                |
| id_new_payroll                               |
| id_new_price                                 |
+----------------------------------------------+
(Payroll má méně hodnot než Price kvůli menšímu počtu kategorií)
```
---

## 4️⃣ Výzkumné otázky a shrnutí odpovědí

### Q1 – Růst cen v jednotlivých letech a odvětvích
*Jak se vyvíjely ceny potravin v čase? Rostly ve všech sektorech nebo jen v některých?*

**Shrnutí výsledků:**  
*(Zde doplň stručný komentář – např. „Ve všech kategoriích došlo k růstu, nejvyšší růst zaznamenány mléčné výrobky v roce 2018.“)*

---

### Q2 – Kupní síla (kolik kg chleba a kg masa lze koupit)
*Kolik si lze koupit chleba a masa za průměrnou mzdu v prvním a posledním sledovaném období?*

**Shrnutí výsledků:**  
*(Např.: „Kupní síla se zvýšila u obou komodit, u masa více než u chleba.“)*

---

### Q3 – Nejpomalejší růst cen
*Která kategorie potravin zaznamenala nejnižší meziroční procentuální růst?*

**Shrnutí výsledků:**  
*(Např.: „Cukr zaznamenal nejnižší průměrný meziroční růst, zejména po roce 2019.“)*

---

### Q4 – Roky s růstem cen >10 % oproti mzdám
*Existuje rok, kdy meziroční nárůst cen potravin výrazně převýšil růst mezd (o více než 10 %)?*

**Shrnutí výsledků:**  
*(Např.: „Rok 2022 – ceny potravin rostly o 15 %, mzdy jen o 3 %.“)*

---

### Q5 – Vliv HDP na ceny a mzdy
*Projevil se růst HDP v daném roce výraznějším růstem cen potravin nebo mezd v tom samém či následujícím roce?*

**Shrnutí výsledků:**  
*(Např.: „Významná korelace nebyla nalezena, kromě let 2017–2018.“)*

---

## 5️⃣ Jak spustit projekt

1. **Načti data** z původních tabulek (poskytnuté v rámci projektu).
2. **Spusť skripty** v adresáři `/sql` v tomto pořadí:
   - `01_create_primary_final.sql`
   - `02_create_secondary_final.sql`
   - `Q1_price_trends.sql` až `Q5_gdp_influence.sql` podle potřeby.
3. **Prohlédni výsledky** – každý skript pro otázku vrací datovou sadu, která odpovídá na výzkumnou otázku.

---

## 6️⃣ Poznámky k datům
- Některé roky neobsahují kompletní data pro všechny kategorie potravin.
- U mzdových dat chybí údaje za některé okresy v počátečních letech.
- Všechny ceny jsou v Kč, mzdy jsou průměrné měsíční hrubé.

---

## 7️⃣ Autor
**Jméno:** *Ondřej Romaniuk*  
**Kontakt:** *[LinkedIn]([url](https://www.linkedin.com/in/ond%C5%99ej-romaniuk/)) / [GitHub]([url](https://github.com/OndrejRomaniuk))*  
**Datum:** *08/2025*





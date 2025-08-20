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
*Na základě propojení mezd a cen potravin lze sledovat, kolik kilogramů chleba a litrů mléka bylo možné si koupit na začátku sledovaného období (rok 2006) a kolik na jeho konci (rok 2018).*

**Kupní síla mezd (chleba a mléko, 2006 vs. 2018)**
```plaintext
Odvětví                                           | Chléb 2006 (kg) | Chléb 2018 (kg) | Rozdíl chléb (kg) | Mléko 2006 (l) | Mléko 2018 (l) | Rozdíl mléko (l)
-------------------------------------------------------------------------------------------------------------------------------
A  Zemědělství, lesnictví, rybářství              |  919.22         | 1050.61         | +131.39           | 1026.16        | 1284.90        | +258.74
B  Těžba a dobývání                               | 1492.97         | 1486.76         |  -6.21            | 1666.67        | 1818.31        | +151.64
C  Zpracovatelský průmysl                         | 1146.51         | 1315.57         | +169.06           | 1279.90        | 1608.96        | +329.06
D  Výroba a rozvod elektřiny, plynu, tepla...     | 1812.11         | 1913.14         | +101.03           | 2022.94        | 2339.78        | +316.84
E  Zásobování vodou; odpady a sanace              | 1162.50         | 1184.99         |  +22.49           | 1297.75        | 1449.26        | +151.51
F  Stavebnictví                                   | 1107.34         | 1161.98         |  +54.64           | 1236.17        | 1421.12        | +184.95
G  Velkoobchod a maloobchod                       | 1130.43         | 1236.60         | +106.17           | 1261.95        | 1512.37        | +250.42
H  Doprava a skladování                           | 1194.59         | 1215.33         |  +20.74           | 1333.57        | 1486.35        | +152.78
I  Ubytování, stravování a pohostinství           |  724.21         |  794.95         |  +70.74           |  808.47        |  972.23        | +163.76
J  Informační a komunikační činnosti              | 2220.41         | 2340.25         | +119.84           | 2478.74        | 2862.15        | +383.41
K  Peněžnictví a pojišťovnictví                   | 2483.06         | 2264.16         | -218.90           | 2771.95        | 2769.08        |  -2.87
L  Činnosti v oblasti nemovitostí                 | 1193.67         | 1159.61         |  -34.06           | 1332.55        | 1418.21        |  +85.66
M  Profesní, vědecké a technické činnosti         | 1528.85         | 1608.29         |  +79.44           | 1706.72        | 1966.95        | +260.23
N  Administrativní a podpůrné činnosti            |  896.03         |  864.42         |  -31.61           | 1000.28        | 1057.19        |  +56.91
O  Veřejná správa a obrana                        | 1444.45         | 1498.07         |  +53.62           | 1612.50        | 1832.15        | +219.65
P  Vzdělávání                                     | 1242.54         | 1297.13         |  +54.59           | 1387.10        | 1586.40        | +199.30
Q  Zdravotní a sociální péče                      | 1181.23         | 1397.00         | +215.77           | 1318.66        | 1708.54        | +389.88
R  Kulturní, zábavní a rekreační činnosti         | 1043.87         | 1171.57         | +127.70           | 1165.32        | 1432.83        | +267.51
S  Ostatní činnosti                               | 1022.57         |  977.58         |  -44.99           | 1141.53        | 1195.59        |  +54.06
```

*Z dat vyplývá, že ve většině odvětví došlo ke zlepšení kupní síly – zaměstnanci si mohli v roce 2018 dovolit za svou mzdu pořídit více chleba i mléka než v roce 2006. Největší nárůst je patrný u mléka, kde rozdíl činí často stovky litrů navíc.*

*Naopak v některých odvětvích, například peněžnictví a pojišťovnictví (K) nebo administrativní činnosti (N), kupní síla v případě chleba dokonce poklesla. U mléka byl pokles minimální, spíše stagnace.*

*Celkově lze tedy shrnout, že kupní síla obyvatel rostla, ale rozdíly mezi odvětvími jsou výrazné – nejlépe si vedly informační technologie, zdravotnictví nebo veřejný sektor, zatímco část služeb a administrativní profese spíše stagnovaly.*

*Tento vývoj dokládá, že růst mezd předčil růst cen potravin, i když nerovnoměrně podle oboru.*

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
- Některé roky neobsahují kompletní data pro všechny kategorie potravin - "Jakostní víno bílé" s kódem 212101 bylo za celou časovou řadu zachyceno pouze 4x.         Ostatní potraviny 13x.
- Všechny ceny jsou v Kč, mzdy jsou průměrné měsíční hrubé.

Během analýzy se ukázalo, že v tabulce czechia_payroll existují záznamy, které obsahují platnou hodnotu (value), ale u příslušného odvětví (industry_branch) je hodnota NULL.
Tyto záznamy odpovídaly nekategorizovaným datům nebo spadaly do defaultní kategorie „ostatní“. Protože nešlo jednoznačně určit, ke kterému odvětví patří, byly z analýzy vynechány.
Důvodem je, že zahrnutí takových záznamů by mohlo zkreslit výsledky srovnání jednotlivých odvětví, a zároveň by jejich přítomnost neumožnila smysluplné interpretace.

---

## 7️⃣ Autor
**Jméno:** *Ondřej Romaniuk* 
**Datum:** *08/2025*
**Kontakt:** *[LinkedIn](https://www.linkedin.com/in/ond%C5%99ej-romaniuk/) / [GitHub](https://github.com/OndrejRomaniuk)*


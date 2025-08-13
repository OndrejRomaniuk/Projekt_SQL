# 📊 SQL Projekt: Dostupnost základních potravin a mzdový vývoj v ČR a Evropě

## 1️⃣ Úvod do projektu
Tento projekt vznikl v rámci studia SQL (ENGETO) a jeho cílem je:
- analyzovat dostupnost základních potravin v ČR v kontextu průměrných příjmů,
- porovnat cenový a mzdový vývoj za vybrané období,
- doplnit srovnání s dalšími evropskými státy pomocí ukazatelů HDP, GINI a populace.

Výsledky budou sloužit jako datový podklad pro prezentaci na konferenci zaměřené na životní úroveň obyvatel.

---

## 2️⃣ Použitá data

### Primární zdroje
- **Mzdová data** (canchia-payroll) – informace o mzdách v různých odvětvích za několik let.
- **Cenová data** (canchia-price) – informace o cenách vybraných potravin za několik let.
- Číselníky kategorií potravin, odvětví a dalších pomocných dat pro propojení.

### Dodatečné zdroje
- Tabulka `countries` – základní údaje o zemích.
- Tabulka `economic_indicators` – ukazatele HDP, GINI, daňová zátěž atd. pro evropské státy.

> **Poznámka:** Data nebyla měněna v původních tabulkách. Všechny transformace probíhaly až při tvorbě nových tabulek.

---

## 3️⃣ Struktura projektu

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
**Kontakt:** *LinkedIn / GitHub odkaz*  
**Datum:** *08/2025*


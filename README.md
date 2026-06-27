# AdventureWorks Sales Analytics & Dashboards

End-to-end business-intelligence project on the **AdventureWorks** sales dataset:
SQL analysis feeding interactive dashboards built in **Tableau**, **Power BI**, and **Excel**.

## 📊 Overview

The project analyses internet sales for AdventureWorks — total sales, profit,
production cost, and regional / time-based performance — and surfaces the results
through three parallel dashboard implementations.

## 🗂️ Project Structure

```
.
├── data/                  # Source dataset
│   └── adventureworks_dataset.xlsx
├── sql/                   # Analysis queries (MySQL)
│   └── adventureworks_analysis.sql
├── dashboards/
│   ├── tableau/           # .twbx workbook
│   ├── powerbi/           # .pbix report
│   └── excel/             # .xlsb dashboard
└── docs/                  # Screenshots & supporting docs
```

## 🔍 Analysis Highlights

- Total sales, production cost, and profit (aggregate functions)
- Region-wise sales & profit (joins + grouping)
- Year-over-year sales, cost & profit trends

## 🛠️ Tools & Tech

`MySQL` · `Tableau` · `Power BI` · `Excel`

## 🚀 Usage

1. Load `data/adventureworks_dataset.xlsx` into MySQL.
2. Run `sql/adventureworks_analysis.sql` to reproduce the analysis.
3. Open any dashboard under `dashboards/` in its respective tool.

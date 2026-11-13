# Code – ALLBUS replication (R)

**Start:** open `empirical-methods-replication.Rproj` in RStudio, put `ZA5252_v1-0-0.dta` into `data/raw/`, then run `code/00_run_all.R`.
Packages (once): `install.packages(c("haven", "sandwich", "ivreg", "ggplot2"))`

| Script | What it does | Output |
|---|---|---|
| `00_run_all.R` | Runs 01 → 02 → 03 | – |
| `01_clean_allbus.R` | Raw ALLBUS → cleaned data, exactly as the authors' do-file (l. 1–96) | `data/processed/allbus2016_clean.rds/.csv` (gitignored) |
| `02_tables.R` | **Replication:** Table 6, Table 7 (OLS), Table 9 (first stage + reduced form), Table 10 (2SLS), Figure 7 | `output/tables/*.tex`, `output/figures/figure7.*`, `output/paper_vs_ours.csv` |
| `03_extension.R` | **Extension:** (A) weak-instrument-robust inference (tF, Anderson–Rubin) for all Table 10 columns; (B) exclusion-restriction check; (C) plausibly exogenous sensitivity (Conley, Hansen & Rossi 2012) | `output/tables/ext_*.tex`, `output/figures/ext_weakiv.*`, `output/ext_*.csv` |

## Conventions
- Standard errors as in the authors' Stata code: OLS `reg, robust` = **HC1**, IV `ivreg2, robust` = **HC0**.
- Each regression uses its own complete cases (N changes across columns, as in Stata).
- No `setwd()`: all paths are relative to the repo root (that is what the `.Rproj` is for).
- Do **not** commit anything in `data/raw/` or `data/processed/` – it is GESIS microdata.

## Replication status
Every target number matches the paper exactly (`output/paper_vs_ours.csv`, column `diff_coef` = 0):
Table 6 (N = 2,336), Table 7 cols 1–7 (both outcomes), Table 9 first stage 0.519 (0.118) and reduced form 0.337 (0.099), Table 10 cols 1–8 (both outcomes; main result 0.850 (0.339)), Figure 7.

## Extension: key numbers (Israel unjust, Table 10)
| Col. | 2SLS (SE) | First-stage F | 95% CI ±1.96 | 95% CI tF | 95% CI Anderson–Rubin |
|---|---|---|---|---|---|
| 1 | 0.489 (0.111) | 71.9 | [0.27, 0.71] | [0.26, 0.71] | [0.29, 0.74] |
| 4 (main) | 0.850 (0.339) | 10.5 | [0.18, 1.51] | [−0.28, 1.98] | [0.33, 2.18] |
| 8 | 0.981 (0.401) | 8.9 | [0.20, 1.77] | [−0.50, 2.46] | [0.39, 2.82] |

Full results for all columns and both outcomes: `output/ext_weakiv.csv`.

## Extension C: plausibly exogenous instrument (Table 10, col. 4)
If being born 1930–45 also has a direct effect δ on "Israel unjust" (points on the 1–7 scale), the 2SLS estimate becomes β(δ) = (reduced form − δ) / first stage = (0.330 − δ) / 0.388.

| δ | β(δ) | 95% CI Anderson–Rubin |
|---|---|---|
| −0.10 | 1.11 | [0.54, 2.77] |
| 0 (authors) | 0.85 | [0.33, 2.18] |
| 0.13 | 0.52 | [−0.00, 1.46] ← no longer significant |
| 0.27 | 0.15 | = OLS (0.14) |

Figure: `output/figures/ext_plausexog.png`, table: `output/tables/ext_plausexog.tex`, all values: `output/ext_plausexog.csv`.

Credits: `01_clean_allbus.R` and `02_tables.R` written by our team (v2); paths adapted to the repo and reduced form added. tF critical values from Lee, McCrary, Moreira & Porter (2022), as tabulated in the R package `ivDiag` (Lal & Xu, MIT licence).

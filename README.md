# Empirical Methods (HS 2026) – Problem Set 3 & 4: Replication

**Paper:** Binstok, N., Gould, E. & Kaplan, T. – *Policies or Prejudices? An Analysis of Antisemitic and Anti-Israel Views on Social Media and Social Surveys*, Journal of the European Economic Association (jvae013).
**Replikationspaket:** [Link eintragen – den gleichen wie bei der Registrierung auf praxai.ch]

## Deadlines
| Was | Wo | Fällig |
|---|---|---|
| Paper + Datenquelle registrieren | praxai.ch | **16.11.2026** |
| PS3: Replication Report (5–7 S.) + Code | OLAT | 30.11.2026, 23:59 |
| PS4: Interaktive Website + GitHub-Repo | OLAT / GitHub Pages | 14.12.2026, 23:59 |

## Die drei Analysen im Paper
| Analyse | Do-File (Autoren) | Daten |
|---|---|---|
| 1. Twitter-Daten (UK, Tottenham-Spiele) | `original_code/twitter_dofile.do` | `jeea_15km/20km/25km.dta` (je 432 MB, nur lokal) |
| 2. German Social Survey (ALLBUS) 2016 | `original_code/German_Social_Survey_2016_dofile.do` | `ZA5252_v1-0-0.dta` (GESIS, nur lokal) |
| 3. Kaplan & Small (2006) | `original_code/kaplan_and_small_dofile.do` | `data/public/kaplan and small data.dta` |

## Struktur
```
docs/            Aufgabenstellung (Problem Set 3 & 4)
paper/           Online Appendix, Notizen (notes.md)
report/          Report-Template (.tex) und unser Bericht
original_code/   Code der Autoren – UNVERÄNDERT lassen
code/            Unser Code (nummeriert, z. B. 01_clean.do, 02_main_result.do)
data/public/     Kleine, öffentliche Daten (im Repo)
data/raw/        Grosse/lizenzierte Daten – NICHT im Repo, siehe data/README.md
data/processed/  Zwischenergebnisse
output/          Tabellen und Grafiken
website/         Website für PS4
```

## Aufgabenverteilung
| Teil Report | Verantwortlich |
|---|---|
| (a) Introduction | |
| (b) Methodology | |
| (c) Main Result (Tabelle + 1–2 Grafiken) | |
| (d) Critical Evaluation (z. B. OVB-Formel) | |
| (e) Extension, Robustness, „ideale“ Strategie | |

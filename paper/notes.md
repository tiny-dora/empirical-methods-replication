# Notizen zum Paper (Arbeitsnotizen)

> Interne Stichpunkte zum Verstehen und Diskutieren – **nicht** in den Report kopieren.
> Den Report-Text schreiben wir selbst in eigenen Worten (Vorgabe im Problem Set).
> Seitenzahlen = Journal-Seiten (PDF-Seite = Journal-Seite − 2328). Zahlen aus unserem Code: `output/`.

## Forschungsfrage
- Verursachen antisemitische Einstellungen negativere Sichten auf Israel? (kausal, nicht nur Korrelation) – S. 2330–2332
- Allgemeiner Kontext: beeinflussen persönliche Vorurteile politische Meinungen?
- Autoren urteilen **nicht** über Einzelpersonen, nur systematischer Zusammenhang im Durchschnitt – S. 2332
- Warum schwer: Social Desirability Bias (Leute verstecken Vorurteile), bisher fast nur Korrelationen – S. 2330

## Welche Analyse replizieren wir?
- **ALLBUS 2016** (deutsche Umfrage), Abschnitte 4–6, S. 2344–2365
- Twitter (Abschn. 2–3) und ADL (Abschn. 7) nur kurz erwähnen
- Gründe: kleine öffentliche Daten, klare OLS→IV-Struktur, gute Kritikpunkte

## Daten (Abschnitt 4, S. 2344–2352)
- Einziges ALLBUS-Jahr mit Israel-Fragen
- Stichprobe: in DE geboren, Jahrgang 1930–1990, christlich oder konfessionslos → N = 2'336
  - Juden/Muslime ausgeschlossen (direkter Bezug zum Konflikt) → Ergebnis gilt nur für Leute ohne direkten Bezug
- **Y** „Israel nimmt ungerecht Land weg“ (1–7), Mittel 5.30 – Hauptvariable, weil sie Juden nicht erwähnt
  - Mehrdeutig: Ablehnung kann heissen „gerecht“ ODER „es wird kein Land weggenommen“ (S. 2346)
  - Y2 „wegen Israels Politik verstehe ich Leute gegen Juden“, Mittel 3.55 – Robustheit
- **X** „Juden haben zu viel Einfluss“ (1–7), Mittel 3.09; dazu 4 weitere Items + Mittelwert + Faktor
- Table 6: ca. **die Hälfte** der stärksten Israel-Kritiker zeigt keinen Antisemitismus; jünger, gebildeter, linker
- Code-Details (Kollege): „College“ = Abitur (educ==5); „in DE geboren“ = deutsche Staatsbürgerschaft seit Geburt (dn05); County-Variablen = Klassen-Codes, linear; keine Gewichte

## OLS (Abschnitt 5, Table 7, S. 2352–2355)
- 0.118 (nur Alter/Geschlecht) → 0.162 (alle Kontrollen)
- Lesart: +1 Punkt X → +0.16 Punkte Y, bei gleichen Merkmalen
- Autoren: Koeffizient steigt mit Kontrollen → OVB verzerrt eher nicht nach oben (+ Oster-Bounds, App. A.7)
- Kurs: OVB-Formel E(β̂) = β + γ·β̂(q auf X) (Folie 2a/2b)

## IV (Abschnitt 6, S. 2355–2365)
- Instrument Z = geboren 1930–45 (Nazi-Indoktrination, Voigtländer & Voth 2015); Israel existierte damals nicht
- Figure 7: X nach Jahrzehnt 3.91 (1930er) → 2.45 (1980er)
- Relevanz (Table 9): mit linearem Alter nur 0.227* (schwach) → deshalb Kontrolle „vor/nach 1960“ → 0.519
  - Faktisch Vergleich 1930–45 vs. 1946–60
- **Hauptresultat Table 10, Sp. 4: 0.850 (0.339)**, OLS vergleichbar ≈ 0.14 → IV ≈ 5–6× OLS
- IV steigt mit Kontrollen (0.489 → 0.981); Autoren: strengste Annahme = kleinste Schätzung (Fn. 23)
- Grösse: 1 SD X → 1.10 SD Y (IV) vs. 0.18 SD (OLS) – S. 2364
- Erklärung Autoren: Messfehler (Leute verstecken Antisemitismus) → Attenuation Bias
  - Beleg: Interviewer ≥ 75 J. → +0.22 Punkte bei X (S. 2364); Interviewer-IV aber F ≈ 5
- Gegenfaktisch (S. 2365): X auf max. 3 begrenzt → Y −0.76; X = 1 für alle → immer noch 18.5 % stark Israel-kritisch

## Unsere Replikation
- Alles exakt repliziert (Table 6, 7, 9, 10, Figure 7) – `output/paper_vs_ours.csv`
- Reduced Form ergänzt: 0.337 (0.099) (Table 9, Sp. 8)
- Spalte 4: First Stage 0.388, Reduced Form 0.330 → IV = 0.330 / 0.388 = 0.850 (Wald-Logik, Folie 2c)

## Threats (für Teil d)
1. **Omitted Variables (OLS):** z. B. politische Einstellung, allgemeine Fremdenskepsis
2. **Umgekehrte Kausalität:** Wut über Israels Politik → Antisemitismus (Y → X)
3. **Messfehler in X:** Attenuation Bias, β̂_OLS → λβ, λ = σ²x*/(σ²x* + σ²η) (Folie 2b)
   - Wenn NUR Messfehler: λ ≈ 0.14/0.85 ≈ 0.17 → 83 % der Varianz in X wäre Rauschen → sehr viel, unplausibel?
   - Also andere Gründe für IV ≫ OLS mitdiskutieren (LATE, Exclusion-Verletzung)
4. **Exclusion Restriction** (nicht testbar):
   - Jahrgang kann Y direkt beeinflussen: Kriegserfahrung, Nachkriegszeit, Gründung Israels 1948 als junger Mensch – nicht in den Daten
   - Unser Check (`ext_exclusion`): Kohorte 1930–45 ist auch politisch rechter (+0.24), sieht Ausländer (−0.42) und Islam (−0.24) negativer, seltener konfessionslos
   - Richtung unklar:
     - δ > 0 (Konservatismus, Kriegserfahrung → kritischer) → IV **zu gross**
     - δ < 0 (Schuld, Wiedergutmachung 1952, diplomatische Beziehungen 1965 → Israel-freundlicher) → IV **zu klein**
   - Autoren: direkter Effekt „vor 1960 geboren“ nicht signifikant / negativ (S. 2360, 2364) – aber das ist nicht 1930–45 vs. 1946–60
5. **Schwaches Instrument:** First-stage F = 10.5 (Sp. 4), 8.9 (Sp. 8); Paper berichtet F nicht
   - Kurs (Folie 2c, Lee et al. 2022): ±1.96 erst ab F > 104.7 gültig
   - Schwaches Instrument verstärkt Exclusion-Verletzungen: Verzerrung = δ / First Stage = δ / 0.388 ≈ 2.6·δ
6. **LATE:** Effekt gilt für „Complier“ = Ältere, deren Antisemitismus durch Schulzeit geprägt wurde; nicht auf alle übertragbar (Folie „Whose Return Does IV Estimate?“)
7. **Externe Validität:** nur Deutsche ohne direkten Bezug zum Konflikt; nur 2016

## Extension (für Teil e) – Resultate aus `03_extension.R`
### A) Robuste Inferenz bei schwachem Instrument (Table 10, Y = Israel unjust)
| Sp. | IV | F | KI ±1.96 | KI tF | KI Anderson-Rubin |
|---|---|---|---|---|---|
| 1 | 0.489 | 71.9 | [0.27, 0.71] | [0.26, 0.71] | [0.29, 0.74] |
| 4 | 0.850 | 10.5 | [0.18, 1.51] | [−0.28, 1.98], p = 0.14 | [0.33, 2.18] |
| 8 | 0.981 | 8.9 | [0.20, 1.77] | [−0.50, 2.46], p = 0.19 | [0.39, 2.82] |
- tF: Hauptresultat nicht mehr signifikant auf 5 %
- AR (Kurs-Empfehlung, gültig egal wie schwach): Richtung bleibt (KI ohne 0), aber sehr breit → Grösse unsicher
- Grafik: `output/figures/ext_weakiv.png`

### B) Exclusion-Check – siehe Threats Punkt 4 (`output/tables/ext_exclusion.tex`)

### C) „Plausibly exogenous“ (Conley, Hansen & Rossi 2012) – Sp. 4
- Idee: erlaube direkten Effekt δ von Z auf Y; β(δ) = (Reduced Form − δ) / First Stage
- δ = 0 → 0.85 (Annahme der Autoren)
- **δ = 0.13 → AR-KI enthält 0** (nicht mehr signifikant) – das sind nur 0.13 Punkte auf 1–7, ≈ 0.08 SD von Y
- δ = 0.27 → IV = OLS (0.14) → ganze Differenz IV vs. OLS erklärt
- δ = 0.33 → IV = 0
- δ < 0 → Effekt noch grösser (z. B. δ = −0.1 → 1.11)
- Vergleich: dieselbe Kohorte verschiebt andere Einstellungen um 0.24–0.42 Punkte → δ ≈ 0.13 nicht abwegig
- Grafik: `output/figures/ext_plausexog.png`, Tabelle: `output/tables/ext_plausexog.tex`

### D) „Ideale“ Strategie (noch offen – selbst überlegen)
- Ideen zum Diskutieren: Survey-Experiment (z. B. List-Experiment gegen Social Desirability), Panel-Daten mit Einstellungsänderungen, anderes Instrument (regionale Variation in Nazi-Indoktrination?), …

## Offene Fragen fürs Team
- Welche Teile der Extension nehmen wir in den Report (Platz: 5–7 Seiten)? Vorschlag: A + C, B als Argument in (d)
- Wer schreibt welchen Teil (a)–(e)? → README
- Link zum Replikationspaket in README eintragen

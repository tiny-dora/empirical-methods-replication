# =============================================================================
# 01_clean_allbus.R
# Replication of Binstok, Gould & Kaplan (2024), JEEA 22(5)
# Cleans ALLBUS 2016 (ZA5252_v1-0-0.dta) exactly as the authors'
# German_Social_Survey_2016_dofile.do does (do-file lines 1-96 + figure block).
#
# Input : data/raw/ZA5252_v1-0-0.dta      (GESIS; never modified, never committed)
# Output: data/processed/allbus2016_clean.rds and .csv  (gitignored: GESIS microdata)
#
# Needs only: haven (install.packages("haven")).
# Optional check at the end uses: ivreg, sandwich.
# Run from the repo root: open empirical-methods-replication.Rproj in RStudio
# (or run code/00_run_all.R). No setwd() needed, all paths are relative.
# =============================================================================
if (!file.exists("data/raw/ZA5252_v1-0-0.dta"))
  stop("data/raw/ZA5252_v1-0-0.dta not found. Open empirical-methods-replication.Rproj ",
       "(working directory = repo root) and put the GESIS file into data/raw/.")
library(haven)

raw <- read_dta("data/raw/ZA5252_v1-0-0.dta")
d   <- as.data.frame(zap_labels(raw))        # keep the numeric codes, drop Stata labels

# -----------------------------------------------------------------------------
# Step 1. Keep and rename the variables we need               (do-file l. 8-27)
# -----------------------------------------------------------------------------
ren <- c(mj01 = "jews_influence",            mj04 = "jews_not_without_blame",
         mj02 = "jews_shame",                mj06 = "israel_unjust",
         mm02 = "islam_fits_in",             pn11 = "not_proud_german",
         mp03 = "foreigners_enrich_culture", pa01 = "political_spectrum",
         mj05 = "israel_policy",             gr03 = "county_urate",
         gr01 = "county_perc_foreigners",    mg11 = "jews_neighbor_pleasant",
         mj03 = "jews_take_adv",             land = "state")
d <- d[, c("respid", "yborn", "age", "sex", "educ", "rd01", "dn05", "xi03c", names(ren))]
names(d)[match(names(ren), names(d))] <- ren

# -----------------------------------------------------------------------------
# Step 2. ALLBUS missing codes (-14, -11, -10, -9, -8) -> NA   (l. 31-34)
# -----------------------------------------------------------------------------
attitudes <- c("jews_influence", "israel_unjust", "islam_fits_in", "not_proud_german",
               "foreigners_enrich_culture", "political_spectrum", "israel_policy",
               "jews_not_without_blame", "jews_shame", "jews_neighbor_pleasant", "jews_take_adv")
for (v in attitudes) d[[v]][d[[v]] %in% c(-14, -11, -10, -9, -8)] <- NA

# -----------------------------------------------------------------------------
# Step 3. Attitude variables; higher = more negative toward Jews (l. 37-58)
# -----------------------------------------------------------------------------
d$very_proud_german   <- ifelse(is.na(d$not_proud_german), NA, as.numeric(d$not_proud_german == 1))
d$anti_jews_influence <- d$jews_influence               # already: agree = more negative
d$anti_jews_blame     <- d$jews_not_without_blame
d$anti_jews_take_adv  <- d$jews_take_adv
d$anti_jews_shame     <- 8 - d$jews_shame               # reversed: 7 = NOT ashamed
d$anti_jews_neighbor  <- 8 - d$jews_neighbor_pleasant   # reversed: 7 = very unpleasant
d$interviewer_over75  <- as.numeric(d$xi03c >= 5)

# -----------------------------------------------------------------------------
# Step 4. Composite antisemitism measures                      (l. 62-68)
#   Stata `factor ..., factors(2)` = principal factor (SMC communalities),
#   `predict` = regression scores. Estimated on ALL respondents with the five
#   items non-missing (no sample restriction yet), as in the do-file.
# -----------------------------------------------------------------------------
items <- c("anti_jews_influence", "anti_jews_blame", "anti_jews_take_adv",
           "anti_jews_shame", "anti_jews_neighbor")
cc   <- complete.cases(d[, items])
Z    <- scale(d[cc, items])                              # sd with n-1, as Stata
R    <- cor(Z)
Rinv <- solve(R)
Rred <- R; diag(Rred) <- 1 - 1 / diag(Rinv)              # squared multiple correlations
e    <- eigen(Rred, symmetric = TRUE)
L1   <- e$vectors[, 1] * sqrt(e$values[1])
L1   <- L1 * sign(sum(L1))                               # higher = more antisemitic
d$anti_jews_factor_1     <- NA
d$anti_jews_factor_1[cc] <- as.vector(Z %*% (Rinv %*% L1))
cat("Factor loadings (paper fn. 18: .67 .62 .65 .28 .43):", round(L1, 2), "\n")

m <- rowMeans(d[, items], na.rm = TRUE)                  # egen rowmean ignores missing items
d$anti_jews_mean <- ifelse(is.nan(m), NA, m)

# -----------------------------------------------------------------------------
# Step 5. Demographics and instruments                         (l. 70-87)
#   Stata quirk kept on purpose: `gen x = (cond)` gives 0, not missing, when the
#   variable in cond is missing. Hence the !is.na(...) & ... below.
# -----------------------------------------------------------------------------
d$educ[d$educ %in% c(-9, -41, 7)] <- NA                  # no answer, data error, still in school
d$cog  <- as.numeric(!is.na(d$educ) & d$educ == 5)       # "college" = university entrance qual.
d$age[d$age == -32] <- NA
d$age2 <- d$age^2
d$male <- as.numeric(d$sex == 1)
d$non_christian <- ifelse(d$rd01 %in% c(-10, -9), NA, as.numeric(d$rd01 == 5))
names(d)[names(d) == "rd01"] <- "religion"               # -9 / -7 stay as own categories (as in Stata)
d$religion_none <- as.numeric(d$religion == 6)
d$native        <- ifelse(d$dn05 == -10, NA, as.numeric(d$dn05 == 1))   # German citizen since birth
d$cohort_1930_45 <- as.numeric(!is.na(d$yborn) & d$yborn >= 1930 & d$yborn <= 1945)  # instrument
d$cohort_half_1  <- as.numeric(!is.na(d$yborn) & d$yborn < 1960)                     # born before 1960
d$yborn_decade   <- ifelse(d$yborn >= 1920 & d$yborn <= 1999, floor(d$yborn / 10) * 10, NA)

# -----------------------------------------------------------------------------
# Step 6. Sample flags
#   sample_main   : $SAMPLE_1 (l. 108). Note Stata treats missing non_christian
#                   as "not equal to 1", so those 3 respondents stay in.
#   sample_table6 : estimation sample of the Table 7 col. 7 Israel-policy
#                   regression (l. 120-121) -> N = 2,336
#   sample_fig    : figure sample, born up to 1989 (l. 885)
# -----------------------------------------------------------------------------
base <- (is.na(d$non_christian) | d$non_christian != 1) & d$native %in% 1 &
        d$yborn >= 1930 & d$yborn <= 1990
d$sample_main <- as.numeric(base)
t6_vars <- c("israel_policy", "anti_jews_influence", "age", "age2", "male", "native", "educ",
             "county_perc_foreigners", "county_urate", "state", "political_spectrum", "religion",
             "very_proud_german", "foreigners_enrich_culture", "islam_fits_in")
d$sample_table6 <- as.numeric(base & complete.cases(d[, t6_vars]))
d$sample_fig    <- as.numeric(base & d$yborn <= 1989)

# -----------------------------------------------------------------------------
# Step 7. Save
#   Categorical controls (educ, state, political_spectrum, religion) are kept
#   as numeric codes; wrap them in factor() inside the regression formulas.
# -----------------------------------------------------------------------------
keep <- c("respid", "yborn", "yborn_decade", "age", "age2", "male", "native", "educ", "cog",
          "religion", "religion_none", "non_christian", "state", "county_perc_foreigners",
          "county_urate", "political_spectrum", "very_proud_german", "foreigners_enrich_culture",
          "islam_fits_in", "israel_unjust", "israel_policy", "anti_jews_influence", "anti_jews_blame",
          "anti_jews_take_adv", "anti_jews_shame", "anti_jews_neighbor", "anti_jews_factor_1",
          "anti_jews_mean", "cohort_1930_45", "cohort_half_1", "interviewer_over75",
          "sample_main", "sample_table6", "sample_fig")
clean <- d[, keep]
dir.create("data/processed", showWarnings = FALSE, recursive = TRUE)
saveRDS(clean, "data/processed/allbus2016_clean.rds")
write.csv(clean, "data/processed/allbus2016_clean.csv", row.names = FALSE, na = "")

# -----------------------------------------------------------------------------
# Step 8. Checks against the paper
# -----------------------------------------------------------------------------
t6 <- clean[clean$sample_table6 == 1, ]
cat("Table 6 N           :", nrow(t6), "  (paper 2,336)\n")
cat("Israel unjust mean  :", round(mean(t6$israel_unjust, na.rm = TRUE), 2), " (paper 5.30)\n")
cat("Jews influence mean :", round(mean(t6$anti_jews_influence), 2), " (paper 3.09)\n")
cat("Age mean            :", round(mean(t6$age), 2), "(paper 54.59)\n")
cat("Figure 7 means      :\n")
print(round(tapply(clean$anti_jews_influence[clean$sample_fig == 1],
                   clean$yborn_decade[clean$sample_fig == 1], mean, na.rm = TRUE), 2))
cat("                      (paper 3.91 3.66 3.21 2.87 2.82 2.45)\n")

# Optional: Table 10, col. 4 (paper 0.850, SE 0.339). ivreg2 'robust' = HC0.
if (requireNamespace("ivreg", quietly = TRUE) && requireNamespace("sandwich", quietly = TRUE)) {
  s  <- clean[clean$sample_main == 1, ]
  iv <- ivreg::ivreg(israel_unjust ~ anti_jews_influence + cohort_half_1 + male +
                       county_perc_foreigners + county_urate + factor(educ) + factor(state) |
                       cohort_1930_45 + cohort_half_1 + male +
                       county_perc_foreigners + county_urate + factor(educ) + factor(state),
                     data = s)
  se <- sqrt(diag(sandwich::vcovHC(iv, type = "HC0")))["anti_jews_influence"]
  cat("Table 10 col 4      :", round(coef(iv)["anti_jews_influence"], 3),
      "(SE", round(se, 3), ")  (paper 0.850, SE 0.339)\n")
}

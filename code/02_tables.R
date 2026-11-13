# =============================================================================
# 02_tables.R
# Replication of Binstok, Gould & Kaplan (2024): Tables 6, 7, 9 (first stage),
# 10 and Figure 7, from the cleaned ALLBUS data made by 01_clean_allbus.R.
#
# Input : data/processed/allbus2016_clean.rds
# Output: output/tables/*.tex      (LaTeX, booktabs; \input{} them in the report)
#         output/paper_vs_ours.csv (every number next to the paper's)
#         output/figures/figure7.pdf / .png
#
# Packages: install.packages(c("sandwich", "ivreg", "ggplot2"))
# Run from the project root (open the .Rproj first).
#
# Standard errors follow the authors' Stata code:
#   OLS  `reg ..., robust`    = HC1
#   IV   `ivreg2 ..., robust` = HC0 (no small-sample correction)
# =============================================================================

library(sandwich)
library(ivreg)
library(ggplot2)

dir.create("output/tables",  recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

d <- readRDS("data/processed/allbus2016_clean.rds")
s <- d[d$sample_main == 1, ]      # authors' $SAMPLE_1, N = 2,795

# -----------------------------------------------------------------------------
# 1. Control sets SPEC_1 ... SPEC_7 (do-file l. 99-105)
#    `native` is left out: it equals 1 for everyone in the sample, so Stata
#    drops it anyway. `num` enter linearly, `fac` as categories (factor()).
# -----------------------------------------------------------------------------
spec <- list(
  list(num = "male",                                                     fac = character()),
  list(num = "male",                                                     fac = "educ"),
  list(num = c("male", "county_perc_foreigners", "county_urate"),        fac = c("educ", "state")),
  list(num = c("male", "county_perc_foreigners", "county_urate"),        fac = c("educ", "state", "political_spectrum", "religion"))
)
spec[[5]] <- list(num = c(spec[[4]]$num, "very_proud_german"),         fac = spec[[4]]$fac)
spec[[6]] <- list(num = c(spec[[5]]$num, "foreigners_enrich_culture"), fac = spec[[4]]$fac)
spec[[7]] <- list(num = c(spec[[6]]$num, "islam_fits_in"),             fac = spec[[4]]$fac)

rhs <- function(cs) paste(c(cs$num, if (length(cs$fac)) sprintf("factor(%s)", cs$fac)), collapse = " + ")
add_num <- function(cs, extra) list(num = c(extra, cs$num), fac = cs$fac)

# Each regression runs on its own complete cases, as in Stata (N changes across columns).
complete_rows <- function(vars) s[complete.cases(s[, vars]), ]

# -----------------------------------------------------------------------------
# 2. Estimation helpers
# -----------------------------------------------------------------------------
run_ols <- function(y, x, cs, type = "HC1") {
  dd <- complete_rows(c(y, x, cs$num, cs$fac))
  m  <- lm(as.formula(paste(y, "~", x, "+", rhs(cs))), data = dd)
  V  <- vcovHC(m, type = type)
  data.frame(coef = unname(coef(m)[x]), se = sqrt(V[x, x]), n = nobs(m), F = NA)
}

run_iv <- function(y, x, z, cs) {
  dd <- complete_rows(c(y, x, z, cs$num, cs$fac))
  ex <- rhs(cs)
  m  <- ivreg(as.formula(paste(y, "~", x, "+", ex, "|", z, "+", ex)), data = dd)
  V  <- vcovHC(m, type = "HC0")
  fs <- lm(as.formula(paste(x, "~", z, "+", ex)), data = dd)        # first stage
  Vf <- vcovHC(fs, type = "HC0")
  data.frame(coef = unname(coef(m)[x]), se = sqrt(V[x, x]), n = nobs(m),
             F = unname(coef(fs)[z])^2 / Vf[z, z])                    # robust first-stage F (1 instrument)
}

# -----------------------------------------------------------------------------
# 3. Paper values (read off the published tables)
# -----------------------------------------------------------------------------
paper <- list(
  t7_unjust  = data.frame(coef = c(.118, .139, .144, .150, .149, .159, .162),
                          se   = c(.0180, .0188, .0189, .0196, .0197, .0201, .0204),
                          n    = c(2438, 2438, 2438, 2378, 2330, 2321, 2309)),
  t7_policy  = data.frame(coef = c(.389, .396, .398, .389, .386, .384, .376),
                          se   = c(.0204, .0212, .0213, .0218, .0220, .0224, .0226),
                          n    = c(2470, 2470, 2470, 2410, 2359, 2349, 2336)),
  t10_unjust = data.frame(coef = c(.489, .589, .830, .850, .914, .854, .934, .981),
                          se   = c(.111, .227, .330, .339, .358, .363, .382, .401)),
  t10_policy = data.frame(coef = c(1.120, 1.204, 1.434, 1.409, 1.410, 1.405, 1.466, 1.528),
                          se   = c(.136, .286, .414, .413, .431, .450, .471, .513)),
  t9         = data.frame(coef = .519, se = .118),
  t9_rf      = data.frame(coef = .337, se = .0988)
)

# -----------------------------------------------------------------------------
# 4. Table 7: OLS, columns 1-7, both outcomes  (do-file l. 169-198)
#    outcome ~ Jews too much influence + age + age^2 + SPEC_k
# -----------------------------------------------------------------------------
t7 <- list()
for (y in c("israel_unjust", "israel_policy")) {
  t7[[y]] <- do.call(rbind, lapply(1:7, function(k)
    run_ols(y, "anti_jews_influence", add_num(spec[[k]], c("age", "age2")))))
}

# -----------------------------------------------------------------------------
# 5. Table 9, third panel, column 1: first stage  (do-file l. 242-245)
#    Jews too much influence ~ born 1930-45 + born before 1960 + male
# -----------------------------------------------------------------------------
t9 <- run_ols("anti_jews_influence", "cohort_1930_45", add_num(spec[[1]], "cohort_half_1"))

# Reduced form, same panel, column 8 (do-file l. 242-245 with varbx = israel_unjust):
#   Israel unjust ~ born 1930-45 + born before 1960 + male     (paper: 0.337, SE 0.0988)
# The course slides (2c, "Weak Instruments III") ask to always report the first
# stage AND the reduced form next to 2SLS. Note: IV = reduced form / first stage
# only holds exactly when both use the same sample (see 03_extension.R).
t9_rf <- run_ols("israel_unjust", "cohort_1930_45", add_num(spec[[1]], "cohort_half_1"))

# -----------------------------------------------------------------------------
# 6. Table 10: IV, columns 1-8, both outcomes  (do-file l. 266-300)
#    col 1: SPEC_1 only;  col c >= 2: born before 1960 + SPEC_(c-1)
#    Main result = upper panel, column 4.
# -----------------------------------------------------------------------------
t10 <- list()
for (y in c("israel_unjust", "israel_policy")) {
  t10[[y]] <- do.call(rbind, lapply(1:8, function(c) {
    cs <- if (c == 1) spec[[1]] else add_num(spec[[c - 1]], "cohort_half_1")
    run_iv(y, "anti_jews_influence", "cohort_1930_45", cs)
  }))
}

# -----------------------------------------------------------------------------
# 7. Table 6: summary statistics, column 1 (do-file l. 119-137)
# -----------------------------------------------------------------------------
t6v <- data.frame(
  var   = c("israel_unjust", "israel_policy", "anti_jews_influence", "anti_jews_blame",
            "anti_jews_take_adv", "anti_jews_shame", "anti_jews_neighbor",
            "foreigners_enrich_culture", "islam_fits_in", "anti_jews_factor_1", "anti_jews_mean",
            "political_spectrum", "very_proud_german", "religion_none", "cog", "age",
            "cohort_1930_45", "cohort_half_1", "male"),
  label = c("Israel---unjust to take Palestinian land", "Israeli policy justifies antisemitism",
            "Jews---too much influence in the world", "Jews are not without blame for persecution",
            "Many Jews take advantage of the Holocaust", "I'm not ashamed of German crimes against Jews",
            "It would be unpleasant to have a Jewish neighbor", "Foreigners enrich German culture",
            "Islam fits in with German society", "First factor of five views about Jews",
            "Mean of five views about Jews", "Political spectrum (1 left to 10 right)",
            "Very proud German (dummy)", "No religion (dummy)", "College graduate",
            "Age", "Cohort: born 1930--1945", "Cohort: born 1930--1960", "Male"),
  p_mean = c(5.30, 3.55, 3.09, 2.26, 3.92, 2.20, 3.45, 4.18, 2.75, 0.00, 2.99, 5.06, 0.27, 0.43, 0.29, 54.59, 0.18, 0.47, 0.52),
  p_sd   = c(1.62, 1.97, 1.92, 1.72, 2.04, 1.76, 1.37, 1.84, 1.77, 0.82, 1.19, 1.72, 0.45, 0.49, 0.45, 15.24, 0.39, 0.50, 0.50))
t6s <- d[d$sample_table6 == 1, ]
t6v$mean <- sapply(t6v$var, function(v) mean(t6s[[v]], na.rm = TRUE))
t6v$sd   <- sapply(t6v$var, function(v) sd(t6s[[v]],   na.rm = TRUE))

# -----------------------------------------------------------------------------
# 8. Paper vs. ours (one CSV with every number)
# -----------------------------------------------------------------------------
cmp <- function(table, ours, pap) {
  k <- seq_len(nrow(ours))
  data.frame(table = table, column = k,
             paper_coef = pap$coef[k], our_coef = round(ours$coef, 3),
             paper_se   = pap$se[k],   our_se   = round(ours$se, 4),
             paper_n    = if (!is.null(pap$n)) pap$n[k] else NA, our_n = ours$n,
             first_stage_F = round(ours$F, 2))
}
comparison <- rbind(
  cmp("Table 7, Israel unjust (OLS)",       t7$israel_unjust,  paper$t7_unjust),
  cmp("Table 7, Israeli policy (OLS)",      t7$israel_policy,  paper$t7_policy),
  cmp("Table 9, first stage (born 1930-45)", t9,               paper$t9),
  cmp("Table 9, reduced form (Israel unjust)", t9_rf,          paper$t9_rf),
  cmp("Table 10, Israel unjust (IV)",       t10$israel_unjust, paper$t10_unjust),
  cmp("Table 10, Israeli policy (IV)",      t10$israel_policy, paper$t10_policy))
comparison$diff_coef <- round(comparison$our_coef - comparison$paper_coef, 3)
write.csv(comparison, "output/paper_vs_ours.csv", row.names = FALSE)
write.csv(t6v[, c("label", "p_mean", "mean", "p_sd", "sd")], "output/table6_vs_paper.csv", row.names = FALSE)
print(comparison)

# -----------------------------------------------------------------------------
# 9. LaTeX writers (booktabs; the report template already loads it)
# -----------------------------------------------------------------------------
stars <- function(b, se) {
  p <- 2 * pnorm(-abs(b / se))
  ifelse(p < .01, "^{***}", ifelse(p < .05, "^{**}", ifelse(p < .1, "^{*}", "")))
}
fmt  <- function(x, k = 3) formatC(x, format = "f", digits = k, big.mark = ",")
cell <- function(b, se) sprintf("$%s%s$", fmt(b), stars(b, se))
row  <- function(label, cells) paste0(label, " & ", paste(cells, collapse = " & "), " \\\\")

write_reg_table <- function(file, res, paper_res, colnames, yes_rows, show_F = FALSE) {
  k <- length(colnames)
  out <- c(sprintf("\\begin{tabular}{l%s}", strrep("c", k)), "\\toprule",
           row("", colnames), "\\midrule",
           row("Jews have too much influence", cell(res$coef, res$se)),
           row("", sprintf("(%s)", fmt(res$se))),
           row("\\textit{Paper}", sprintf("\\textit{%s}", fmt(paper_res$coef))),
           row("", sprintf("\\textit{(%s)}", fmt(paper_res$se))),
           "\\midrule")
  if (show_F) out <- c(out, row("First-stage $F$ (robust)", ifelse(is.na(res$F), "--", fmt(res$F, 1))))
  out <- c(out, row("Observations", fmt(res$n, 0)))
  for (r in names(yes_rows)) out <- c(out, row(r, ifelse(yes_rows[[r]], "Yes", "")))
  writeLines(c(out, "\\bottomrule", "\\end{tabular}"), file)
}

cols7  <- sprintf("(%d)", 1:7)
yes7   <- list("Age, age$^2$, gender"                 = rep(TRUE, 7),
               "Education"                            = 1:7 >= 2,
               "County foreigners, unemployment, state" = 1:7 >= 3,
               "Political spectrum, religion"         = 1:7 >= 4,
               "Very proud German"                    = 1:7 >= 5,
               "Foreigners enrich culture"            = 1:7 >= 6,
               "Islam fits in"                        = 1:7 >= 7)
write_reg_table("output/tables/table7_unjust.tex", t7$israel_unjust, paper$t7_unjust, cols7, yes7)
write_reg_table("output/tables/table7_policy.tex", t7$israel_policy, paper$t7_policy, cols7, yes7)

cols10 <- sprintf("(%d)", 1:8)
yes10  <- list("Gender"                               = rep(TRUE, 8),
               "Born before 1960"                     = 1:8 >= 2,
               "Education"                            = 1:8 >= 3,
               "County foreigners, unemployment, state" = 1:8 >= 4,
               "Political spectrum, religion"         = 1:8 >= 5,
               "Very proud German"                    = 1:8 >= 6,
               "Foreigners enrich culture"            = 1:8 >= 7,
               "Islam fits in"                        = 1:8 >= 8)
write_reg_table("output/tables/table10_unjust.tex", t10$israel_unjust, paper$t10_unjust, cols10, yes10, show_F = TRUE)
write_reg_table("output/tables/table10_policy.tex", t10$israel_policy, paper$t10_policy, cols10, yes10, show_F = TRUE)

# Main report table: OLS (T7 c1, c7) next to IV (T10 c1, c2, c4, c8), outcome = Israel unjust
main     <- rbind(t7$israel_unjust[c(1, 7), ], t10$israel_unjust[c(1, 2, 4, 8), ])
main_pap <- rbind(paper$t7_unjust[c(1, 7), c("coef", "se")], paper$t10_unjust[c(1, 2, 4, 8), ])
main$F[1:2] <- NA
yes_main <- list("Gender"                       = rep(TRUE, 6),
                 "Age, age$^2$"                 = c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE),
                 "Born before 1960"             = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE),
                 "Education, county, state"     = c(FALSE, TRUE, FALSE, FALSE, TRUE, TRUE),
                 "Politics, religion, views"    = c(FALSE, TRUE, FALSE, FALSE, FALSE, TRUE))
write_reg_table("output/tables/table_main.tex", main, main_pap,
                c("OLS (1)", "OLS (2)", "IV (3)", "IV (4)", "IV (5)", "IV (6)"), yes_main, show_F = TRUE)

# Table 6
t6tex <- c("\\begin{tabular}{lcccc}", "\\toprule",
           " & Mean & SD & \\textit{Paper mean} & \\textit{Paper SD} \\\\", "\\midrule",
           sprintf("%s & %s & %s & \\textit{%s} & \\textit{%s} \\\\", t6v$label,
                   fmt(t6v$mean, 2), fmt(t6v$sd, 2), fmt(t6v$p_mean, 2), fmt(t6v$p_sd, 2)),
           "\\midrule", sprintf("Observations & \\multicolumn{4}{c}{%s} \\\\", fmt(nrow(t6s), 0)),
           "\\bottomrule", "\\end{tabular}")
writeLines(t6tex, "output/tables/table6.tex")

# -----------------------------------------------------------------------------
# 10. Figure 7: mean "Jews have too much influence" by birth decade (l. 968-975)
# -----------------------------------------------------------------------------
f <- d[d$sample_fig == 1 & !is.na(d$anti_jews_influence), ]
fig7 <- aggregate(anti_jews_influence ~ yborn_decade, data = f, FUN = mean)
fig7$decade <- paste0(fig7$yborn_decade, "s")
print(fig7)   # paper: 3.91 3.66 3.21 2.87 2.82 2.45

p7 <- ggplot(fig7, aes(x = decade, y = anti_jews_influence)) +
  geom_col(fill = "#1F4E79", width = 0.65) +
  geom_text(aes(label = sprintf("%.2f", anti_jews_influence)), vjust = -0.5, size = 3.5) +
  scale_y_continuous(limits = c(0, 7), breaks = 1:7) +
  labs(x = "Birth cohort decade",
       y = "Jews have too much influence\n(1 = completely disagree, 7 = completely agree)") +
  theme_minimal(base_size = 11) +
  theme(panel.grid.major.x = element_blank(), panel.grid.minor = element_blank())
ggsave("output/figures/figure7.pdf", p7, width = 6, height = 4)
ggsave("output/figures/figure7.png", p7, width = 6, height = 4, dpi = 300)

cat("\nDone. Tables in output/tables/, figure in output/figures/, comparison in output/paper_vs_ours.csv\n")

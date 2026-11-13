# =============================================================================
# 03_extension.R
# Extension to the replication of Binstok, Gould & Kaplan (2024), ALLBUS part.
#
# A. Weak-instrument-robust inference for Table 10 (all 8 columns, both outcomes)
#    Course slides 2c ("Weak Instruments III: The New Standard"):
#      - Lee, McCrary, Moreira & Porter (2022, AER): with one instrument the usual
#        +-1.96 t-test is only valid if the first-stage F > 104.7.
#      - Below that, use the tF procedure or Anderson-Rubin (AR) confidence sets,
#        and report first stage AND reduced form next to 2SLS.
#    Our first-stage F is 72 in column 1 and only 9-18 in columns 2-8.
#
# B. Exclusion-restriction check: does the instrument (born 1930-45) also shift
#    other worldviews that may affect views on Israel directly?
#    (= Table 9, third panel, all columns; do-file l. 242-245)
#
# Input : data/processed/allbus2016_clean.rds   (from 01_clean_allbus.R)
# Output: output/tables/ext_weakiv_unjust.tex, ext_weakiv_policy.tex,
#         output/tables/ext_exclusion.tex, output/ext_weakiv.csv,
#         output/figures/ext_weakiv.pdf / .png
#
# Packages: sandwich, ivreg, ggplot2 (same as 02_tables.R)
# =============================================================================

library(sandwich)
library(ivreg)
library(ggplot2)

d <- readRDS("data/processed/allbus2016_clean.rds")
s <- d[d$sample_main == 1, ]

# Same control sets as 02_tables.R (SPEC_1 ... SPEC_7 in the do-file)
spec <- list(
  list(num = "male",                                              fac = character()),
  list(num = "male",                                              fac = "educ"),
  list(num = c("male", "county_perc_foreigners", "county_urate"), fac = c("educ", "state")),
  list(num = c("male", "county_perc_foreigners", "county_urate"), fac = c("educ", "state", "political_spectrum", "religion"))
)
spec[[5]] <- list(num = c(spec[[4]]$num, "very_proud_german"),         fac = spec[[4]]$fac)
spec[[6]] <- list(num = c(spec[[5]]$num, "foreigners_enrich_culture"), fac = spec[[4]]$fac)
spec[[7]] <- list(num = c(spec[[6]]$num, "islam_fits_in"),             fac = spec[[4]]$fac)
add_num <- function(cs, extra) list(num = c(extra, cs$num), fac = cs$fac)
rhs     <- function(cs) paste(c(cs$num, if (length(cs$fac)) sprintf("factor(%s)", cs$fac)), collapse = " + ")
spec_t10 <- function(c) if (c == 1) spec[[1]] else add_num(spec[[c - 1]], "cohort_half_1")

# -----------------------------------------------------------------------------
# A1. tF critical value (Lee, McCrary, Moreira & Porter 2022, Table 3)
#     Table values as implemented in the R package ivDiag (Lal & Xu, MIT licence).
#     Input: first-stage F. Output: critical value that replaces 1.96.
# -----------------------------------------------------------------------------
tF_crit <- function(Fstat) {
  F0  <- seq(2, 10.3, 0.1)                    # sqrt(F) grid
  cF0 <- c(18.66, 9.74, 7.37, 6.18, 5.43, 4.92, 4.54, 4.25, 4.01, 3.82, 3.65, 3.51, 3.39, 3.29, 3.19, 3.11, 3.03,
           2.97, 2.91, 2.85, 2.80, 2.75, 2.71, 2.67, 2.63, 2.60, 2.57, 2.54, 2.51, 2.48, 2.46, 2.43, 2.41, 2.39, 2.37,
           2.35, 2.33, 2.32, 2.30, 2.29, 2.27, 2.26, 2.24, 2.23, 2.22, 2.21, 2.20, 2.19, 2.17, 2.16, 2.16, 2.15, 2.14,
           2.13, 2.12, 2.11, 2.10, 2.10, 2.09, 2.08, 2.08, 2.07, 2.06, 2.06, 2.05, 2.04, 2.04, 2.03, 2.03, 2.02, 2.02,
           2.01, 2.01, 2.00, 2.00, 1.99, 1.99, 1.99, 1.98, 1.98, 1.97, 1.97, 1.97, 1.96)
  f <- sqrt(Fstat)
  if (f < 2) return(Inf)                      # F < 4: no finite valid critical value
  if (f >= 10.3) return(1.96)                 # F >= 104.7 (= 10.23^2): usual 1.96 is fine
  approx(F0, cF0, xout = f)$y                 # linear interpolation in sqrt(F)
}

# -----------------------------------------------------------------------------
# A2. Anderson-Rubin 95% confidence set (heteroskedasticity-robust, HC0)
#     H0: beta = b  <=>  in  y - b*x = z*g + W'd + e  the coefficient g is 0.
#     The AR set = all b that are NOT rejected. It is valid however weak z is.
#     By Frisch-Waugh-Lovell we first partial out the controls W (as in lecture
#     2a). With one instrument the set solves a quadratic  A b^2 + B b + C <= 0:
#       A > 0 (robust first-stage F > 3.84) -> bounded interval
#       A < 0                               -> unbounded (two rays or whole line)
# -----------------------------------------------------------------------------
ar_set <- function(yt, xt, zt, crit = qchisq(.95, 1)) {
  S   <- sum(zt^2)
  rho <- sum(zt * yt) / S                     # reduced form   (y on z | W)
  pi_ <- sum(zt * xt) / S                     # first stage    (x on z | W)
  uy  <- yt - rho * zt                        # residuals of the two partialled regressions
  ux  <- xt - pi_ * zt
  k   <- crit / S^2
  A   <- pi_^2      - k * sum(zt^2 * ux^2)
  B   <- -2 * rho * pi_ + 2 * k * sum(zt^2 * uy * ux)
  C   <- rho^2      - k * sum(zt^2 * uy^2)
  disc <- B^2 - 4 * A * C
  if (A > 0) {
    if (disc < 0) return(c(lo = NA, hi = NA, type = "empty"))
    r <- sort((-B + c(-1, 1) * sqrt(disc)) / (2 * A))
    return(c(lo = r[1], hi = r[2], type = "bounded"))
  }
  if (disc < 0) return(c(lo = -Inf, hi = Inf, type = "whole line"))
  r <- sort((-B + c(-1, 1) * sqrt(disc)) / (2 * A))
  c(lo = r[1], hi = r[2], type = "unbounded: (-Inf, lo] U [hi, Inf)")
}

# -----------------------------------------------------------------------------
# A3. One column: first stage, reduced form, 2SLS, tF, AR (all on the same sample)
# -----------------------------------------------------------------------------
weak_iv_column <- function(y, c) {
  cs <- spec_t10(c)
  x  <- "anti_jews_influence"; z <- "cohort_1930_45"
  dd <- s[complete.cases(s[, c(y, x, z, cs$num, cs$fac)]), ]
  ex <- rhs(cs)

  iv <- ivreg(as.formula(paste(y, "~", x, "+", ex, "|", z, "+", ex)), data = dd)
  b  <- unname(coef(iv)[x]); se <- sqrt(vcovHC(iv, type = "HC0")[x, x])

  fs <- lm(as.formula(paste(x, "~", z, "+", ex)), data = dd)
  rf <- lm(as.formula(paste(y, "~", z, "+", ex)), data = dd)
  pi_ <- unname(coef(fs)[z]); pi_se <- sqrt(vcovHC(fs, type = "HC0")[z, z])
  rho <- unname(coef(rf)[z]); rho_se <- sqrt(vcovHC(rf, type = "HC0")[z, z])
  Fst <- (pi_ / pi_se)^2                       # robust first-stage F (one instrument)

  cF <- tF_crit(Fst)

  # Partial out the controls (FWL), then AR
  W  <- model.matrix(as.formula(paste("~", ex)), data = dd)
  res <- function(v) unname(lm.fit(W, v)$residuals)
  ar <- ar_set(res(dd[[y]]), res(dd[[x]]), res(dd[[z]]))

  data.frame(outcome = y, column = c, n = nrow(dd),
             first_stage = pi_, first_stage_se = pi_se, F = Fst,
             reduced_form = rho, reduced_form_se = rho_se,
             wald_ratio = rho / pi_,                       # = 2SLS with one instrument
             iv = b, iv_se = se,
             ci_lo = b - 1.96 * se, ci_hi = b + 1.96 * se,
             tF_crit = cF, tF_lo = b - cF * se, tF_hi = b + cF * se,
             tF_p = 2 * (1 - pnorm(abs(b / se) / (cF / 1.96))),
             AR_lo = as.numeric(ar["lo"]), AR_hi = as.numeric(ar["hi"]), AR_type = ar["type"],
             row.names = NULL)
}

res_all <- do.call(rbind, lapply(c("israel_unjust", "israel_policy"), function(y)
  do.call(rbind, lapply(1:8, function(c) weak_iv_column(y, c)))))

stopifnot(all(abs(res_all$wald_ratio - res_all$iv) < 1e-8))   # sanity check: IV = RF / FS
write.csv(res_all, "output/ext_weakiv.csv", row.names = FALSE)
print(res_all[, c("outcome", "column", "F", "iv", "iv_se", "ci_lo", "ci_hi", "tF_crit",
                  "tF_lo", "tF_hi", "tF_p", "AR_lo", "AR_hi", "AR_type")], digits = 3)

# -----------------------------------------------------------------------------
# A4. LaTeX table for the report (one per outcome)
# -----------------------------------------------------------------------------
fmt <- function(x, k = 3) ifelse(is.infinite(x), ifelse(x > 0, "$\\infty$", "$-\\infty$"),
                                 formatC(x, format = "f", digits = k))
ci  <- function(lo, hi) sprintf("[%s, %s]", fmt(lo, 2), fmt(hi, 2))
ar_ci <- function(r) if (grepl("unbounded", r$AR_type)) sprintf("$(-\\infty, %s] \\cup [%s, \\infty)$", fmt(r$AR_lo, 2), fmt(r$AR_hi, 2)) else
                     if (r$AR_type == "whole line") "$(-\\infty, \\infty)$" else ci(r$AR_lo, r$AR_hi)
row <- function(label, cells) paste0(label, " & ", paste(cells, collapse = " & "), " \\\\")

write_weakiv <- function(y, file) {
  r <- res_all[res_all$outcome == y, ]
  out <- c(sprintf("\\begin{tabular}{l%s}", strrep("c", nrow(r))), "\\toprule",
           row("", sprintf("(%d)", r$column)), "\\midrule",
           row("First stage: born 1930--45", fmt(r$first_stage)),
           row("", sprintf("(%s)", fmt(r$first_stage_se))),
           row("First-stage $F$ (robust)", fmt(r$F, 1)),
           row("Reduced form: born 1930--45", fmt(r$reduced_form)),
           row("", sprintf("(%s)", fmt(r$reduced_form_se))),
           "\\midrule",
           row("2SLS: Jews too much influence", fmt(r$iv)),
           row("", sprintf("(%s)", fmt(r$iv_se))),
           row("95\\% CI, $\\pm 1.96$", ci(r$ci_lo, r$ci_hi)),
           row("tF critical value", fmt(r$tF_crit, 2)),
           row("95\\% CI, tF", ci(r$tF_lo, r$tF_hi)),
           row("$p$-value, tF", fmt(r$tF_p)),
           row("95\\% CI, Anderson--Rubin", sapply(seq_len(nrow(r)), function(i) ar_ci(r[i, ]))),
           "\\midrule",
           row("Observations", formatC(r$n, format = "d", big.mark = ",")),
           "\\bottomrule", "\\end{tabular}")
  writeLines(out, file)
}
write_weakiv("israel_unjust", "output/tables/ext_weakiv_unjust.tex")
write_weakiv("israel_policy", "output/tables/ext_weakiv_policy.tex")

# -----------------------------------------------------------------------------
# A5. Figure: 2SLS estimate with conventional, tF and AR intervals (Israel unjust)
# -----------------------------------------------------------------------------
r  <- res_all[res_all$outcome == "israel_unjust", ]
lim <- c(-1, 4)                                     # clip unbounded AR sets for plotting
clip <- function(v) pmin(pmax(v, lim[1]), lim[2])
pl <- rbind(
  data.frame(column = r$column, type = "Conventional (+/- 1.96)", lo = r$ci_lo, hi = r$ci_hi),
  data.frame(column = r$column, type = "tF (Lee et al. 2022)",      lo = r$tF_lo, hi = r$tF_hi),
  data.frame(column = r$column, type = "Anderson-Rubin",            lo = r$AR_lo, hi = r$AR_hi))
pl$unbounded <- grepl("unbounded|whole", rep(r$AR_type, 3)) & pl$type == "Anderson-Rubin"
pl$lo <- clip(pl$lo); pl$hi <- clip(pl$hi)
pl$type <- factor(pl$type, levels = c("Conventional (+/- 1.96)", "tF (Lee et al. 2022)", "Anderson-Rubin"))
pl$x <- r$column[match(pl$column, r$column)] + (as.integer(pl$type) - 2) * 0.22

p <- ggplot() +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_segment(data = pl[!pl$unbounded, ], aes(x = x, xend = x, y = lo, yend = hi, colour = type), linewidth = 1) +
  geom_point(data = r, aes(x = column, y = iv), size = 2.2) +
  geom_text(data = data.frame(column = r$column, F = r$F),
            aes(x = column, y = lim[2], label = sprintf("F = %.1f", F)), size = 3, vjust = 1) +
  scale_x_continuous(breaks = 1:8) +
  scale_colour_manual(values = c("#7A7A7A", "#1F4E79", "#C55A11"), name = NULL) +
  coord_cartesian(ylim = lim) +
  labs(x = "Table 10 column (more controls to the right)",
       y = "2SLS effect of 'Jews have too much influence'\non 'Israel unjust' (1-7 scale)",
       caption = "AR sets that are unbounded are not drawn. F = robust first-stage F.") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom", panel.grid.minor = element_blank())
ggsave("output/figures/ext_weakiv.pdf", p, width = 7, height = 4.5)
ggsave("output/figures/ext_weakiv.png", p, width = 7, height = 4.5, dpi = 300)

# -----------------------------------------------------------------------------
# B. Exclusion-restriction check (Table 9, third panel, all columns)
#    view ~ born 1930-45 + born before 1960 + male   (OLS, HC1 as in the paper)
#    If the instrument also moves politics, pride, religion, education or views
#    on foreigners/Islam, these are channels from birth cohort to views on Israel
#    that do not run through antisemitism (unless controlled for).
# -----------------------------------------------------------------------------
views <- c(anti_jews_influence = "Jews too much influence (first stage)",
           political_spectrum = "Political spectrum (left-right)",
           very_proud_german = "Very proud German",
           religion_none = "No religion",
           cog = "Abitur (``college'')",
           foreigners_enrich_culture = "Foreigners enrich culture",
           islam_fits_in = "Islam fits in",
           israel_unjust = "Israel unjust (reduced form)",
           israel_policy = "Israeli policy justifies antisemitism (reduced form)")
excl <- do.call(rbind, lapply(names(views), function(v) {
  dd <- s[complete.cases(s[, c(v, "cohort_1930_45", "cohort_half_1", "male")]), ]
  m  <- lm(as.formula(paste(v, "~ cohort_1930_45 + cohort_half_1 + male")), data = dd)
  V  <- vcovHC(m, type = "HC1")
  data.frame(variable = v, label = views[[v]], coef = unname(coef(m)["cohort_1930_45"]),
             se = sqrt(V["cohort_1930_45", "cohort_1930_45"]), n = nobs(m), row.names = NULL)
}))
excl$p <- 2 * pnorm(-abs(excl$coef / excl$se))
print(excl, digits = 3)
write.csv(excl, "output/ext_exclusion.csv", row.names = FALSE)

stars <- function(p) ifelse(p < .01, "^{***}", ifelse(p < .05, "^{**}", ifelse(p < .1, "^{*}", "")))
writeLines(c("\\begin{tabular}{lccc}", "\\toprule",
             "Dependent variable & Born 1930--45 & SE & $N$ \\\\", "\\midrule",
             sprintf("%s & $%s%s$ & (%s) & %s \\\\", excl$label, fmt(excl$coef), stars(excl$p),
                     fmt(excl$se), formatC(excl$n, format = "d", big.mark = ",")),
             "\\bottomrule", "\\end{tabular}"),
           "output/tables/ext_exclusion.tex")

cat("\nDone. Extension tables in output/tables/ext_*.tex, figure in output/figures/ext_weakiv.*\n")

# =============================================================================
# 00_run_all.R  -  runs the whole ALLBUS replication from raw data to tables
#
# 1. Open empirical-methods-replication.Rproj in RStudio (sets the working
#    directory to the repo root, so all relative paths work for everyone).
# 2. Put ZA5252_v1-0-0.dta (GESIS, free registration) into data/raw/.
# 3. Run this file (Source).
#
# Packages (once): install.packages(c("haven", "sandwich", "ivreg", "ggplot2"))
# =============================================================================

pkgs <- c("haven", "sandwich", "ivreg", "ggplot2")
missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Please install first: install.packages(c(\"",
                          paste(missing, collapse = "\", \""), "\"))")

source("code/01_clean_allbus.R", echo = FALSE)   # raw .dta -> data/processed/
source("code/02_tables.R",       echo = FALSE)   # replication: Tables 6, 7, 9, 10, Figure 7
source("code/03_extension.R",    echo = FALSE)   # extension: weak-IV inference, exclusion check

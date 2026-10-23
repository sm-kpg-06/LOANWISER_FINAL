# requirements.R - Package installer for LoanWiser
# LoanWiser: Personalized Loan Eligibility & Financial Risk Analysis Using R

options(repos = c(CRAN = "https://cloud.r-project.org"))

required_packages <- c(
  "shiny",
  "shinydashboard",
  "tidyverse",
  "caret",
  "randomForest",
  "xgboost",
  "pROC",
  "plotly",
  "DT",
  "janitor",
  "scales"
)

cat("====================================================\n")
cat("Checking and Installing LoanWiser Dependencies\n")
cat("====================================================\n")

installed <- rownames(installed.packages())
to_install <- setdiff(required_packages, installed)

if (length(to_install) > 0) {
  cat("Packages to install:", paste(to_install, collapse = ", "), "\n")
  install.packages(to_install, dependencies = TRUE, type = "binary")
} else {
  cat("All required packages are already installed!\n")
}

# Verify installation
installed_now <- rownames(installed.packages())
still_missing <- setdiff(required_packages, installed_now)

if (length(still_missing) == 0) {
  cat("\nSUCCESS: All packages verified and ready.\n")
} else {
  cat("\nWARNING: Some packages could not be installed directly as binary:\n")
  print(still_missing)
  cat("Attempting source install for remaining packages...\n")
  install.packages(still_missing, dependencies = TRUE)
}

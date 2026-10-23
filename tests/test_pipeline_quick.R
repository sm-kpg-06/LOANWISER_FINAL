# tests/test_pipeline_quick.R
source(file.path("R", "financial_calculations.R"))
source(file.path("R", "load_data.R"))
source(file.path("R", "feature_engineering.R"))

raw_df <- load_raw_data(file.path("data", "train.csv"), verbose = FALSE)
feat_df <- engineer_features(raw_df)
cat("Engineered dimensions:", nrow(feat_df), "x", ncol(feat_df), "\n")
cat("Sample of derived features:\n")
cols <- c("income_annum", "monthly_income", "loan_amount", "emi", "dti", "total_assets", "ltv", "cibil_score", "cibil_risk_category")
print(head(feat_df[, cols], 3))
cat("\nSummary of DTI and LTV:\n")
print(summary(feat_df[, c("dti", "ltv", "emi")]))

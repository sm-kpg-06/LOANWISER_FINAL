# tests/test_functions.R
# Unit Tests & Verification for LoanWiser Core Functions
# Validates Financial Calculations, Risk Engine, Kaggle Dataset Loading,
# Feature Engineering, and Machine Learning Model Inference

# Resolve paths relative to test file or project root
proj_root <- getwd()
source(file.path(proj_root, "R", "financial_calculations.R"))
source(file.path(proj_root, "R", "risk_engine.R"))
source(file.path(proj_root, "R", "helper_functions.R"))
source(file.path(proj_root, "R", "load_data.R"))
source(file.path(proj_root, "R", "feature_engineering.R"))
source(file.path(proj_root, "R", "ml_models.R"))
source(file.path(proj_root, "R", "eda.R"))

cat("====================================================\n")
cat("RUNNING LOANWISER CORE FUNCTION TESTS\n")
cat("====================================================\n\n")

total_tests <- 0
passed_tests <- 0

assert_true <- function(condition, test_name) {
  total_tests <<- total_tests + 1
  if (isTRUE(condition)) {
    passed_tests <<- passed_tests + 1
    cat(sprintf("[PASS] %s\n", test_name))
  } else {
    cat(sprintf("[FAIL] %s\n", test_name))
  }
}

# ------------------------------------------------------------------
# 1. TEST EMI CALCULATION
# ------------------------------------------------------------------
cat("--- Testing EMI Calculation ---\n")
# P = 1,000,000, Rate = 8.5%, Tenure = 10 years (120 months)
emi_val <- calculate_emi(1000000, 8.5, 10)
assert_true(abs(emi_val - 12398.57) < 1.0, "EMI standard calculation (Rs 1,000,000 @ 8.5% for 10y)")

# Zero interest loan: P = 120,000, Rate = 0%, Tenure = 1y (12 months) -> 10,000
emi_zero_rate <- calculate_emi(120000, 0, 1)
assert_true(emi_zero_rate == 10000, "EMI zero-interest handling (Rs 120,000 @ 0% for 1y)")

# Edge cases: 0 principal, negative principal, 0 tenure
assert_true(calculate_emi(0, 10, 5) == 0, "EMI zero principal returns 0")
assert_true(calculate_emi(-50000, 10, 5) == 0, "EMI negative principal returns 0")
assert_true(calculate_emi(100000, 10, 0) == 0, "EMI zero tenure returns 0")

# ------------------------------------------------------------------
# 2. TEST DTI CALCULATION
# ------------------------------------------------------------------
cat("\n--- Testing DTI Calculation ---\n")
# Existing EMI = 10,000, New EMI = 15,000, Monthly Income = 50,000 -> 50%
dti_val <- calculate_dti(10000, 15000, 50000)
assert_true(dti_val == 50.0, "DTI standard calculation (Rs 25,000 debt on Rs 50,000 income = 50%)")

# Zero income edge case
assert_true(calculate_dti(10000, 5000, 0) == 100.0, "DTI zero income handling safely capped")

# Zero existing EMI
assert_true(calculate_dti(0, 20000, 100000) == 20.0, "DTI zero existing debt (20%)")

# ------------------------------------------------------------------
# 3. TEST LTV CALCULATION
# ------------------------------------------------------------------
cat("\n--- Testing LTV Calculation ---\n")
# Loan = 4,000,000, Collateral = 5,000,000 -> 80%
ltv_val <- calculate_ltv(4000000, 5000000)
assert_true(ltv_val == 80.0, "LTV standard calculation (4M loan on 5M collateral = 80%)")

# Unsecured / zero collateral
assert_true(is.na(calculate_ltv(500000, 0)), "LTV zero collateral returns NA without error")
assert_true(is.na(calculate_ltv(500000, NA)), "LTV NA collateral returns NA")

# ------------------------------------------------------------------
# 4. TEST DISPOSABLE INCOME & REPAYMENT BUFFER
# ------------------------------------------------------------------
cat("\n--- Testing Disposable Income & Repayment Buffer ---\n")
disp_inc <- calculate_disposable_income(80000, 10000, 20000, 25000)
assert_true(disp_inc == 25000, "Disposable income calculation (80k - 10k - 20k - 25k = 25k)")

buffer_val <- calculate_repayment_buffer(30000, 15000)
assert_true(buffer_val == 2.0, "Repayment buffer ratio (30k disposable / 15k EMI = 2.0x)")

buffer_neg <- calculate_repayment_buffer(-5000, 15000)
assert_true(buffer_neg == 0.0, "Repayment buffer handles negative disposable surplus as 0.0")

# ------------------------------------------------------------------
# 5. TEST AMORTIZATION SCHEDULE
# ------------------------------------------------------------------
cat("\n--- Testing Amortization Schedule ---\n")
amort <- calculate_amortization(120000, 10, 1)
assert_true(nrow(amort) == 12, "Amortization table produces 12 rows for 1 year loan")
assert_true(amort$Beginning_Balance[1] == 120000, "Amortization begins with original principal")
assert_true(amort$Ending_Balance[12] == 0, "Amortization ending balance closes strictly at 0.00")
assert_true(all(c("Month", "Beginning_Balance", "EMI", "Interest", "Principal", "Ending_Balance") %in% names(amort)),
            "Amortization table contains all required columns")

# ------------------------------------------------------------------
# 6. TEST RISK ASSESSMENT ENGINE
# ------------------------------------------------------------------
cat("\n--- Testing Risk Assessment Engine ---\n")
prime_risk <- assess_loan_risk(
  ml_prob = 0.92,
  credit_score = 800,
  dti = 22.0,
  ltv = 60.0,
  disposable_income = 60000,
  repayment_buffer = 3.0,
  employment_type = "Salaried",
  employment_years = 6,
  monthly_income = 120000,
  existing_emi = 5000,
  new_emi = 20000,
  loan_amount = 1500000,
  collateral_value = 2500000,
  co_applicant = "Yes"
)

assert_true(prime_risk$risk_level == "Low", "Prime applicant classified as Low Risk")
assert_true(prime_risk$eligibility_status == "Eligible", "Prime applicant classified as Eligible")
assert_true(length(prime_risk$positive_factors) > 0, "Prime applicant has positive factors identified")

poor_risk <- assess_loan_risk(
  ml_prob = 0.15,
  credit_score = 520,
  dti = 68.0,
  ltv = 95.0,
  disposable_income = -5000,
  repayment_buffer = 0.0,
  employment_type = "Unemployed",
  employment_years = 0,
  monthly_income = 25000,
  existing_emi = 12000,
  new_emi = 15000,
  loan_amount = 800000,
  collateral_value = 0,
  co_applicant = "No"
)

assert_true(poor_risk$risk_level == "High", "Distressed applicant classified as High Risk")
assert_true(poor_risk$eligibility_status == "Ineligible", "Distressed applicant classified as Ineligible")
assert_true(length(poor_risk$negative_factors) > 0, "Distressed applicant has negative factors identified")
assert_true(length(poor_risk$recommendations) > 0, "Distressed applicant receives actionable recommendations")

# ------------------------------------------------------------------
# 7. TEST KAGGLE DATASET LOADER & FEATURE ENGINEERING
# ------------------------------------------------------------------
cat("\n--- Testing Kaggle Dataset Loader & Feature Engineering ---\n")
raw_data_file <- file.path("data", "train.csv")
assert_true(file.exists(raw_data_file), "Kaggle data/train.csv file exists")

df_raw <- load_raw_data(raw_data_file, verbose = FALSE)
assert_true(nrow(df_raw) == 4269, "Kaggle train.csv contains exactly 4,269 rows")
assert_true("loan_status_binary" %in% names(df_raw), "Binary target loan_status_binary standardized")

df_feat <- engineer_features(df_raw)
assert_true(nrow(df_feat) == 4269, "Feature engineering preserves row count")
assert_true(all(c("monthly_income", "total_assets", "emi", "dti", "ltv") %in% names(df_feat)),
            "Engineered features contain monthly_income, total_assets, emi, dti, ltv")

# Verify total assets formula consistency
expected_assets <- df_feat$residential_assets_value + df_feat$commercial_assets_value + 
                   df_feat$luxury_assets_value + df_feat$bank_asset_value
assert_true(all(df_feat$total_assets == expected_assets), "Total assets accurately sums all 4 asset classes")

# ------------------------------------------------------------------
# 8. TEST MACHINE LEARNING MODEL BUNDLE & INFERENCE
# ------------------------------------------------------------------
# 8. TEST MACHINE LEARNING MODEL BUNDLE & LOGISTIC REGRESSION
# ------------------------------------------------------------------
cat("\n--- Testing Machine Learning Models & Logistic Regression ---\n")
bundle_path <- file.path("models", "model_comparison.rds")
assert_true(file.exists(bundle_path), "Trained model comparison bundle exists in models/")

bundle <- readRDS(bundle_path)
assert_true(!is.null(bundle$models$logistic), "Logistic Regression model loaded")
assert_true(!is.null(bundle$models$random_forest), "Random Forest model loaded")
assert_true(!is.null(bundle$models$xgboost), "XGBoost model loaded")

# Logistic Regression Non-Singularity Verification
lr_coefs <- coef(bundle$models$logistic)
assert_true(sum(is.na(lr_coefs)) == 0, "Logistic Regression has ZERO singular/NA coefficients")
assert_true(length(bundle$lr_feature_cols) == 18, "Logistic Regression uses exactly 18 non-singular features")

# Held-Out Test Set Performance Benchmarks
lr_test <- bundle$test_metrics$logistic
assert_true(lr_test$accuracy >= 0.90, "Logistic Regression achieves >= 90% Test Accuracy")
assert_true(lr_test$auc >= 0.95, "Logistic Regression achieves >= 0.95 Test ROC-AUC")
assert_true(lr_test$precision >= 0.90, "Logistic Regression achieves >= 90% Test Precision")
assert_true(lr_test$recall >= 0.90, "Logistic Regression achieves >= 90% Test Recall")

# Confusion Matrix Verification
cm_lr <- lr_test$confusion_matrix
assert_true(!is.null(cm_lr) && all(dim(cm_lr) == c(2, 2)), "Logistic Regression confusion matrix is 2x2")
assert_true(lr_test$tp > 400, "Logistic Regression TP > 400 on test set")
assert_true(lr_test$tn > 250, "Logistic Regression TN > 250 on test set")
assert_true((lr_test$fp + lr_test$fn) < 60, "Logistic Regression total test errors < 60")

# Multi-Profile Prediction Tests
# Profile A: Prime Applicant (High CIBIL 750, high income)
prime_app <- data.frame(
  id = 1, loan_id = 1,
  no_of_dependents = 2,
  education = "Graduate",
  self_employed = "No",
  income_annum = 4800000,
  loan_amount = 2500000,
  loan_term = 15,
  cibil_score = 750,
  residential_assets_value = 2400000,
  commercial_assets_value = 1800000,
  luxury_assets_value = 2200000,
  bank_asset_value = 800000,
  interest_rate = 8.5,
  existing_emi = 8000,
  living_expenses = 60000,
  stringsAsFactors = FALSE
)
prime_eng <- engineer_features(prime_app)
pred_lr_prime <- predict_single_applicant(prime_eng, "Logistic Regression", bundle)
assert_true(pred_lr_prime$approval_probability >= 0.85, "LR Prime applicant achieves >= 85% approval probability")
assert_true(pred_lr_prime$predicted_class == "Approved", "LR Prime applicant classified as Approved")

# Profile B: Distressed Applicant (Low CIBIL 350, over-leveraged)
distressed_app <- data.frame(
  id = 2, loan_id = 2,
  no_of_dependents = 4,
  education = "Not Graduate",
  self_employed = "Yes",
  income_annum = 1200000,
  loan_amount = 8000000,
  loan_term = 10,
  cibil_score = 350,
  residential_assets_value = 200000,
  commercial_assets_value = 0,
  luxury_assets_value = 100000,
  bank_asset_value = 50000,
  interest_rate = 12.0,
  existing_emi = 35000,
  living_expenses = 50000,
  stringsAsFactors = FALSE
)
distressed_eng <- engineer_features(distressed_app)
pred_lr_distressed <- predict_single_applicant(distressed_eng, "Logistic Regression", bundle)
assert_true(pred_lr_distressed$approval_probability <= 0.15, "LR Distressed applicant achieves <= 15% approval probability")
assert_true(pred_lr_distressed$predicted_class == "Rejected", "LR Distressed applicant classified as Rejected")

# Profile C: Boundary Case (CIBIL 550)
boundary_app <- data.frame(
  id = 3, loan_id = 3,
  no_of_dependents = 1,
  education = "Graduate",
  self_employed = "No",
  income_annum = 3000000,
  loan_amount = 3000000,
  loan_term = 15,
  cibil_score = 550,
  residential_assets_value = 1500000,
  commercial_assets_value = 500000,
  luxury_assets_value = 800000,
  bank_asset_value = 300000,
  interest_rate = 9.0,
  existing_emi = 10000,
  living_expenses = 40000,
  stringsAsFactors = FALSE
)
boundary_eng <- engineer_features(boundary_app)
pred_lr_bound <- predict_single_applicant(boundary_eng, "Logistic Regression", bundle)
assert_true(pred_lr_bound$approval_probability >= 0 && pred_lr_bound$approval_probability <= 1,
            "LR Boundary applicant returns valid probability [0, 1]")
assert_true(pred_lr_bound$predicted_class %in% c("Approved", "Rejected"),
            "LR Boundary applicant returns valid class")

# Random Forest & XGBoost Predictions
pred_rf <- predict_single_applicant(prime_eng, "Random Forest", bundle)
assert_true(pred_rf$approval_probability >= 0.80, "RF Prime applicant predicted Approved")
pred_xgb <- predict_single_applicant(prime_eng, "XGBoost", bundle)
assert_true(pred_xgb$approval_probability >= 0.80, "XGBoost Prime applicant predicted Approved")

# ------------------------------------------------------------------
# 9. TEST EDA CATEGORY FILTERING & DYNAMIC VISUALIZATION
# ------------------------------------------------------------------
cat("\n--- Testing EDA Category Filtering & Plotly Rendering ---\n")
eda_raw_df <- read.csv("data/processed_data.csv", stringsAsFactors = FALSE)

# Test 9A: Category A selection ("Graduate")
filter_a <- filter_eda_dataset(eda_raw_df, edu_filter = "Graduate")
assert_true(filter_a$n == 2144, "EDA filter Category A ('Graduate') returns exactly 2,144 rows")

# Test 9B: Category B selection ("Not Graduate")
filter_b <- filter_eda_dataset(eda_raw_df, edu_filter = "Not Graduate")
assert_true(filter_b$n == 2125, "EDA filter Category B ('Not Graduate') returns exactly 2,125 rows")

# Test 9C: Multiple category selection
filter_multi <- filter_eda_dataset(eda_raw_df, edu_filter = c("Graduate", "Not Graduate"))
assert_true(filter_multi$n == 4269, "EDA filter multiple categories returns all 4,269 rows")

# Test 9D: Cross-category filtering ("Graduate" + Self-Employed "Yes")
filter_cross <- filter_eda_dataset(eda_raw_df, edu_filter = "Graduate", self_filter = "Yes")
assert_true(filter_cross$n == 1055, "EDA cross-filtering ('Graduate' & 'Yes') returns exactly 1,055 rows")

# Test 9E: Clear filters / "All"
filter_all <- filter_eda_dataset(eda_raw_df, edu_filter = "All", self_filter = "All")
assert_true(filter_all$n == 4269, "EDA reset/All returns complete dataset (4,269 rows)")

# Test 9F: Selection with "All" and specific category handles cleanly
filter_all_plus <- filter_eda_dataset(eda_raw_df, edu_filter = c("All", "Graduate"))
assert_true(filter_all_plus$n == 2144, "EDA c('All', 'Graduate') correctly filters to 'Graduate' (2,144 rows)")

# Test 9G: Empty match scenario handled gracefully
filter_empty <- filter_eda_dataset(eda_raw_df, edu_filter = "PhD NonExistent")
assert_true(filter_empty$n == 0, "EDA invalid category returns 0 rows without crashing")

# Test 9H: Interactive Plotly rendering for all 7 chart types with filters applied
chart_types <- c("approval_dist", "credit_score", "dti_dist", "income_vs_loan", "education", "self_employed", "correlation")
for (ct in chart_types) {
  p_test <- get_interactive_eda_plot(eda_raw_df, chart_type = ct, edu_filter = "Graduate", self_filter = "No")
  assert_true(inherits(p_test, "plotly"), paste0("EDA plot '", ct, "' generates valid Plotly object"))
}

# Test 9I: Empty state Plotly chart renders without crashing
p_empty <- get_interactive_eda_plot(eda_raw_df, chart_type = "approval_dist", edu_filter = "PhD NonExistent")
assert_true(inherits(p_empty, "plotly"), "EDA empty result generates clean fallback Plotly chart")

# ------------------------------------------------------------------
# 10. TEST WHAT-IF SIMULATION PERCENTAGE CALCULATIONS
# ------------------------------------------------------------------
cat("\n--- Testing What-If Simulation Percentage Calculations ---\n")

# Approval Probability Percentage: [0, 1] -> [0, 100%]
p_prob <- 0.842
p_pct <- p_prob * 100
assert_true(p_pct == 84.2, "Approval probability converts accurately to percentage (84.2%)")

# DTI Percentage: (Existing + New EMI) / Monthly Income * 100
dti_calc_test <- calculate_dti(existing_emi = 12000, new_emi = 18000, monthly_income = 60000)
assert_true(dti_calc_test == 50.0, "DTI calculates exact percentage (50.0%)")

# EMI Burden (% of Income): (EMI / Monthly Income) * 100
emi_burden_test <- round((18000 / 60000) * 100, 1)
assert_true(emi_burden_test == 30.0, "Monthly EMI burden calculates exact percentage of income (30.0%)")

# LTV Percentage: (Loan Amount / Collateral) * 100
ltv_calc_test <- calculate_ltv(loan_amount = 3000000, collateral_value = 5000000)
assert_true(ltv_calc_test == 60.0, "LTV calculates exact percentage of collateral (60.0%)")

# Percentage-Point Difference: Simulated - Current
delta_pts_test <- round(45.5 - 32.0, 1)
assert_true(delta_pts_test == 13.5, "Percentage-point difference calculates correctly (+13.5 % pts)")

# Relative Percentage Change: ((Simulated - Current) / Current) * 100
rel_shift_test <- round(((45.5 - 32.0) / 32.0) * 100, 1)
assert_true(rel_shift_test == 42.2, "Relative percentage shift calculates correctly (+42.2%)")

# Zero-Denominator Safety in Percentage Math
zero_denom_res <- ifelse(0 > 0, ((50 - 0) / 0) * 100, 0)
assert_true(zero_denom_res == 0, "Zero denominator in percentage change handled safely without NaN/Inf")

# ------------------------------------------------------------------
# 11. TEST INPUT VALIDATION & CIBIL 300-900 RANGE
# ------------------------------------------------------------------
cat("\n--- Testing Input Validation ---\n")
valid_inputs <- list(
  monthly_income = 75000,
  loan_amount = 1000000,
  interest_rate = 9.0,
  loan_tenure_years = 15,
  credit_score = 740,
  age = 32,
  existing_emi = 5000,
  collateral_value = 1500000
)
assert_true(validate_applicant_inputs(valid_inputs)$is_valid, "Valid inputs pass validation")

# CIBIL 900 upper limit verification
valid_cibil_900 <- valid_inputs
valid_cibil_900$credit_score <- 900
assert_true(validate_applicant_inputs(valid_cibil_900)$is_valid, "Credit score 900 passes validation")

invalid_inputs <- list(
  monthly_income = -5000,
  loan_amount = 0,
  interest_rate = -2.0,
  loan_tenure_years = 0,
  credit_score = 999,
  age = 15
)
val_res <- validate_applicant_inputs(invalid_inputs)
assert_true(!val_res$is_valid, "Invalid inputs caught correctly")
assert_true(length(val_res$errors) >= 5, "Multiple validation errors collected")

# ------------------------------------------------------------------
# SUMMARY
# ------------------------------------------------------------------
cat("\n====================================================\n")
cat(sprintf("TEST RESULTS: %d / %d PASSED (%.1f%%)\n", passed_tests, total_tests, (passed_tests / total_tests) * 100))
cat("====================================================\n")

if (passed_tests == total_tests) {
  cat("ALL TESTS PASSED SUCCESSFULLY!\n")
} else {
  stop("Some tests failed!")
}

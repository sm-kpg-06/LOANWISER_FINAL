# R/data_preprocessing.R
# Data Preprocessing & Leakage-Free Train/Test Partitioning for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis

# Ensure dependencies are loaded
if (!exists("engineer_features", mode = "function")) {
  source(file.path("R", "feature_engineering.R"))
}

#' Preprocess Kaggle Loan Data and Generate Clean Modeling Sets
#'
#' Orchestrates feature engineering, stratified 80/20 train/test splitting,
#' computes training-set statistics for inference scaling, and packages metadata.
#'
#' @param raw_df Data frame containing raw Kaggle loan data
#' @param train_ratio Numeric: Fraction for training split (default 0.80)
#' @param seed Integer: Seed for reproducible split (default 42)
#' @return List with data, train_data, test_data, feature_cols, preproc_meta
preprocess_pipeline <- function(raw_df, train_ratio = 0.80, seed = 42) {
  set.seed(seed)
  cat("Executing data preprocessing pipeline on Kaggle loan dataset...\n")
  
  # 1. Feature Engineering
  data <- engineer_features(raw_df)
  
  # 2. Define Original vs Derived Feature Columns
  original_features <- c(
    "no_of_dependents", "education", "self_employed",
    "income_annum", "loan_amount", "loan_term", "cibil_score",
    "residential_assets_value", "commercial_assets_value",
    "luxury_assets_value", "bank_asset_value"
  )
  
  derived_features <- c(
    "monthly_income", "total_assets", "immovable_assets", "liquid_assets",
    "loan_to_income", "loan_to_asset", "asset_coverage_ratio",
    "emi", "dti", "ltv", "disposable_income", "repayment_buffer",
    "annual_emi_burden", "cibil_risk_category"
  )
  
  # All ML predictive features (strictly excluding ID columns and target)
  feature_cols <- c(
    "no_of_dependents", "education", "self_employed",
    "income_annum", "loan_amount", "loan_term", "cibil_score",
    "residential_assets_value", "commercial_assets_value",
    "luxury_assets_value", "bank_asset_value",
    "monthly_income", "total_assets", "immovable_assets", "liquid_assets",
    "loan_to_income", "loan_to_asset", "asset_coverage_ratio",
    "emi", "dti", "ltv", "disposable_income", "repayment_buffer",
    "annual_emi_burden"
  )
  
  # 3. Target Variable Standardization
  if (!("loan_status_label" %in% names(data))) {
    if ("loan_status" %in% names(data)) {
      status_clean <- tolower(trimws(as.character(data$loan_status)))
      data$loan_status_binary <- ifelse(status_clean %in% c("approved", "1", "yes", "y", "true"), 1L, 0L)
    } else if ("loan_status_encoded" %in% names(data)) {
      data$loan_status_binary <- as.integer(data$loan_status_encoded)
    } else {
      stop("Target column loan_status not found in dataset!")
    }
    data$loan_status_label <- factor(
      ifelse(data$loan_status_binary == 1L, "Approved", "Rejected"),
      levels = c("Rejected", "Approved")
    )
  }
  data$target_factor <- data$loan_status_label
  data$loan_approved  <- data$loan_status_binary
  
  # 4. Stratified Train / Test Partitioning (80/20)
  n_total <- nrow(data)
  approved_idx <- which(data$loan_status_binary == 1L)
  rejected_idx <- which(data$loan_status_binary == 0L)
  
  train_approved_idx <- sample(approved_idx, size = round(length(approved_idx) * train_ratio))
  train_rejected_idx <- sample(rejected_idx, size = round(length(rejected_idx) * train_ratio))
  
  train_idx <- sort(c(train_approved_idx, train_rejected_idx))
  test_idx  <- setdiff(seq_len(n_total), train_idx)
  
  train_df <- data[train_idx, ]
  test_df  <- data[test_idx, ]
  
  # 5. Imputation parameters learned strictly on training set (No data leakage)
  numeric_features <- feature_cols[sapply(train_df[feature_cols], is.numeric)]
  categorical_features <- feature_cols[sapply(train_df[feature_cols], function(x) is.factor(x) || is.character(x))]
  
  medians_train <- sapply(train_df[numeric_features], median, na.rm = TRUE)
  means_train   <- sapply(train_df[numeric_features], mean, na.rm = TRUE)
  sds_train     <- sapply(train_df[numeric_features], sd, na.rm = TRUE)
  
  # Extract categorical levels
  cat_levels <- list()
  for (c_col in categorical_features) {
    cat_levels[[c_col]] <- levels(as.factor(train_df[[c_col]]))
  }
  
  # Handle any missing values in train and test sets using training statistics
  for (col in numeric_features) {
    med_val <- medians_train[[col]]
    train_df[[col]][is.na(train_df[[col]])] <- med_val
    test_df[[col]][is.na(test_df[[col]])]   <- med_val
    data[[col]][is.na(data[[col]])]         <- med_val
  }
  
  for (col in categorical_features) {
    mode_val <- names(sort(table(train_df[[col]]), decreasing = TRUE))[1]
    train_df[[col]][is.na(train_df[[col]])] <- mode_val
    test_df[[col]][is.na(test_df[[col]])]   <- mode_val
    data[[col]][is.na(data[[col]])]         <- mode_val
    train_df[[col]] <- factor(train_df[[col]], levels = cat_levels[[col]])
    test_df[[col]]  <- factor(test_df[[col]],  levels = cat_levels[[col]])
    data[[col]]     <- factor(data[[col]],     levels = cat_levels[[col]])
  }
  
  preproc_meta <- list(
    feature_cols = feature_cols,
    original_features = original_features,
    derived_features = derived_features,
    numeric_features = numeric_features,
    categorical_features = categorical_features,
    medians = medians_train,
    means = means_train,
    sds = sds_train,
    categorical_levels = cat_levels,
    train_obs = nrow(train_df),
    test_obs = nrow(test_df),
    approval_rate_train = mean(train_df$loan_status_binary),
    approval_rate_test = mean(test_df$loan_status_binary)
  )
  
  cat(sprintf("Training observations: %d (%.1f%% Approved)\n", 
              nrow(train_df), preproc_meta$approval_rate_train * 100))
  cat(sprintf("Testing observations:  %d (%.1f%% Approved)\n", 
              nrow(test_df), preproc_meta$approval_rate_test * 100))
  
  return(list(
    data = data,
    train_data = train_df,
    test_data = test_df,
    feature_cols = feature_cols,
    original_features = original_features,
    derived_features = derived_features,
    preproc_meta = preproc_meta
  ))
}

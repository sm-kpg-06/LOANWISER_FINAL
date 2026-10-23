# R/ml_models.R
# Machine Learning Training, Stratified 5-Fold Cross-Validation & Evaluation Pipeline
# LoanWiser: Personalized Loan Eligibility & Financial Risk Analysis Using R

library(randomForest)
library(xgboost)
library(pROC)
library(ggplot2)
library(dplyr)
library(scales)

#' Stratified K-Fold Cross-Validation Partitioning
#'
#' Divides dataset into K balanced partitions preserving target class ratios.
#'
#' @param y Factor or vector of target classes
#' @param k Integer: Number of folds (default 5)
#' @param seed Integer: Reproducibility seed (default 42)
#' @return List of length k with validation indices for each fold
create_stratified_folds <- function(y, k = 5, seed = 42) {
  set.seed(seed)
  folds <- vector("list", k)
  classes <- unique(y)
  
  for (cl in classes) {
    idx <- which(y == cl)
    shuffled <- sample(idx)
    fold_ids <- rep(1:k, length.out = length(shuffled))
    for (i in 1:k) {
      folds[[i]] <- c(folds[[i]], shuffled[fold_ids == i])
    }
  }
  return(folds)
}

#' Helper to Calculate Classification Performance Metrics
#'
#' Computes Accuracy, Precision, Recall, F1-Score, and ROC-AUC.
#'
#' @param actual Factor or vector with levels "Rejected" and "Approved"
#' @param pred_class Predicted class vector ("Approved" / "Rejected")
#' @param pred_prob Predicted probability of positive class ("Approved")
#' @return Named list with accuracy, precision, recall, f1, and auc
calculate_metrics <- function(actual, pred_class, pred_prob) {
  actual <- factor(actual, levels = c("Rejected", "Approved"))
  pred_class <- factor(pred_class, levels = c("Rejected", "Approved"))
  
  tp <- sum(pred_class == "Approved" & actual == "Approved")
  fp <- sum(pred_class == "Approved" & actual == "Rejected")
  tn <- sum(pred_class == "Rejected" & actual == "Rejected")
  fn <- sum(pred_class == "Rejected" & actual == "Approved")
  total <- tp + fp + tn + fn
  
  accuracy <- (tp + tn) / total
  precision <- ifelse((tp + fp) > 0, tp / (tp + fp), 0)
  recall <- ifelse((tp + fn) > 0, tp / (tp + fn), 0)
  f1 <- ifelse((precision + recall) > 0, 2 * (precision * recall) / (precision + recall), 0)
  
  roc_obj <- pROC::roc(response = actual, predictor = pred_prob, levels = c("Rejected", "Approved"), quiet = TRUE)
  auc_val <- as.numeric(pROC::auc(roc_obj))
  
  conf_matrix <- matrix(c(tn, fp, fn, tp), nrow = 2, byrow = TRUE,
                        dimnames = list(Actual = c("Rejected", "Approved"),
                                        Predicted = c("Rejected", "Approved")))
  
  list(
    accuracy = round(accuracy, 4),
    precision = round(precision, 4),
    recall = round(recall, 4),
    f1 = round(f1, 4),
    auc = round(auc_val, 4),
    roc_obj = roc_obj,
    confusion_matrix = conf_matrix,
    tp = tp, fp = fp, tn = tn, fn = fn
  )
}

#' Helper to Encode Data Frame to Numeric Matrix for XGBoost
#'
#' @param df Data frame of features
#' @param factor_levels List of known factor levels from training set
#' @param col_names Expected matrix column names (from training matrix)
#' @return Numeric matrix suitable for xgb.DMatrix
encode_for_xgboost <- function(df, factor_levels, col_names = NULL) {
  df_clean <- df
  # Ensure all factors adhere strictly to training levels
  for (col in names(factor_levels)) {
    if (col %in% names(df_clean)) {
      df_clean[[col]] <- factor(as.character(df_clean[[col]]), levels = factor_levels[[col]])
    }
  }
  # Create one-hot numeric matrix
  mat <- model.matrix(~ . - 1, data = df_clean)
  
  # Align columns if training col_names are provided
  if (!is.null(col_names)) {
    missing_cols <- setdiff(col_names, colnames(mat))
    if (length(missing_cols) > 0) {
      zero_mat <- matrix(0, nrow = nrow(mat), ncol = length(missing_cols))
      colnames(zero_mat) <- missing_cols
      mat <- cbind(mat, zero_mat)
    }
    mat <- mat[, col_names, drop = FALSE]
  }
  return(as.matrix(mat))
}

#' Train All 3 Classification Models with Stratified 5-Fold Cross-Validation
#'
#' @param train_df Data frame of training observations
#' @param test_df Data frame of held-out test observations
#' @param feature_cols Character vector of modeling feature names
#' @param seed Integer: Reproducibility seed (default 42)
#' @return Comprehensive bundle with models, comparison table, ROC curves, feature importance
train_and_evaluate_models <- function(train_df, test_df, feature_cols, seed = 42) {
  set.seed(seed)
  cat("\n=======================================================\n")
  cat("STARTING MACHINE LEARNING TRAINING & 5-FOLD CV PIPELINE\n")
  cat("=======================================================\n")
  
  formula_tree <- as.formula(paste("target_factor ~", paste(feature_cols, collapse = " + ")))
  
  # Dedicated non-singular feature set for Logistic Regression (GLM)
  # Excludes exact linear identities: monthly_income (12x income), immovable/liquid/total assets combinations,
  # annual_emi_burden, and disposable_income to guarantee full rank and numerical stability.
  lr_feature_cols <- c(
    "no_of_dependents", "education", "self_employed",
    "income_annum", "loan_amount", "loan_term", "cibil_score",
    "residential_assets_value", "commercial_assets_value",
    "luxury_assets_value", "bank_asset_value",
    "loan_to_income", "loan_to_asset", "asset_coverage_ratio",
    "emi", "dti", "ltv", "repayment_buffer"
  )
  formula_lr <- as.formula(paste("target_factor ~", paste(lr_feature_cols, collapse = " + ")))
  
  # Extract factor levels for XGBoost encoding
  factor_cols <- feature_cols[sapply(train_df[feature_cols], is.factor)]
  factor_levels <- list()
  for (fc in factor_cols) {
    factor_levels[[fc]] <- levels(train_df[[fc]])
  }
  
  # XGBoost matrix preparation
  train_x_mat <- encode_for_xgboost(train_df[, feature_cols], factor_levels)
  xgb_feature_names <- colnames(train_x_mat)
  test_x_mat <- encode_for_xgboost(test_df[, feature_cols], factor_levels, col_names = xgb_feature_names)
  
  train_y_num <- ifelse(train_df$target_factor == "Approved", 1, 0)
  test_y_num  <- ifelse(test_df$target_factor == "Approved", 1, 0)
  
  # 5-Fold Stratified Cross-Validation Folds
  k_folds <- 5
  cv_folds <- create_stratified_folds(train_df$target_factor, k = k_folds, seed = seed)
  
  # -----------------------------------------------------------
  # 1. MODEL 1: LOGISTIC REGRESSION (GLM)
  # -----------------------------------------------------------
  cat("\n[1/3] Training Model 1: Logistic Regression with 5-Fold CV (Non-Singular Formulation)...\n")
  cv_preds_lr <- numeric(nrow(train_df))
  
  for (f in seq_len(k_folds)) {
    val_idx <- cv_folds[[f]]
    trn_sub <- train_df[-val_idx, ]
    val_sub <- train_df[val_idx, ]
    
    fit_cv <- glm(formula_lr, data = trn_sub, family = binomial(link = "logit"))
    cv_preds_lr[val_idx] <- predict(fit_cv, newdata = val_sub, type = "response")
  }
  cv_metrics_lr <- calculate_metrics(train_df$target_factor, 
                                     ifelse(cv_preds_lr >= 0.5, "Approved", "Rejected"), 
                                     cv_preds_lr)
  cat(sprintf("   -> 5-Fold CV Accuracy: %.4f | CV ROC-AUC: %.4f\n", cv_metrics_lr$accuracy, cv_metrics_lr$auc))
  
  # Train final Logistic Regression model
  lr_model <- glm(formula_lr, data = train_df, family = binomial(link = "logit"))
  test_pred_prob_lr <- predict(lr_model, newdata = test_df, type = "response")
  test_metrics_lr <- calculate_metrics(test_df$target_factor, 
                                       ifelse(test_pred_prob_lr >= 0.5, "Approved", "Rejected"), 
                                       test_pred_prob_lr)
  cat(sprintf("   -> Test Accuracy:      %.4f | Test ROC-AUC: %.4f\n", test_metrics_lr$accuracy, test_metrics_lr$auc))
  cat("   -> Confusion Matrix (Test Set):\n")
  print(test_metrics_lr$confusion_matrix)
  
  # -----------------------------------------------------------
  # 2. MODEL 2: RANDOM FOREST
  # -----------------------------------------------------------
  cat("\n[2/3] Training Model 2: Random Forest with 5-Fold CV...\n")
  cv_preds_rf <- numeric(nrow(train_df))
  
  for (f in seq_len(k_folds)) {
    val_idx <- cv_folds[[f]]
    trn_sub <- train_df[-val_idx, ]
    val_sub <- train_df[val_idx, ]
    
    fit_cv <- randomForest(formula_tree, data = trn_sub, ntree = 80, mtry = 5)
    cv_preds_rf[val_idx] <- predict(fit_cv, newdata = val_sub, type = "prob")[, "Approved"]
  }
  cv_metrics_rf <- calculate_metrics(train_df$target_factor, 
                                     ifelse(cv_preds_rf >= 0.5, "Approved", "Rejected"), 
                                     cv_preds_rf)
  cat(sprintf("   -> 5-Fold CV Accuracy: %.4f | CV ROC-AUC: %.4f\n", cv_metrics_rf$accuracy, cv_metrics_rf$auc))
  
  # Train final Random Forest model
  rf_model <- randomForest(formula_tree, data = train_df, ntree = 120, mtry = 5, importance = TRUE)
  test_pred_prob_rf <- predict(rf_model, newdata = test_df, type = "prob")[, "Approved"]
  test_metrics_rf <- calculate_metrics(test_df$target_factor, 
                                       ifelse(test_pred_prob_rf >= 0.5, "Approved", "Rejected"), 
                                       test_pred_prob_rf)
  cat(sprintf("   -> Test Accuracy:      %.4f | Test ROC-AUC: %.4f\n", test_metrics_rf$accuracy, test_metrics_rf$auc))
  
  # Extract RF Feature Importance
  rf_imp_raw <- randomForest::importance(rf_model)
  rf_imp_df <- data.frame(
    Feature = rownames(rf_imp_raw),
    MeanDecreaseGini = rf_imp_raw[, "MeanDecreaseGini"]
  ) %>% arrange(desc(MeanDecreaseGini))
  
  # -----------------------------------------------------------
  # 3. MODEL 3: XGBOOST
  # -----------------------------------------------------------
  cat("\n[3/3] Training Model 3: XGBoost with 5-Fold CV...\n")
  cv_preds_xgb <- numeric(nrow(train_df))
  
  dtrain_full <- xgboost::xgb.DMatrix(data = train_x_mat, label = train_y_num)
  dtest_full  <- xgboost::xgb.DMatrix(data = test_x_mat, label = test_y_num)
  
  xgb_params <- list(
    booster = "gbtree",
    objective = "binary:logistic",
    eval_metric = "auc",
    eta = 0.08,
    max_depth = 5,
    subsample = 0.85,
    colsample_bytree = 0.85
  )
  
  for (f in seq_len(k_folds)) {
    val_idx <- cv_folds[[f]]
    dtrn_sub <- xgboost::xgb.DMatrix(data = train_x_mat[-val_idx, ], label = train_y_num[-val_idx])
    dval_sub <- xgboost::xgb.DMatrix(data = train_x_mat[val_idx, ], label = train_y_num[val_idx])
    
    fit_cv <- xgboost::xgb.train(params = xgb_params, data = dtrn_sub, nrounds = 80, verbose = 0)
    cv_preds_xgb[val_idx] <- predict(fit_cv, dval_sub)
  }
  cv_metrics_xgb <- calculate_metrics(train_df$target_factor, 
                                      ifelse(cv_preds_xgb >= 0.5, "Approved", "Rejected"), 
                                      cv_preds_xgb)
  cat(sprintf("   -> 5-Fold CV Accuracy: %.4f | CV ROC-AUC: %.4f\n", cv_metrics_xgb$accuracy, cv_metrics_xgb$auc))
  
  # Train final XGBoost model
  xgb_model <- xgboost::xgb.train(params = xgb_params, data = dtrain_full, nrounds = 100, verbose = 0)
  test_pred_prob_xgb <- predict(xgb_model, dtest_full)
  test_metrics_xgb <- calculate_metrics(test_df$target_factor, 
                                        ifelse(test_pred_prob_xgb >= 0.5, "Approved", "Rejected"), 
                                        test_pred_prob_xgb)
  cat(sprintf("   -> Test Accuracy:      %.4f | Test ROC-AUC: %.4f\n", test_metrics_xgb$accuracy, test_metrics_xgb$auc))
  
  # Extract XGBoost Feature Importance
  xgb_imp_raw <- xgboost::xgb.importance(model = xgb_model)
  xgb_imp_df <- data.frame(
    Feature = xgb_imp_raw$Feature,
    Gain = xgb_imp_raw$Gain
  ) %>% arrange(desc(Gain))
  
  # -----------------------------------------------------------
  # 4. MODEL EVALUATION & COMPARISON TABLE
  # -----------------------------------------------------------
  cat("\n=======================================================\n")
  cat("MODEL EVALUATION COMPARISON SUMMARY\n")
  cat("=======================================================\n")
  
  comparison_table <- data.frame(
    Model = c("Logistic Regression", "Random Forest", "XGBoost"),
    CV_Accuracy = c(cv_metrics_lr$accuracy, cv_metrics_rf$accuracy, cv_metrics_xgb$accuracy),
    CV_ROC_AUC  = c(cv_metrics_lr$auc, cv_metrics_rf$auc, cv_metrics_xgb$auc),
    Accuracy    = c(test_metrics_lr$accuracy, test_metrics_rf$accuracy, test_metrics_xgb$accuracy),
    Precision   = c(test_metrics_lr$precision, test_metrics_rf$precision, test_metrics_xgb$precision),
    Recall      = c(test_metrics_lr$recall, test_metrics_rf$recall, test_metrics_xgb$recall),
    F1          = c(test_metrics_lr$f1, test_metrics_rf$f1, test_metrics_xgb$f1),
    ROC_AUC     = c(test_metrics_lr$auc, test_metrics_rf$auc, test_metrics_xgb$auc)
  )
  print(comparison_table)
  
  # Select best model objectively based primarily on test ROC-AUC
  best_idx <- which.max(comparison_table$ROC_AUC)
  best_model_name <- comparison_table$Model[best_idx]
  cat(sprintf("\n*** BEST PERFORMING MODEL: %s (ROC-AUC = %.4f, Accuracy = %.4f) ***\n\n",
              best_model_name, comparison_table$ROC_AUC[best_idx], comparison_table$Accuracy[best_idx]))
  
  # Logistic Regression Coefficients & Odds Ratios Summary
  lr_coef_raw <- summary(lr_model)$coefficients
  lr_coef_df <- data.frame(
    Feature = rownames(lr_coef_raw),
    Estimate = round(lr_coef_raw[, "Estimate"], 6),
    Std_Error = round(lr_coef_raw[, "Std. Error"], 6),
    z_value = round(lr_coef_raw[, "z value"], 3),
    p_value = round(lr_coef_raw[, "Pr(>|z|)"], 6),
    Odds_Ratio = round(exp(lr_coef_raw[, "Estimate"]), 4),
    stringsAsFactors = FALSE
  )
  rownames(lr_coef_df) <- NULL
  
  # Bundle for serialization
  bundle <- list(
    models = list(
      logistic = lr_model,
      random_forest = rf_model,
      xgboost = xgb_model
    ),
    factor_levels = factor_levels,
    xgb_feature_names = xgb_feature_names,
    feature_cols = feature_cols,
    lr_feature_cols = lr_feature_cols,
    lr_coefficients = lr_coef_df,
    comparison_table = comparison_table,
    best_model_name = best_model_name,
    roc_curves = list(
      logistic = test_metrics_lr$roc_obj,
      random_forest = test_metrics_rf$roc_obj,
      xgboost = test_metrics_xgb$roc_obj
    ),
    test_metrics = list(
      logistic = test_metrics_lr,
      random_forest = test_metrics_rf,
      xgboost = test_metrics_xgb
    ),
    feature_importance = list(
      random_forest = rf_imp_df,
      xgboost = xgb_imp_df,
      logistic = lr_coef_df
    ),
    test_actual = test_df$target_factor,
    test_predictions = list(
      logistic = test_pred_prob_lr,
      random_forest = test_pred_prob_rf,
      xgboost = test_pred_prob_xgb
    )
  )
  
  return(bundle)
}

#' Single-Row Real-Time Model Inference Function
#'
#' Evaluates a single applicant record using the selected ML model.
#' Handles factor alignment, missing attributes, and graceful fallbacks.
#'
#' @param applicant_df 1-row data frame with engineered features
#' @param model_choice Character: "Logistic Regression", "Random Forest", or "XGBoost"
#' @param bundle Trained model bundle loaded from models/
#' @return List with approval_probability and predicted_class
predict_single_applicant <- function(applicant_df, model_choice, bundle) {
  # Unwrap if nested
  if (!is.null(bundle$models$models)) {
    bundle$models <- bundle$models$models
  }
  
  # Align categorical variables with trained factor levels
  if (!is.null(bundle$factor_levels)) {
    for (fc in names(bundle$factor_levels)) {
      if (fc %in% names(applicant_df)) {
        val <- trimws(as.character(applicant_df[[fc]]))
        # Fallback to first level if unseen
        if (!val %in% bundle$factor_levels[[fc]]) {
          val <- bundle$factor_levels[[fc]][1]
        }
        applicant_df[[fc]] <- factor(val, levels = bundle$factor_levels[[fc]])
      }
    }
  }
  
  m_choice <- tolower(gsub(" ", "_", model_choice))
  prob_approved <- 0.5
  
  if (grepl("logistic", m_choice)) {
    # Non-singular Logistic Regression prediction
    lr_cols <- if (!is.null(bundle$lr_feature_cols)) bundle$lr_feature_cols else bundle$feature_cols
    lr_cols_available <- intersect(lr_cols, names(applicant_df))
    
    prob_approved <- tryCatch({
      as.numeric(predict(bundle$models$logistic, newdata = applicant_df[, lr_cols_available, drop = FALSE], type = "response"))
    }, error = function(e) {
      warning("Logistic Regression prediction error: ", conditionMessage(e))
      0.50
    })
  } else if (grepl("forest", m_choice)) {
    prob_approved <- tryCatch({
      as.numeric(predict(bundle$models$random_forest, newdata = applicant_df, type = "prob")[, "Approved"])
    }, error = function(e) {
      warning("Random Forest prediction error: ", conditionMessage(e))
      0.50
    })
  } else if (grepl("xgboost", m_choice)) {
    prob_approved <- tryCatch({
      x_encoded <- encode_for_xgboost(applicant_df[, bundle$feature_cols], 
                                       bundle$factor_levels, 
                                       col_names = bundle$xgb_feature_names)
      dx <- xgboost::xgb.DMatrix(data = x_encoded)
      as.numeric(predict(bundle$models$xgboost, dx))
    }, error = function(e) {
      warning("XGBoost prediction error: ", conditionMessage(e))
      0.50
    })
  } else {
    best_m <- tolower(gsub(" ", "_", bundle$best_model_name))
    return(predict_single_applicant(applicant_df, best_m, bundle))
  }
  
  if (is.na(prob_approved) || is.nan(prob_approved) || is.infinite(prob_approved)) {
    prob_approved <- 0.50
  }
  
  prob_num <- max(0.01, min(0.99, as.numeric(prob_approved)))
  pred_class <- ifelse(prob_num >= 0.50, "Approved", "Rejected")
  
  list(
    approval_probability = round(prob_num, 3),
    predicted_class = pred_class,
    model_used = model_choice
  )
}

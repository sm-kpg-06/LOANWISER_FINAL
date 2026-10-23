# train_models.R
# Master Model Training & Pipeline Orchestrator for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis

# Ensure project working directory is set
cat("===============================================================\n")
cat("LOANWISER: MASTER DATA & MODEL TRAINING PIPELINE\n")
cat("===============================================================\n")

# Load required libraries
library(randomForest)
library(xgboost)
library(pROC)
library(ggplot2)
library(dplyr)
library(scales)

# Source all modular R scripts using relative project paths
source(file.path("R", "financial_calculations.R"))
source(file.path("R", "load_data.R"))
source(file.path("R", "feature_engineering.R"))
source(file.path("R", "data_preprocessing.R"))
source(file.path("R", "ml_models.R"))
source(file.path("R", "eda.R"))
source(file.path("R", "risk_engine.R"))
source(file.path("R", "helper_functions.R"))

# Create required directories
dir.create("data", showWarnings = FALSE)
dir.create("models", showWarnings = FALSE)
dir.create("reports", showWarnings = FALSE)
dir.create("plots", showWarnings = FALSE)
dir.create(file.path("plots", "eda"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path("plots", "models"), recursive = TRUE, showWarnings = FALSE)

# -------------------------------------------------------------
# STEP 1: Load Kaggle Primary Dataset
# -------------------------------------------------------------
raw_data_path <- file.path("data", "train.csv")
cat("\n[Step 1/7] Ingesting Kaggle Loan Approval Prediction dataset from data/train.csv...\n")
raw_df <- load_raw_data(raw_data_path, verbose = TRUE)
cat(sprintf("Loaded dataset: %d rows, %d columns.\n", nrow(raw_df), ncol(raw_df)))

# -------------------------------------------------------------
# STEP 2: Data Cleaning & Feature Engineering
# -------------------------------------------------------------
cat("\n[Step 2/7] Preprocessing and feature engineering...\n")
pipeline_out <- preprocess_pipeline(raw_df, train_ratio = 0.80, seed = 42)

full_processed_df <- pipeline_out$data
train_df          <- pipeline_out$train_data
test_df           <- pipeline_out$test_data
feature_cols      <- pipeline_out$feature_cols
preproc_meta      <- pipeline_out$preproc_meta

# Save processed dataset
processed_data_path <- file.path("data", "processed_data.csv")
write.csv(full_processed_df, processed_data_path, row.names = FALSE)
cat("Saved processed dataset to:", processed_data_path, "\n")

# Save preprocessing metadata
saveRDS(preproc_meta, file.path("models", "preproc_meta.rds"))
cat("Saved preprocessing metadata to models/preproc_meta.rds\n")

# -------------------------------------------------------------
# STEP 3: Generate and Save Exploratory Data Analysis Plots
# -------------------------------------------------------------
cat("\n[Step 3/7] Generating and saving static EDA plots...\n")
generate_and_save_eda_plots(full_processed_df, output_dir = file.path("plots", "eda"))

# -------------------------------------------------------------
# STEP 4: Train Machine Learning Models (LR, RF, XGBoost) & 5-Fold CV
# -------------------------------------------------------------
cat("\n[Step 4/7] Training Machine Learning Models...\n")
ml_bundle <- train_and_evaluate_models(
  train_df = train_df,
  test_df = test_df,
  feature_cols = feature_cols,
  seed = 42
)

# -------------------------------------------------------------
# STEP 5: Save Models and Comparison Table
# -------------------------------------------------------------
cat("\n[Step 5/7] Saving trained models and comparison metrics...\n")
saveRDS(ml_bundle$models$logistic,      file.path("models", "logistic_model.rds"))
saveRDS(ml_bundle$models$random_forest, file.path("models", "random_forest_model.rds"))
saveRDS(ml_bundle$models$xgboost,       file.path("models", "xgboost_model.rds"))
saveRDS(ml_bundle,                      file.path("models", "model_comparison.rds"))

# Save evaluation table CSV
comparison_table <- ml_bundle$comparison_table
write.csv(comparison_table, file.path("reports", "model_evaluation.csv"), row.names = FALSE)
cat("Saved evaluation metrics table to: reports/model_evaluation.csv\n")

# -------------------------------------------------------------
# STEP 6: Generate Model Comparison Plots
# -------------------------------------------------------------
cat("\n[Step 6/7] Generating model evaluation comparison charts...\n")

# 1. ROC Curves Overlay Plot
roc_lr  <- ml_bundle$roc_curves$logistic
roc_rf  <- ml_bundle$roc_curves$random_forest
roc_xgb <- ml_bundle$roc_curves$xgboost

roc_df_lr <- data.frame(FPR = 1 - roc_lr$specificities, TPR = roc_lr$sensitivities, Model = paste0("Logistic (AUC = ", sprintf("%.3f", ml_bundle$test_metrics$logistic$auc), ")"))
roc_df_rf <- data.frame(FPR = 1 - roc_rf$specificities, TPR = roc_rf$sensitivities, Model = paste0("Random Forest (AUC = ", sprintf("%.3f", ml_bundle$test_metrics$random_forest$auc), ")"))
roc_df_xgb <- data.frame(FPR = 1 - roc_xgb$specificities, TPR = roc_xgb$sensitivities, Model = paste0("XGBoost (AUC = ", sprintf("%.3f", ml_bundle$test_metrics$xgboost$auc), ")"))

roc_combined <- rbind(roc_df_lr, roc_df_rf, roc_df_xgb)

p_roc <- ggplot(roc_combined, aes(x = FPR, y = TPR, color = Model)) +
  geom_line(linewidth = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("#2563eb", "#10b981", "#8b5cf6")) +
  labs(title = "Receiver Operating Characteristic (ROC) Comparison",
       x = "False Positive Rate (1 - Specificity)",
       y = "True Positive Rate (Sensitivity)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5), legend.position = "bottom")

ggsave(file.path("plots", "models", "roc_comparison.png"), p_roc, width = 8, height = 6, dpi = 150)

# 2. Performance Metrics Bar Chart
metrics_long <- comparison_table %>%
  select(Model, Accuracy, Precision, Recall, F1, ROC_AUC) %>%
  tidyr::pivot_longer(cols = -Model, names_to = "Metric", values_to = "Score")

p_metrics <- ggplot(metrics_long, aes(x = Metric, y = Score, fill = Model)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_text(aes(label = sprintf("%.2f", Score)), position = position_dodge(0.8), vjust = -0.4, size = 3.2, fontface = "bold") +
  scale_fill_manual(values = c("Logistic Regression" = "#3b82f6", "Random Forest" = "#10b981", "XGBoost" = "#8b5cf6")) +
  scale_y_continuous(limits = c(0, 1.1), labels = percent) +
  labs(title = "Classification Performance Metrics Comparison", x = "Metric", y = "Score") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5), legend.position = "bottom")

ggsave(file.path("plots", "models", "model_metrics_comparison.png"), p_metrics, width = 9, height = 5, dpi = 150)

# 3. Top Feature Importance Chart
rf_top <- ml_bundle$feature_importance$random_forest %>%
  head(10) %>%
  mutate(Feature = reorder(Feature, MeanDecreaseGini))

p_imp <- ggplot(rf_top, aes(x = MeanDecreaseGini, y = Feature)) +
  geom_col(fill = "#1e3a8a", alpha = 0.85, width = 0.6) +
  geom_text(aes(label = round(MeanDecreaseGini, 1)), hjust = -0.2, size = 3.2, fontface = "bold") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(title = "Top 10 Feature Importance (Random Forest - Mean Decrease Gini)",
       x = "Mean Decrease in Gini Impurity", y = "") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(file.path("plots", "models", "feature_importance.png"), p_imp, width = 8, height = 5, dpi = 150)

# -------------------------------------------------------------
# STEP 7: Completion Summary
# -------------------------------------------------------------
cat("\n[Step 7/7] Master training workflow complete!\n")
cat("===============================================================\n")
cat(sprintf("Best Model Selected: %s (Test ROC-AUC: %.4f)\n", 
            ml_bundle$best_model_name, max(comparison_table$ROC_AUC)))
cat("All models saved to models/ directory.\n")
cat("All evaluation reports saved to reports/ directory.\n")
cat("All static plots saved to plots/ directory.\n")
cat("===============================================================\n")

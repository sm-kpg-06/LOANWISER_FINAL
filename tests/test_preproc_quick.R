# tests/test_preproc_quick.R
source(file.path("R", "financial_calculations.R"))
source(file.path("R", "load_data.R"))
source(file.path("R", "feature_engineering.R"))
source(file.path("R", "data_preprocessing.R"))

raw_df <- load_raw_data(file.path("data", "train.csv"), verbose = FALSE)
res <- preprocess_pipeline(raw_df, train_ratio = 0.80, seed = 42)
cat("Train size:", nrow(res$train_data), "Test size:", nrow(res$test_data), "\n")
cat("Features count:", length(res$feature_cols), "\n")
cat("Original features:", paste(res$original_features, collapse = ", "), "\n")
cat("Derived features:", paste(res$derived_features, collapse = ", "), "\n")

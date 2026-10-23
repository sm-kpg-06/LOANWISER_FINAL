# R/load_data.R
# Kaggle Loan Approval Dataset Loader and Validation Module
# Project: LoanWiser - Personalized Loan Eligibility & Financial Risk Analysis Using R

#' Clean column names safely using janitor if available, or robust base R fallback
#'
#' @param df Data frame to clean
#' @return Data frame with clean snake_case column names
clean_names_safe <- function(df) {
  if (requireNamespace("janitor", quietly = TRUE)) {
    res <- try(janitor::clean_names(df), silent = TRUE)
    if (!inherits(res, "try-error")) return(res)
  }
  # Base R fallback
  nms <- names(df)
  nms <- trimws(nms)
  nms <- tolower(nms)
  nms <- gsub("[^a-z0-9]+", "_", nms)
  nms <- gsub("^_|_$", "", nms)
  names(df) <- nms
  return(df)
}

#' Load and Validate Kaggle Loan Approval Dataset
#'
#' Loads the primary training dataset from data/train.csv (or specified path),
#' checks file existence, standardizes column names, cleans whitespace,
#' and reports summary statistics.
#'
#' @param filepath Relative or absolute path to train.csv (default: file.path("data", "train.csv"))
#' @param verbose Logical: whether to print diagnostics to console (default: TRUE)
#' @return A cleaned data.frame ready for feature engineering and modeling
load_raw_data <- function(filepath = file.path("data", "train.csv"), verbose = TRUE) {
  # 1. Check whether dataset file exists
  if (!file.exists(filepath)) {
    stop(sprintf(
      paste0(
        "Dataset file not found at: '%s'\n",
        "Please ensure the Kaggle Loan Approval Prediction training file is saved at data/train.csv.\n",
        "Source: https://www.kaggle.com/competitions/loan-approval-prediction-cpe-232-data-models-intl2/data"
      ),
      filepath
    ))
  }
  
  if (verbose) {
    cat("=================================================================\n")
    cat("LOANWISER DATA INGESTION: Loading Primary Kaggle Dataset\n")
    cat("Source Path:", filepath, "\n")
    cat("=================================================================\n")
  }
  
  # 2. Read raw CSV
  raw_df <- read.csv(filepath, stringsAsFactors = FALSE, check.names = FALSE)
  
  # 3. Clean column names
  cleaned_df <- clean_names_safe(raw_df)
  
  # 4. Standardize text columns (trim leading/trailing whitespaces common in Kaggle CSV)
  for (col in names(cleaned_df)) {
    if (is.character(cleaned_df[[col]])) {
      cleaned_df[[col]] <- trimws(cleaned_df[[col]])
    }
  }
  
  # Standardize target column: loan_status
  # Values are typically 'Approved' and 'Rejected' or 1 and 0
  if ("loan_status" %in% names(cleaned_df)) {
    cleaned_df$loan_status_raw <- cleaned_df$loan_status
    status_clean <- tolower(trimws(as.character(cleaned_df$loan_status)))
    cleaned_df$loan_status_binary <- ifelse(
      status_clean %in% c("approved", "1", "yes", "y", "true"), 1L, 0L
    )
    cleaned_df$loan_status_label <- factor(
      ifelse(cleaned_df$loan_status_binary == 1L, "Approved", "Rejected"),
      levels = c("Rejected", "Approved")
    )
  } else if ("loan_status_encoded" %in% names(cleaned_df)) {
    cleaned_df$loan_status_binary <- as.integer(cleaned_df$loan_status_encoded)
    cleaned_df$loan_status_label <- factor(
      ifelse(cleaned_df$loan_status_binary == 1L, "Approved", "Rejected"),
      levels = c("Rejected", "Approved")
    )
  }
  
  # Standardize ID column
  if (!("loan_id" %in% names(cleaned_df)) && "id" %in% names(cleaned_df)) {
    cleaned_df$loan_id <- cleaned_df$id
  }
  
  # 5. Diagnostic reporting
  if (verbose) {
    n_rows <- nrow(cleaned_df)
    n_cols <- ncol(cleaned_df)
    n_missing <- sum(is.na(cleaned_df))
    n_duplicates <- sum(duplicated(cleaned_df[, setdiff(names(cleaned_df), c("loan_id", "id"))]))
    
    cat(sprintf("Rows: %d | Columns: %d\n", n_rows, n_cols))
    cat(sprintf("Total Missing (NA) Values: %d\n", n_missing))
    cat(sprintf("Duplicate Rows (excluding ID): %d\n", n_duplicates))
    
    cat("\nTarget Class Distribution:\n")
    if ("loan_status_label" %in% names(cleaned_df)) {
      tab <- table(cleaned_df$loan_status_label)
      prop <- round(prop.table(tab) * 100, 2)
      for (lvl in names(tab)) {
        cat(sprintf(" - %s: %d (%.2f%%)\n", lvl, tab[[lvl]], prop[[lvl]]))
      }
    }
    
    cat("\nColumn Types & Non-NA Counts:\n")
    for (cn in names(cleaned_df)) {
      cat(sprintf(" - %-26s [%s] (Non-NA: %d/%d)\n", 
                  cn, class(cleaned_df[[cn]])[1], sum(!is.na(cleaned_df[[cn]])), n_rows))
    }
    cat("=================================================================\n\n")
  }
  
  return(cleaned_df)
}

# Standalone execution check
if (sys.nframe() == 0) {
  df <- load_raw_data()
}

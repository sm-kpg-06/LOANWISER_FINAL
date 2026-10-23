# inspect_kaggle.R
# Inspect the official Kaggle Loan Approval Prediction dataset
csv_path <- file.path("data", "train.csv")
if (!file.exists(csv_path)) {
  stop("data/train.csv does not exist!")
}

df <- read.csv(csv_path, stringsAsFactors = FALSE)
cat(sprintf("Dataset Dimensions: %d rows, %d columns\n\n", nrow(df), ncol(df)))

cat("Columns and Data Types:\n")
for (nm in names(df)) {
  vals <- trimws(as.character(df[[nm]]))
  cat(sprintf(" - %-26s | %-8s | NAs: %d | Samples: %s\n", 
              nm, class(df[[nm]]), sum(is.na(df[[nm]])), paste(head(vals, 3), collapse = ", ")))
}

cat("\nLoan Status Target Distribution:\n")
clean_status <- trimws(df$loan_status)
print(table(clean_status, useNA = "always"))

if ("loan_status_encoded" %in% names(df)) {
  cat("\nLoan Status Encoded Distribution:\n")
  print(table(df$loan_status_encoded, useNA = "always"))
}

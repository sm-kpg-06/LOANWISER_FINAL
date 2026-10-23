# R/feature_engineering.R
# Feature Engineering Engine for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis
# Maps Kaggle Original Features to Standardized Financial Metrics

# Source financial calculations if not already loaded
if (!exists("calculate_emi", mode = "function")) {
  source(file.path("R", "financial_calculations.R"))
}

#' Engineer Financial Ratios and Derived Features from Kaggle Dataset & Simulation Inputs
#'
#' Explicitly distinguishes between Original Kaggle Features and Derived Features:
#' Original Features:
#'   - income_annum, loan_amount, loan_term, cibil_score
#'   - residential_assets_value, commercial_assets_value, luxury_assets_value, bank_asset_value
#'   - education, self_employed, no_of_dependents
#'
#' Derived Features:
#'   - monthly_income: income_annum / 12
#'   - total_assets: sum of residential, commercial, luxury, and bank assets
#'   - immovable_assets: residential + commercial assets (property collateral)
#'   - liquid_assets: luxury + bank assets
#'   - loan_to_income: loan_amount / income_annum
#'   - loan_to_asset: loan_amount / total_assets
#'   - asset_coverage_ratio: total_assets / loan_amount
#'   - emi: Equated Monthly Installment computed via standard financial formula
#'   - dti: Debt-to-Income ratio (%)
#'   - ltv: Loan-to-Value ratio (%)
#'   - disposable_income: monthly_income - total_debt - living_expenses
#'   - repayment_buffer: disposable_income / emi
#'   - cibil_risk_category: credit score risk tier
#'   - annual_emi_burden: annual EMI obligations as % of annual income
#'
#' @param df Data frame containing original Kaggle columns (and optional user simulation fields)
#' @param default_interest_rate Benchmark annual interest rate in percent if not present (default: 9.5%)
#' @param default_living_expense_ratio Ratio of income for living expenses if not specified (default: 0.25)
#' @return Enriched data frame containing both original and derived financial metrics
engineer_features <- function(df, default_interest_rate = 9.5, default_living_expense_ratio = 0.25) {
  data <- as.data.frame(df)
  n <- nrow(data)
  
  # -------------------------------------------------------------
  # A. Original Kaggle Variable Extraction & Normalization
  # -------------------------------------------------------------
  inc_annum <- pmax(1, as.numeric(data$income_annum))
  loan_amt  <- pmax(1, as.numeric(data$loan_amount))
  tenure_yr <- pmax(1, as.numeric(data$loan_term))
  cibil     <- pmax(300, pmin(900, as.numeric(data$cibil_score)))
  
  res_asset  <- as.numeric(data$residential_assets_value)
  com_asset  <- as.numeric(data$commercial_assets_value)
  lux_asset  <- as.numeric(data$luxury_assets_value)
  bank_asset <- as.numeric(data$bank_asset_value)
  
  # Optional simulation inputs (from Shiny app or training defaults)
  # Interest rate: default 9.5% if not present
  if ("interest_rate" %in% names(data) && !all(is.na(data$interest_rate))) {
    int_rate <- as.numeric(data$interest_rate)
  } else {
    int_rate <- rep(default_interest_rate, n)
  }
  
  # Existing EMI: default 0 if not present (Kaggle dataset does not contain existing loans)
  if ("existing_emi" %in% names(data) && !all(is.na(data$existing_emi))) {
    exist_emi <- pmax(0, as.numeric(data$existing_emi))
  } else {
    exist_emi <- rep(0, n)
  }
  
  # Living expenses: default 25% of monthly income if not present
  monthly_inc <- round(inc_annum / 12, 2)
  if ("living_expenses" %in% names(data) && !all(is.na(data$living_expenses))) {
    living_exp <- pmax(0, as.numeric(data$living_expenses))
  } else {
    living_exp <- round(monthly_inc * default_living_expense_ratio, 2)
  }
  
  # -------------------------------------------------------------
  # B. Derived Financial Ratios & Asset Aggregations
  # -------------------------------------------------------------
  # 1. Total & Grouped Assets
  tot_assets   <- res_asset + com_asset + lux_asset + bank_asset
  immov_assets <- pmax(0, res_asset + com_asset)
  liq_assets   <- pmax(0, lux_asset + bank_asset)
  
  # 2. Equated Monthly Installment (EMI)
  emi_vec <- numeric(n)
  for (i in seq_len(n)) {
    emi_vec[i] <- calculate_emi(
      principal = loan_amt[i],
      annual_rate = int_rate[i],
      tenure_years = tenure_yr[i]
    )
  }
  
  # 3. Debt-to-Income (DTI)
  tot_debt <- exist_emi + emi_vec
  dti_vec  <- numeric(n)
  for (i in seq_len(n)) {
    dti_vec[i] <- calculate_dti(exist_emi[i], emi_vec[i], monthly_inc[i])
  }
  
  # 4. Loan-to-Value (LTV)
  # Collateral primarily based on immovable property assets (residential + commercial)
  # If 0, fallback to total assets. If total assets also 0, benchmark at 100%.
  ltv_vec <- numeric(n)
  for (i in seq_len(n)) {
    collateral <- immov_assets[i]
    if (collateral <= 0) collateral <- tot_assets[i]
    
    if (collateral > 0) {
      ltv_vec[i] <- round((loan_amt[i] / collateral) * 100, 2)
    } else {
      ltv_vec[i] <- 100.0
    }
  }
  
  # 5. Loan-to-Income (LTI) & Asset Coverage Ratios
  loan_to_income <- round(loan_amt / inc_annum, 4)
  loan_to_asset  <- round(loan_amt / pmax(1, tot_assets), 4)
  asset_coverage <- round(tot_assets / loan_amt, 4)
  
  # 6. Disposable Income & Repayment Capacity Buffer
  disp_inc <- monthly_inc - tot_debt - living_exp
  disp_inc <- round(disp_inc, 2)
  
  repayment_buf <- numeric(n)
  for (i in seq_len(n)) {
    repayment_buf[i] <- calculate_repayment_buffer(disp_inc[i], emi_vec[i])
  }
  
  # 7. Annualized EMI Burden Ratio (%)
  annual_emi_burden <- round(((emi_vec * 12) / inc_annum) * 100, 2)
  
  # 8. CIBIL Risk Tier Categorization
  cibil_category <- cut(
    cibil,
    breaks = c(299, 549, 649, 749, 901),
    labels = c("Poor", "Fair", "Good", "Excellent"),
    ordered_result = FALSE
  )
  
  # 9. Clean Categoricals
  edu_clean <- trimws(as.character(data$education))
  self_clean <- trimws(as.character(data$self_employed))
  
  # Binary numeric encodings
  edu_num  <- ifelse(tolower(edu_clean) %in% c("graduate", "1"), 1L, 0L)
  self_num <- ifelse(tolower(self_clean) %in% c("yes", "1"), 1L, 0L)
  
  # -------------------------------------------------------------
  # C. Attach Derived Features
  # -------------------------------------------------------------
  data$monthly_income       <- monthly_inc
  data$total_assets         <- tot_assets
  data$immovable_assets     <- immov_assets
  data$liquid_assets        <- liq_assets
  data$interest_rate        <- int_rate
  data$existing_emi         <- exist_emi
  data$living_expenses      <- living_exp
  data$emi                  <- round(emi_vec, 2)
  data$total_monthly_debt   <- round(tot_debt, 2)
  data$dti                  <- dti_vec
  data$ltv                  <- ltv_vec
  data$loan_to_income       <- loan_to_income
  data$loan_to_asset        <- loan_to_asset
  data$asset_coverage_ratio <- asset_coverage
  data$disposable_income    <- disp_inc
  data$repayment_buffer     <- repayment_buf
  data$annual_emi_burden    <- annual_emi_burden
  data$cibil_risk_category  <- as.factor(as.character(cibil_category))
  data$education            <- as.factor(edu_clean)
  data$self_employed        <- as.factor(self_clean)
  data$education_num        <- edu_num
  data$self_employed_num    <- self_num
  
  return(data)
}

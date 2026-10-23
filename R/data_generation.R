# R/data_generation.R
# Realistic Synthetic Loan Applicant Dataset Generator for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis

#' Generate Realistic Synthetic Loan Applicants Dataset
#'
#' @param n Integer: Number of applicant records to generate (default 6000)
#' @param seed Integer: Random seed for reproducibility (default 42)
#' @return A data.frame containing raw applicant data and engineered target
generate_loan_data <- function(n = 6000, seed = 42) {
  set.seed(seed)
  cat(sprintf("Generating %d synthetic loan applicant records (seed = %d)...\n", n, seed))
  
  # 1. Applicant Demographic Characteristics
  applicant_id <- sprintf("LW-%05d", 1:n)
  
  employment_types <- c("Salaried", "Business", "Young Professional", "Student", "Retired", "Unemployed")
  employment_probs <- c(0.46, 0.24, 0.14, 0.07, 0.06, 0.03)
  employment_type <- sample(employment_types, size = n, replace = TRUE, prob = employment_probs)
  
  gender <- sample(c("Male", "Female", "Other"), size = n, replace = TRUE, prob = c(0.58, 0.40, 0.02))
  marital_status <- sample(c("Married", "Single", "Divorced"), size = n, replace = TRUE, prob = c(0.60, 0.32, 0.08))
  education <- sample(c("High School", "Graduate", "Post Graduate", "Professional"), 
                      size = n, replace = TRUE, prob = c(0.12, 0.48, 0.28, 0.12))
  
  # Age conditioned on employment type
  age <- numeric(n)
  employment_years <- numeric(n)
  dependents <- integer(n)
  
  for (i in 1:n) {
    emp <- employment_type[i]
    if (emp == "Student") {
      age[i] <- sample(20:26, 1)
      employment_years[i] <- 0
      dependents[i] <- 0
    } else if (emp == "Young Professional") {
      age[i] <- sample(23:30, 1)
      employment_years[i] <- round(runif(1, 1, age[i] - 22), 1)
      dependents[i] <- sample(0:2, 1, prob = c(0.7, 0.2, 0.1))
    } else if (emp == "Retired") {
      age[i] <- sample(60:75, 1)
      employment_years[i] <- round(runif(1, 20, 40), 1)
      dependents[i] <- sample(0:2, 1, prob = c(0.6, 0.3, 0.1))
    } else if (emp == "Unemployed") {
      age[i] <- sample(22:58, 1)
      employment_years[i] <- 0
      dependents[i] <- sample(0:3, 1, prob = c(0.4, 0.3, 0.2, 0.1))
    } else if (emp == "Business") {
      age[i] <- sample(28:64, 1)
      employment_years[i] <- round(runif(1, 2, max(3, age[i] - 25)), 1)
      dependents[i] <- sample(0:4, 1, prob = c(0.2, 0.4, 0.3, 0.08, 0.02))
    } else { # Salaried
      age[i] <- sample(24:58, 1)
      employment_years[i] <- round(runif(1, 1, max(2, age[i] - 23)), 1)
      dependents[i] <- sample(0:4, 1, prob = c(0.25, 0.45, 0.22, 0.06, 0.02))
    }
  }
  
  # 2. Financial Baseline
  monthly_income <- numeric(n)
  for (i in 1:n) {
    emp <- employment_type[i]
    if (emp == "Student") {
      monthly_income[i] <- round(rnorm(1, mean = 15000, sd = 4000))
    } else if (emp == "Young Professional") {
      monthly_income[i] <- round(rnorm(1, mean = 48000, sd = 12000))
    } else if (emp == "Salaried") {
      monthly_income[i] <- round(exp(rnorm(1, mean = log(75000), sd = 0.55)))
    } else if (emp == "Business") {
      monthly_income[i] <- round(exp(rnorm(1, mean = log(110000), sd = 0.70)))
    } else if (emp == "Retired") {
      monthly_income[i] <- round(rnorm(1, mean = 42000, sd = 14000))
    } else { # Unemployed
      monthly_income[i] <- round(runif(1, 0, 10000))
    }
  }
  monthly_income <- pmax(5000, monthly_income)
  annual_income <- monthly_income * 12
  
  # Co-applicant presence & income
  co_applicant_prob <- ifelse(employment_type %in% c("Student", "Unemployed"), 0.75, 0.35)
  co_applicant <- ifelse(runif(n) < co_applicant_prob, "Yes", "No")
  co_applicant_income <- numeric(n)
  for (i in 1:n) {
    if (co_applicant[i] == "Yes") {
      co_applicant_income[i] <- round(exp(rnorm(1, mean = log(45000), sd = 0.5)))
    } else {
      co_applicant_income[i] <- 0
    }
  }
  
  # Credit Score (300 to 850)
  # Unemployed and distressed profiles have systematically lower credit scores
  credit_score <- numeric(n)
  for (i in 1:n) {
    emp <- employment_type[i]
    if (emp == "Unemployed") {
      base_score <- rnorm(1, mean = 560, sd = 65)
    } else if (emp == "Student") {
      base_score <- rnorm(1, mean = 650, sd = 50)
    } else {
      base_score <- rnorm(1, mean = 715, sd = 60)
    }
    credit_score[i] <- round(pmax(300, pmin(850, base_score)))
  }
  
  # Existing Debt Obligations
  existing_emi <- numeric(n)
  existing_debt <- numeric(n)
  for (i in 1:n) {
    # Existing debt burden as fraction of monthly income
    debt_burden_ratio <- rbeta(1, shape1 = 2, shape2 = 8) # typically 10-30%
    if (employment_type[i] == "Unemployed") {
      existing_emi[i] <- round(runif(1, 0, 15000))
    } else {
      existing_emi[i] <- round(monthly_income[i] * debt_burden_ratio)
    }
    # Existing debt principal
    existing_debt[i] <- round(existing_emi[i] * runif(1, 12, 48))
  }
  
  # Savings / Assets
  savings <- round(monthly_income * runif(n, 2, 18))
  
  # 3. Loan Requirements
  loan_types <- c("Home", "Personal", "Auto")
  loan_type <- sample(loan_types, size = n, replace = TRUE, prob = c(0.48, 0.32, 0.20))
  
  loan_amount <- numeric(n)
  loan_tenure_years <- numeric(n)
  interest_rate <- numeric(n)
  collateral_value <- numeric(n)
  loan_purpose <- character(n)
  down_payment <- numeric(n)
  
  purposes_home <- c("Home Purchase", "Home Construction", "Home Renovation")
  purposes_personal <- c("Education", "Debt Consolidation", "Medical", "Wedding / Travel")
  purposes_auto <- c("New Vehicle Purchase", "Commercial Vehicle", "Used Car Purchase")
  
  for (i in 1:n) {
    lt <- loan_type[i]
    tot_inc <- monthly_income[i] + co_applicant_income[i]
    
    if (lt == "Home") {
      # Loan typically 3x to 6x annual income
      loan_amount[i] <- round(pmax(500000, pmin(15000000, tot_inc * 12 * runif(1, 2.5, 5.5))))
      loan_tenure_years[i] <- sample(c(10, 15, 20, 25, 30), 1, prob = c(0.15, 0.25, 0.35, 0.15, 0.10))
      base_rate <- 8.2 + (850 - credit_score[i]) * 0.005 + runif(1, -0.3, 0.8)
      interest_rate[i] <- round(pmax(7.5, pmin(13.0, base_rate)), 2)
      collateral_value[i] <- round(loan_amount[i] * runif(1, 1.20, 1.65))
      down_payment[i] <- round(collateral_value[i] - loan_amount[i])
      loan_purpose[i] <- sample(purposes_home, 1)
      
    } else if (lt == "Auto") {
      # Vehicle loan typically 300k to 2.5M
      loan_amount[i] <- round(pmax(200000, pmin(2500000, tot_inc * runif(1, 4, 18))))
      loan_tenure_years[i] <- sample(3:7, 1)
      base_rate <- 9.0 + (850 - credit_score[i]) * 0.006 + runif(1, -0.4, 0.8)
      interest_rate[i] <- round(pmax(8.2, pmin(14.5, base_rate)), 2)
      collateral_value[i] <- round(loan_amount[i] * runif(1, 1.15, 1.40))
      down_payment[i] <- round(collateral_value[i] - loan_amount[i])
      loan_purpose[i] <- sample(purposes_auto, 1)
      
    } else { # Personal
      # Unsecured loan 50k to 1.5M
      loan_amount[i] <- round(pmax(50000, pmin(1500000, tot_inc * runif(1, 1.5, 8.0))))
      loan_tenure_years[i] <- sample(1:5, 1)
      base_rate <- 11.5 + (850 - credit_score[i]) * 0.010 + runif(1, -0.5, 1.5)
      interest_rate[i] <- round(pmax(10.0, pmin(18.0, base_rate)), 2)
      collateral_value[i] <- 0 # Unsecured personal loan
      down_payment[i] <- 0
      loan_purpose[i] <- sample(purposes_personal, 1)
    }
  }
  
  # 4. Compute Financial Metrics
  new_emi <- numeric(n)
  for (i in 1:n) {
    p <- loan_amount[i]
    r <- (interest_rate[i] / 100) / 12
    m <- loan_tenure_years[i] * 12
    new_emi[i] <- round(p * r * ((1 + r)^m) / (((1 + r)^m) - 1), 2)
  }
  
  total_monthly_debt <- existing_emi + new_emi
  total_monthly_income <- monthly_income + co_applicant_income
  dti <- round((total_monthly_debt / total_monthly_income) * 100, 2)
  
  ltv <- numeric(n)
  for (i in 1:n) {
    if (collateral_value[i] > 0) {
      ltv[i] <- round((loan_amount[i] / collateral_value[i]) * 100, 2)
    } else {
      ltv[i] <- NA_real_
    }
  }
  
  disposable_income <- round(total_monthly_income - total_monthly_debt - (total_monthly_income * 0.25), 2)
  repayment_buffer <- round(pmax(0, disposable_income) / pmax(1, new_emi), 2)
  
  # Categorical Features
  credit_risk <- cut(credit_score, 
                     breaks = c(299, 579, 669, 739, 799, 851),
                     labels = c("Poor", "Fair", "Good", "Very Good", "Exceptional"))
  
  employment_stability <- ifelse(employment_type == "Unemployed" | employment_years < 1, "Low",
                          ifelse(employment_years <= 4, "Moderate", "High"))
  
  # 5. TARGET VARIABLE: Realistic Probabilistic Logistic Generation
  # Realistic underwriting criteria:
  # - High credit score increases odds significantly
  # - High DTI decreases odds significantly (sharp penalty above 45%)
  # - Positive cash buffer increases odds
  # - Excessive loan-to-income ratio decreases odds
  # - High LTV (> 80%) decreases odds
  # - Unemployed has severe penalty
  # - Co-applicant presence gives positive bump
  
  loan_to_income <- loan_amount / (total_monthly_income * 12)
  
  log_odds <- -2.2 +
    0.016 * (credit_score - 650) -
    0.065 * (dti - 38) +
    0.65 * (repayment_buffer - 1.0) -
    0.35 * (loan_to_income - 3.0) +
    0.04 * pmin(15, employment_years) +
    ifelse(co_applicant == "Yes", 0.50, 0) +
    ifelse(employment_type == "Unemployed", -3.0, 0) +
    ifelse(employment_type == "Business", 0.15, 0) +
    ifelse(!is.na(ltv) & ltv > 85, -0.60, 0) +
    ifelse(dti > 55, -1.2, 0) +
    ifelse(credit_score < 600, -1.5, 0)
  
  # Add stochastic logistic noise
  prob_approved <- 1 / (1 + exp(-log_odds))
  
  # Bound probabilities realistically
  prob_approved <- pmax(0.02, pmin(0.98, prob_approved))
  
  # Binary approval target
  loan_approved <- ifelse(runif(n) < prob_approved, 1, 0)
  
  # Assemble final raw dataset
  df <- data.frame(
    applicant_id = applicant_id,
    age = age,
    gender = gender,
    employment_type = employment_type,
    employment_years = employment_years,
    marital_status = marital_status,
    dependents = dependents,
    education = education,
    monthly_income = monthly_income,
    annual_income = annual_income,
    existing_emi = existing_emi,
    existing_debt = existing_debt,
    credit_score = credit_score,
    savings = savings,
    collateral_value = collateral_value,
    co_applicant = co_applicant,
    co_applicant_income = co_applicant_income,
    loan_type = loan_type,
    loan_amount = loan_amount,
    interest_rate = interest_rate,
    loan_tenure_years = loan_tenure_years,
    loan_purpose = loan_purpose,
    down_payment = down_payment,
    new_emi = new_emi,
    total_monthly_debt = total_monthly_debt,
    dti = dti,
    ltv = ltv,
    disposable_income = disposable_income,
    repayment_buffer = repayment_buffer,
    credit_risk = as.character(credit_risk),
    employment_stability = employment_stability,
    loan_approved = loan_approved,
    stringsAsFactors = FALSE
  )
  
  cat(sprintf("Dataset generated successfully: %d rows, %d columns.\n", nrow(df), ncol(df)))
  cat(sprintf("Approval Rate: %.1f%% (%d approved / %d rejected)\n", 
              mean(df$loan_approved) * 100, sum(df$loan_approved == 1), sum(df$loan_approved == 0)))
  
  return(df)
}

# Standalone execution support
if (!interactive() && identical(environment(), globalenv())) {
  out_path <- file.path(getwd(), "data", "loan_data.csv")
  dataset <- generate_loan_data(6000, seed = 42)
  write.csv(dataset, out_path, row.names = FALSE)
  cat("Saved dataset to:", out_path, "\n")
}

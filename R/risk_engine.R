# R/risk_engine.R
# Comprehensive Financial Risk Assessment Engine for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis

#' Assess Comprehensive Financial Risk & Loan Eligibility
#'
#' @param ml_prob Numeric: Predicted probability of loan approval from ML model [0, 1]
#' @param credit_score Numeric: Credit score (300 to 850)
#' @param dti Numeric: Debt-to-Income ratio in percent
#' @param ltv Numeric: Loan-to-Value ratio in percent (can be NA for unsecured)
#' @param disposable_income Numeric: Net monthly disposable income
#' @param repayment_buffer Numeric: Buffer ratio of disposable income to EMI
#' @param employment_type Character: Applicant employment profile
#' @param employment_years Numeric: Years in current employment/business
#' @param monthly_income Numeric: Monthly income
#' @param existing_emi Numeric: Existing monthly EMI commitments
#' @param new_emi Numeric: Proposed new EMI
#' @param loan_amount Numeric: Loan principal
#' @param collateral_value Numeric: Collateral value
#' @param co_applicant Character: "Yes" or "No"
#' @return List containing risk_score, risk_level, eligibility_status, positive_factors, negative_factors, recommendations
assess_loan_risk <- function(ml_prob,
                             credit_score,
                             dti,
                             ltv,
                             disposable_income,
                             repayment_buffer,
                             employment_type = "Salaried",
                             employment_years = 3,
                             monthly_income = 50000,
                             existing_emi = 0,
                             new_emi = 10000,
                             loan_amount = 500000,
                             collateral_value = 0,
                             co_applicant = "No") {
  
  # Ensure clean numeric values
  ml_prob <- ifelse(is.na(ml_prob), 0.5, max(0, min(1, as.numeric(ml_prob))))
  credit_score <- ifelse(is.na(credit_score), 650, max(300, min(900, as.numeric(credit_score))))
  dti <- ifelse(is.na(dti), 50, max(0, as.numeric(dti)))
  disposable_income <- ifelse(is.na(disposable_income), 0, as.numeric(disposable_income))
  repayment_buffer <- ifelse(is.na(repayment_buffer), 1.0, max(0, as.numeric(repayment_buffer)))
  employment_years <- ifelse(is.na(employment_years), 0, max(0, as.numeric(employment_years)))
  
  # ----------------------------------------------------
  # 1. Multi-Factor Risk Score Calculation (0 to 100)
  # 0 = Minimal Risk (Ultra Safe), 100 = Maximum Risk (High Default)
  # ----------------------------------------------------
  
  # Component A: ML Model Risk (Weight: 40%)
  ml_risk_comp <- (1 - ml_prob) * 100
  
  # Component B: Credit Score Risk (Weight: 25%)
  # Range 300 to 900 (CIBIL standard): 900 -> 0 risk, 300 -> 100 risk
  credit_risk_comp <- ((900 - credit_score) / (900 - 300)) * 100
  credit_risk_comp <- max(0, min(100, credit_risk_comp))
  
  # Component C: Debt-to-Income Risk (Weight: 20%)
  # DTI: <= 20% -> 0 risk, 50% -> 60 risk, >= 70% -> 100 risk
  if (dti <= 20) {
    dti_risk_comp <- 5
  } else if (dti <= 40) {
    dti_risk_comp <- 15 + ((dti - 20) / 20) * 25 # 15 to 40
  } else if (dti <= 60) {
    dti_risk_comp <- 40 + ((dti - 40) / 20) * 35 # 40 to 75
  } else {
    dti_risk_comp <- min(100, 75 + ((dti - 60) / 20) * 25)
  }
  
  # Component D: Loan-to-Value Risk (Weight: 10%)
  if (!is.na(ltv) && ltv > 0) {
    if (ltv <= 50) {
      ltv_risk_comp <- 10
    } else if (ltv <= 80) {
      ltv_risk_comp <- 10 + ((ltv - 50) / 30) * 40 # 10 to 50
    } else {
      ltv_risk_comp <- min(100, 50 + ((ltv - 80) / 20) * 50)
    }
  } else {
    # Unsecured or collateral-free loan: moderate risk baseline
    ltv_risk_comp <- 45
  }
  
  # Component E: Repayment Buffer & Stability (Weight: 5%)
  if (repayment_buffer >= 2.0) {
    buffer_risk_comp <- 5
  } else if (repayment_buffer >= 1.0) {
    buffer_risk_comp <- 25
  } else if (repayment_buffer >= 0.5) {
    buffer_risk_comp <- 60
  } else {
    buffer_risk_comp <- 95
  }
  
  # Weighted Composite Score
  risk_score <- (0.40 * ml_risk_comp) +
                (0.25 * credit_risk_comp) +
                (0.20 * dti_risk_comp) +
                (0.10 * ltv_risk_comp) +
                (0.05 * buffer_risk_comp)
  
  # Penalties & Bonuses for Special Profiles
  if (employment_type == "Unemployed") {
    risk_score <- min(100, risk_score + 30)
  } else if (employment_type == "Retired" && dti <= 35 && credit_score >= 700) {
    risk_score <- max(5, risk_score - 5)
  } else if (employment_type == "Student" && co_applicant == "Yes") {
    risk_score <- max(5, risk_score - 8)
  }
  
  if (co_applicant == "Yes") {
    risk_score <- max(5, risk_score - 5)
  }
  
  risk_score <- round(max(1, min(99, risk_score)), 1)
  
  # ----------------------------------------------------
  # 2. Risk Level Categorization
  # ----------------------------------------------------
  if (risk_score < 35) {
    risk_level <- "Low"
  } else if (risk_score <= 65) {
    risk_level <- "Medium"
  } else {
    risk_level <- "High"
  }
  
  # ----------------------------------------------------
  # 3. Eligibility Determination
  # ----------------------------------------------------
  # Hard disqualification checks:
  if (employment_type == "Unemployed" && co_applicant != "Yes") {
    eligibility_status <- "Ineligible"
  } else if (credit_score < 550 || dti > 65 || ml_prob < 0.30 || disposable_income < 0) {
    eligibility_status <- "Ineligible"
  } else if (risk_level == "Low" && ml_prob >= 0.65 && dti <= 45 && credit_score >= 680) {
    eligibility_status <- "Eligible"
  } else if (risk_level == "Medium" && ml_prob >= 0.50 && dti <= 50 && credit_score >= 620) {
    eligibility_status <- "Needs Review"
  } else if (risk_level == "High") {
    eligibility_status <- "Ineligible"
  } else {
    eligibility_status <- "Needs Review"
  }
  
  # ----------------------------------------------------
  # 4. Explainability: Positive & Negative Factors
  # ----------------------------------------------------
  positive_factors <- character(0)
  negative_factors <- character(0)
  recommendations <- character(0)
  
  # Positive factor checks
  if (credit_score >= 750) {
    positive_factors <- c(positive_factors, paste0("Excellent credit score (", credit_score, ") reflects proven repayment reliability."))
  } else if (credit_score >= 700) {
    positive_factors <- c(positive_factors, paste0("Good credit score (", credit_score, ") meets standard banking benchmarks."))
  }
  
  if (dti <= 35) {
    positive_factors <- c(positive_factors, paste0("Healthy Debt-to-Income ratio (", round(dti, 1), "%) provides comfortable debt headroom."))
  } else if (dti <= 45) {
    positive_factors <- c(positive_factors, paste0("Manageable Debt-to-Income ratio (", round(dti, 1), "%)."))
  }
  
  if (!is.na(ltv) && ltv <= 70) {
    positive_factors <- c(positive_factors, paste0("Strong collateral backing with low LTV ratio (", round(ltv, 1), "%)."))
  }
  
  if (repayment_buffer >= 1.5) {
    positive_factors <- c(positive_factors, paste0("Robust cash flow buffer: Disposable income covers ", round(repayment_buffer, 1), "x the monthly EMI."))
  }
  
  if (employment_years >= 4) {
    positive_factors <- c(positive_factors, paste0("Demonstrated career stability with ", employment_years, " years in current profession."))
  }
  
  if (co_applicant == "Yes") {
    positive_factors <- c(positive_factors, "Co-applicant presence strengthens total household repayment capacity.")
  }
  
  if (ml_prob >= 0.75) {
    positive_factors <- c(positive_factors, paste0("Machine Learning models indicate strong approval probability (", round(ml_prob * 100, 1), "%)."))
  }
  
  # Negative factor checks
  if (credit_score < 620) {
    negative_factors <- c(negative_factors, paste0("Low credit score (", credit_score, ") signals historical repayment delays or default risk."))
  } else if (credit_score < 680) {
    negative_factors <- c(negative_factors, paste0("Moderate credit score (", credit_score, ") is below prime tier (700+)."))
  }
  
  if (dti > 50) {
    negative_factors <- c(negative_factors, paste0("High Debt-to-Income ratio (", round(dti, 1), "%) exceeds the prudent 45% ceiling."))
  }
  
  if (!is.na(ltv) && ltv > 85) {
    negative_factors <- c(negative_factors, paste0("Elevated Loan-to-Value ratio (", round(ltv, 1), "%) leaves minimal collateral buffer."))
  }
  
  if (disposable_income < 0) {
    negative_factors <- c(negative_factors, paste0("Negative monthly disposable cash flow (-Rs ", scales::comma(abs(disposable_income)), ") after debt obligations."))
  } else if (repayment_buffer < 0.8) {
    negative_factors <- c(negative_factors, paste0("Tight repayment buffer: Monthly surplus covers only ", round(repayment_buffer, 2), "x of the EMI."))
  }
  
  if (employment_type == "Unemployed") {
    negative_factors <- c(negative_factors, "No active verifiable employment or primary revenue stream.")
  } else if (employment_years < 1) {
    negative_factors <- c(negative_factors, paste0("Limited professional stability (", employment_years, " years tenure)."))
  }
  
  if (ml_prob < 0.45) {
    negative_factors <- c(negative_factors, paste0("Low predictive approval score (", round(ml_prob * 100, 1), "%) based on multi-variate ML classification."))
  }
  
  # Ensure there is at least one entry
  if (length(positive_factors) == 0) {
    positive_factors <- c("Basic demographic eligibility criteria satisfied.")
  }
  if (length(negative_factors) == 0) {
    negative_factors <- c("No significant financial vulnerability detected.")
  }
  
  # ----------------------------------------------------
  # 5. Tailored Recommendations
  # ----------------------------------------------------
  if (dti > 45) {
    recommendations <- c(recommendations, "Extend loan tenure or pay down existing EMIs to bring DTI below 40%.")
  }
  if (!is.na(ltv) && ltv > 80) {
    recommendations <- c(recommendations, "Increase initial down payment to lower the principal borrowing amount and improve LTV.")
  }
  if (credit_score < 680) {
    recommendations <- c(recommendations, "Improve credit score by settling past overdue accounts and maintaining 100% on-time payments.")
  }
  if (co_applicant != "Yes" && (dti > 40 || credit_score < 680)) {
    recommendations <- c(recommendations, "Add an earning co-applicant to pool household income and enhance creditworthiness.")
  }
  if (repayment_buffer < 1.0) {
    recommendations <- c(recommendations, "Consider a lower loan quantum to maintain a positive monthly liquidity buffer.")
  }
  if (length(recommendations) == 0) {
    recommendations <- c("Applicant demonstrates prime financial standing. Eligible for competitive interest rates and rapid processing.")
  }
  
  list(
    risk_score = risk_score,
    risk_level = risk_level,
    eligibility_status = eligibility_status,
    ml_probability = round(ml_prob, 3),
    positive_factors = positive_factors,
    negative_factors = negative_factors,
    recommendations = recommendations
  )
}

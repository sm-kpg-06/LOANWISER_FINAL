# R/financial_calculations.R
# Financial Mathematics Engine for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis

#' Calculate Equated Monthly Installment (EMI)
#'
#' @param principal Numeric: Loan principal amount (P)
#' @param annual_rate Numeric: Annual interest rate in percent (e.g., 8.5 for 8.5%)
#' @param tenure_years Numeric: Loan tenure in years (n = tenure_years * 12 months)
#' @return Numeric: Monthly EMI amount rounded to 2 decimal places
calculate_emi <- function(principal, annual_rate, tenure_years) {
  if (is.na(principal) || is.na(annual_rate) || is.na(tenure_years)) {
    return(0)
  }
  if (principal <= 0 || tenure_years <= 0) {
    return(0)
  }
  
  n <- round(as.numeric(tenure_years) * 12)
  if (n <= 0) return(0)
  
  r <- (as.numeric(annual_rate) / 100) / 12
  
  if (r == 0) {
    # Zero interest case
    return(round(principal / n, 2))
  }
  
  emi <- principal * r * ((1 + r)^n) / (((1 + r)^n) - 1)
  if (is.nan(emi) || is.infinite(emi)) {
    return(0)
  }
  return(round(emi, 2))
}

#' Calculate Debt-to-Income (DTI) Ratio
#'
#' @param existing_emi Numeric: Current monthly debt obligations
#' @param new_emi Numeric: Newly calculated monthly loan EMI
#' @param monthly_income Numeric: Total net monthly income of applicant (+ co-applicant)
#' @return Numeric: DTI ratio as a percentage rounded to 2 decimal places
calculate_dti <- function(existing_emi, new_emi, monthly_income) {
  existing_emi <- ifelse(is.na(existing_emi) || existing_emi < 0, 0, as.numeric(existing_emi))
  new_emi <- ifelse(is.na(new_emi) || new_emi < 0, 0, as.numeric(new_emi))
  monthly_income <- ifelse(is.na(monthly_income), 0, as.numeric(monthly_income))
  
  if (monthly_income <= 0) {
    if (existing_emi + new_emi > 0) return(100.0) else return(0.0)
  }
  
  dti <- ((existing_emi + new_emi) / monthly_income) * 100
  if (is.nan(dti) || is.infinite(dti)) return(100.0)
  return(round(dti, 2))
}

#' Calculate Loan-to-Value (LTV) Ratio
#'
#' @param loan_amount Numeric: Loan principal requested
#' @param collateral_value Numeric: Appraised value of asset/collateral
#' @return Numeric: LTV ratio in percent, or NA if collateral is zero/unsecured
calculate_ltv <- function(loan_amount, collateral_value) {
  loan_amount <- ifelse(is.na(loan_amount) || loan_amount < 0, 0, as.numeric(loan_amount))
  collateral_value <- ifelse(is.na(collateral_value) || collateral_value < 0, 0, as.numeric(collateral_value))
  
  if (collateral_value <= 0) {
    # Unsecured loan or zero collateral
    return(NA_real_)
  }
  
  ltv <- (loan_amount / collateral_value) * 100
  if (is.nan(ltv) || is.infinite(ltv)) return(NA_real_)
  return(round(ltv, 2))
}

#' Calculate Disposable Income
#'
#' @param monthly_income Numeric: Net monthly income
#' @param existing_emi Numeric: Existing monthly EMI commitments
#' @param new_emi Numeric: New proposed EMI
#' @param living_expenses Numeric: Estimated monthly living expenses (default 0)
#' @return Numeric: Net monthly disposable income surplus/deficit
calculate_disposable_income <- function(monthly_income, existing_emi, new_emi, living_expenses = 0) {
  monthly_income <- ifelse(is.na(monthly_income) || monthly_income < 0, 0, as.numeric(monthly_income))
  existing_emi <- ifelse(is.na(existing_emi) || existing_emi < 0, 0, as.numeric(existing_emi))
  new_emi <- ifelse(is.na(new_emi) || new_emi < 0, 0, as.numeric(new_emi))
  living_expenses <- ifelse(is.na(living_expenses) || living_expenses < 0, 0, as.numeric(living_expenses))
  
  disposable <- monthly_income - (existing_emi + new_emi + living_expenses)
  return(round(disposable, 2))
}

#' Calculate Repayment Capacity Buffer Ratio
#'
#' @param disposable_income Numeric: Net disposable monthly income
#' @param new_emi Numeric: New proposed loan EMI
#' @return Numeric: Multiple of EMI covered by disposable income (e.g. 1.5x buffer)
calculate_repayment_buffer <- function(disposable_income, new_emi) {
  disposable_income <- ifelse(is.na(disposable_income), 0, as.numeric(disposable_income))
  new_emi <- ifelse(is.na(new_emi) || new_emi < 0, 0, as.numeric(new_emi))
  
  if (new_emi <= 0) {
    return(if (disposable_income > 0) 10.0 else 0.0)
  }
  if (disposable_income <= 0) {
    return(0.0)
  }
  
  buffer <- disposable_income / new_emi
  if (is.nan(buffer) || is.infinite(buffer)) return(0.0)
  return(round(buffer, 2))
}

#' Generate Full Monthly Loan Amortization Schedule
#'
#' @param principal Numeric: Loan amount
#' @param annual_rate Numeric: Annual interest rate in percent
#' @param tenure_years Numeric: Tenure in years
#' @return Data frame with Month, Beginning_Balance, EMI, Interest, Principal, Ending_Balance
calculate_amortization <- function(principal, annual_rate, tenure_years) {
  principal <- as.numeric(principal)
  annual_rate <- as.numeric(annual_rate)
  tenure_years <- as.numeric(tenure_years)
  
  if (is.na(principal) || principal <= 0 || is.na(tenure_years) || tenure_years <= 0) {
    return(data.frame(
      Month = integer(0),
      Beginning_Balance = numeric(0),
      EMI = numeric(0),
      Interest = numeric(0),
      Principal = numeric(0),
      Ending_Balance = numeric(0)
    ))
  }
  
  n <- round(tenure_years * 12)
  r <- (annual_rate / 100) / 12
  monthly_emi <- calculate_emi(principal, annual_rate, tenure_years)
  
  months <- integer(n)
  beg_bal <- numeric(n)
  emi_col <- numeric(n)
  interest_col <- numeric(n)
  principal_col <- numeric(n)
  end_bal <- numeric(n)
  
  current_bal <- principal
  
  for (m in 1:n) {
    months[m] <- m
    beg_bal[m] <- round(current_bal, 2)
    
    if (r == 0) {
      interest <- 0
    } else {
      interest <- round(current_bal * r, 2)
    }
    
    # In last month or if balance is less than EMI payment
    if (m == n || (current_bal + interest) <= monthly_emi) {
      principal_paid <- current_bal
      emi_payment <- round(principal_paid + interest, 2)
      remaining <- 0
    } else {
      principal_paid <- round(monthly_emi - interest, 2)
      # Guard against principal paid exceeding balance
      if (principal_paid > current_bal) {
        principal_paid <- current_bal
        remaining <- 0
      } else {
        remaining <- round(current_bal - principal_paid, 2)
      }
      emi_payment <- monthly_emi
    }
    
    interest_col[m] <- interest
    principal_col[m] <- principal_paid
    emi_col[m] <- emi_payment
    end_bal[m] <- remaining
    
    current_bal <- remaining
    if (current_bal <= 0) {
      # Truncate if paid off early
      months <- months[1:m]
      beg_bal <- beg_bal[1:m]
      emi_col <- emi_col[1:m]
      interest_col <- interest_col[1:m]
      principal_col <- principal_col[1:m]
      end_bal <- end_bal[1:m]
      break
    }
  }
  
  data.frame(
    Month = months,
    Beginning_Balance = beg_bal,
    EMI = emi_col,
    Interest = interest_col,
    Principal = principal_col,
    Ending_Balance = end_bal
  )
}

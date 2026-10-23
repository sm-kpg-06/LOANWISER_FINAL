# R/helper_functions.R
# General Helper Utilities, Formats & Validation for LoanWiser

#' Format Currency in Indian / Standard Banking Style
#'
#' @param amount Numeric value
#' @param symbol Currency symbol string (default "Rs ")
#' @return Formatted character string
format_currency <- function(amount, symbol = "\u20B9 ") {
  if (length(amount) == 0) return(character(0))
  sapply(amount, function(x) {
    if (is.null(x) || is.na(x) || !is.numeric(x)) return("N/A")
    paste0(symbol, scales::comma(round(x, 0)))
  }, USE.NAMES = FALSE)
}

format_percent <- function(val, decimals = 1) {
  if (length(val) == 0) return(character(0))
  sapply(val, function(x) {
    if (is.null(x) || is.na(x) || !is.numeric(x)) return("N/A")
    paste0(round(x, decimals), "%")
  }, USE.NAMES = FALSE)
}

#' Validate Loan Applicant User Inputs
#'
#' @param inputs List of user inputs from Shiny UI
#' @return List with status (TRUE/FALSE) and error messages vector
validate_applicant_inputs <- function(inputs) {
  errors <- character(0)
  
  if (is.null(inputs$monthly_income) || is.na(inputs$monthly_income) || inputs$monthly_income <= 0) {
    errors <- c(errors, "Monthly Income must be greater than 0.")
  }
  
  if (is.null(inputs$loan_amount) || is.na(inputs$loan_amount) || inputs$loan_amount <= 0) {
    errors <- c(errors, "Loan Amount requested must be greater than 0.")
  }
  
  if (is.null(inputs$interest_rate) || is.na(inputs$interest_rate) || inputs$interest_rate < 0) {
    errors <- c(errors, "Interest Rate cannot be negative.")
  }
  
  if (is.null(inputs$loan_tenure_years) || is.na(inputs$loan_tenure_years) || inputs$loan_tenure_years <= 0) {
    errors <- c(errors, "Loan Tenure must be at least 1 year.")
  }
  
  if (is.null(inputs$credit_score) || is.na(inputs$credit_score) || inputs$credit_score < 300 || inputs$credit_score > 900) {
    errors <- c(errors, "Credit Score must be between 300 and 900.")
  }
  
  if (!is.null(inputs$age) && (inputs$age < 18 || inputs$age > 100)) {
    errors <- c(errors, "Applicant age must be between 18 and 100 years.")
  }
  
  if (!is.null(inputs$existing_emi) && inputs$existing_emi < 0) {
    errors <- c(errors, "Existing EMI cannot be negative.")
  }
  
  if (!is.null(inputs$collateral_value) && inputs$collateral_value < 0) {
    errors <- c(errors, "Collateral Value cannot be negative.")
  }
  
  list(
    is_valid = (length(errors) == 0),
    errors = errors
  )
}

#' Generate Styled HTML Badge for Risk Level
#'
#' @param risk_level Character: "Low", "Medium", or "High"
#' @return Shiny HTML tag string
risk_badge_html <- function(risk_level) {
  cls <- switch(risk_level,
    "Low" = "badge-risk-low",
    "Medium" = "badge-risk-medium",
    "High" = "badge-risk-high",
    "badge-risk-medium"
  )
  icon_name <- switch(risk_level,
    "Low" = "shield-check",
    "Medium" = "triangle-exclamation",
    "High" = "circle-xmark",
    "shield"
  )
  shiny::HTML(sprintf("<span class='status-badge %s'><i class='fa-solid fa-%s'></i> %s RISK</span>",
                      cls, icon_name, toupper(risk_level)))
}

#' Generate Styled HTML Badge for Eligibility Status
#'
#' @param status Character: "Eligible", "Needs Review", or "Ineligible"
#' @return Shiny HTML tag string
eligibility_badge_html <- function(status) {
  cls <- switch(status,
    "Eligible" = "badge-elig-eligible",
    "Needs Review" = "badge-elig-review",
    "Ineligible" = "badge-elig-ineligible",
    "badge-elig-review"
  )
  icon_name <- switch(status,
    "Eligible" = "circle-check",
    "Needs Review" = "clock",
    "Ineligible" = "ban",
    "info-circle"
  )
  shiny::HTML(sprintf("<span class='status-badge %s'><i class='fa-solid fa-%s'></i> %s</span>",
                      cls, icon_name, toupper(status)))
}

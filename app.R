# app.R
# LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R
# Primary Specification: LoanWiser Presentation & Kaggle Loan Approval Prediction Dataset
# Team: S.Karpagam (24BDS1210) & Shruti Chaturvedi (24BDS1003)

library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(ggplot2)
library(dplyr)
library(scales)
library(randomForest)
library(xgboost)
library(pROC)

# Source modules using relative project paths
source(file.path("R", "financial_calculations.R"))
source(file.path("R", "load_data.R"))
source(file.path("R", "feature_engineering.R"))
source(file.path("R", "data_preprocessing.R"))
source(file.path("R", "risk_engine.R"))
source(file.path("R", "helper_functions.R"))
source(file.path("R", "eda.R"))
source(file.path("R", "ml_models.R"))

# ---------------------------------------------------------------------------
# LOAD PERSISTED ARTIFACTS
# ---------------------------------------------------------------------------
models_bundle <- tryCatch({
  readRDS(file.path("models", "model_comparison.rds"))
}, error = function(e) {
  warning("Model bundle could not be loaded: ", conditionMessage(e))
  NULL
})

preproc_meta <- tryCatch({
  readRDS(file.path("models", "preproc_meta.rds"))
}, error = function(e) {
  NULL
})

eda_data <- tryCatch({
  read.csv(file.path("data", "processed_data.csv"), stringsAsFactors = FALSE)
}, error = function(e) {
  NULL
})

# ---------------------------------------------------------------------------
# UI DEFINITION
# ---------------------------------------------------------------------------
header <- dashboardHeader(
  title = span(tagList(icon("building-columns"), " LOANWISER")),
  titleWidth = 260
)

sidebar <- dashboardSidebar(
  width = 260,
  sidebarMenu(
    id = "sidebar_menu",
    menuItem("Executive Dashboard", tabName = "tab_dashboard", icon = icon("chart-pie")),
    menuItem("Applicant Profile", tabName = "tab_profile", icon = icon("user-shield")),
    menuItem("Loan Analysis", tabName = "tab_loan_analysis", icon = icon("calculator")),
    menuItem("Risk Assessment", tabName = "tab_risk", icon = icon("shield-halved")),
    menuItem("ML Prediction", tabName = "tab_ml", icon = icon("microchip")),
    menuItem("What-If Simulation", tabName = "tab_whatif", icon = icon("sliders")),
    menuItem("Exploratory Data (EDA)", tabName = "tab_eda", icon = icon("chart-line")),
    menuItem("Amortization Schedule", tabName = "tab_amortization", icon = icon("table-cells")),
    menuItem("Model Performance", tabName = "tab_performance", icon = icon("award")),
    menuItem("About Project", tabName = "tab_about", icon = icon("circle-info"))
  ),
  tags$div(
    style = "padding: 20px 15px; font-size: 11px; color: #64748b; border-top: 1px solid rgba(255,255,255,0.08);",
    tags$p(tags$b("Project:"), " LoanWiser v2.0"),
    tags$p(tags$b("Team:"), " S.Karpagam & Shruti"),
    tags$p(tags$b("Dataset:"), " Kaggle Loan Approval"),
    tags$p(tags$b("Status:"), tags$span(style = "color:#10b981;", " Models Loaded"))
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css")
  ),
  
  tabItems(
    # -----------------------------------------------------------------------
    # TAB 1: EXECUTIVE DASHBOARD
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_dashboard",
      fluidRow(
        column(12,
          tags$div(
            style = "margin-bottom: 20px;",
            tags$h2(style = "font-weight: 800; margin: 0; color: #0f172a;", "Executive Risk & Eligibility Dashboard"),
            tags$p(style = "color: #64748b; font-size: 14px; margin-top: 4px;",
                   "Integrated synthesis of Kaggle-trained ML classification, solvency ratios, and debt exposure analytics.")
          )
        )
      ),
      fluidRow(
        column(4,
          div(class = "kpi-card",
              div(class = "kpi-label", "ML Underwriting Decision"),
              div(class = "kpi-value", uiOutput("dash_eligibility_badge")),
              div(class = "kpi-subtext", textOutput("dash_ml_decision_subtext"))
          )
        ),
        column(4,
          div(class = "kpi-card",
              div(class = "kpi-label", "Multi-Factor Risk Level"),
              div(class = "kpi-value", uiOutput("dash_risk_badge")),
              div(class = "kpi-subtext", textOutput("dash_risk_score_text"))
          )
        ),
        column(4,
          div(class = "kpi-card",
              div(class = "kpi-label", "Monthly Debt Installment (EMI)"),
              div(class = "kpi-value", textOutput("dash_emi_val")),
              div(class = "kpi-subtext", textOutput("dash_emi_subtext"))
          )
        )
      ),
      fluidRow(
        column(3,
          div(class = "kpi-card",
              div(class = "kpi-label", "Debt-to-Income (DTI)"),
              div(class = "kpi-value", textOutput("dash_dti_val")),
              div(class = "kpi-subtext", "Prudent banking ceiling: 40%")
          )
        ),
        column(3,
          div(class = "kpi-card",
              div(class = "kpi-label", "Loan-to-Value (LTV)"),
              div(class = "kpi-value", textOutput("dash_ltv_val")),
              div(class = "kpi-subtext", "Collateral benchmark: 80%")
          )
        ),
        column(3,
          div(class = "kpi-card",
              div(class = "kpi-label", "Total Asset Valuation"),
              div(class = "kpi-value", textOutput("dash_total_assets_val")),
              div(class = "kpi-subtext", "Sum of 4 asset categories")
          )
        ),
        column(3,
          div(class = "kpi-card",
              div(class = "kpi-label", "Disposable Net Surplus"),
              div(class = "kpi-value", textOutput("dash_disposable_val")),
              div(class = "kpi-subtext", "Monthly cash buffer after debt")
          )
        )
      ),
      fluidRow(
        column(7,
          box(
            title = tagList(icon("chart-bar"), " Monthly Cashflow Inflows vs Debt Commitments"),
            width = NULL, status = "primary", solidHeader = FALSE,
            plotlyOutput("dash_waterfall_chart", height = "320px")
          )
        ),
        column(5,
          box(
            title = tagList(icon("gauge-high"), " Multi-Factor Risk Gauge (0 - 100)"),
            width = NULL, status = "primary", solidHeader = FALSE,
            plotlyOutput("dash_gauge_chart", height = "320px")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 2: APPLICANT PROFILE
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_profile",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Personal & Financial Applicant Profiling"),
          tags$p(style = "color: #64748b;", "Enter applicant details based on Kaggle dataset attributes and interactive simulation fields.")
        )
      ),
      fluidRow(
        column(4,
          box(
            title = tagList(icon("id-card"), " Demographics & Profile (Kaggle)"),
            width = NULL, status = "primary",
            selectInput("app_education", "Education Qualification (Kaggle):",
                        choices = c("Graduate", "Not Graduate"), selected = "Graduate"),
            selectInput("app_self_employed", "Employment Status (Kaggle):",
                        choices = c("No" = "No", "Yes (Self-Employed)" = "Yes"), selected = "No"),
            numericInput("app_dependents", "Number of Dependents (Kaggle):", value = 2, min = 0, max = 5, step = 1),
            numericInput("app_age", "Applicant Age (Years) [Simulation]:", value = 32, min = 18, max = 80),
            selectInput("app_gender", "Gender [Simulation]:", choices = c("Male", "Female"), selected = "Male"),
            numericInput("app_employment_years", "Professional Experience (Years) [Simulation]:", value = 5, min = 0, max = 40)
          )
        ),
        column(4,
          box(
            title = tagList(icon("wallet"), " Income & Assets Portfolio (Kaggle)"),
            width = NULL, status = "primary",
            numericInput("app_income_annum", "Annual Income (Rs) [Kaggle]:", value = 4800000, min = 100000, step = 100000),
            uiOutput("app_monthly_income_ui"),
            sliderInput("app_cibil_score", "CIBIL Credit Score (300-900) [Kaggle]:",
                        min = 300, max = 900, value = 750, step = 5),
            numericInput("app_residential_assets", "Residential Assets Value (Rs) [Kaggle]:", value = 2400000, min = 0, step = 100000),
            numericInput("app_commercial_assets", "Commercial Assets Value (Rs) [Kaggle]:", value = 1800000, min = 0, step = 100000),
            numericInput("app_luxury_assets", "Luxury Assets Value (Rs) [Kaggle]:", value = 2200000, min = 0, step = 100000),
            numericInput("app_bank_assets", "Bank Deposits / Liquid Assets (Rs) [Kaggle]:", value = 800000, min = 0, step = 100000),
            uiOutput("app_total_assets_ui")
          )
        ),
        column(4,
          box(
            title = tagList(icon("scale-unbalanced"), " Financial Simulation Inputs"),
            width = NULL, status = "primary",
            tags$p(style = "font-size: 12px; color: #64748b; margin-bottom: 12px;",
                   icon("circle-info"), " These simulation parameters augment the Kaggle baseline for real-time financial assessment:"),
            numericInput("app_existing_emi", "Existing Monthly EMIs (Rs) [Simulation]:", value = 8000, min = 0, step = 1000),
            numericInput("app_living_expenses", "Estimated Monthly Living Expenses (Rs) [Simulation]:", value = 60000, min = 0, step = 5000),
            selectInput("app_co_applicant", "Co-Applicant Available? [Simulation]:", choices = c("No", "Yes"), selected = "No"),
            div(style = "margin-top: 25px;",
                actionButton("btn_apply_profile", "Analyze Applicant Profile",
                             icon = icon("bolt"), class = "btn-primary btn-block")
            )
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 3: LOAN ANALYSIS
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_loan_analysis",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Loan Parameter Specifications & Debt Solvency"),
          tags$p(style = "color: #64748b;", "Compute exact monthly EMI, interest amortization burden, and debt solvency ratios.")
        )
      ),
      fluidRow(
        column(5,
          box(
            title = tagList(icon("file-invoice-dollar"), " Loan Parameters"),
            width = NULL, status = "primary",
            numericInput("loan_amount", "Requested Loan Amount (Rs) [Kaggle]:", value = 2500000, min = 50000, step = 100000),
            numericInput("loan_tenure_years", "Loan Tenure (Years) [Kaggle]:", value = 15, min = 1, max = 30, step = 1),
            numericInput("interest_rate", "Benchmark Annual Interest Rate (% p.a.) [Simulation]:", value = 8.5, min = 1.0, max = 25.0, step = 0.25),
            selectInput("loan_purpose", "Loan Category / Purpose [Simulation]:",
                        choices = c("Home Purchase", "Commercial Property", "Business Expansion", "Personal Loan", "Vehicle Purchase", "Education"),
                        selected = "Home Purchase"),
            numericInput("down_payment", "Borrower Down Payment (Rs) [Simulation]:", value = 500000, min = 0, step = 50000),
            actionButton("btn_recalc_loan", "Update Loan Calculations", icon = icon("arrows-rotate"), class = "btn-success btn-block")
          )
        ),
        column(7,
          fluidRow(
            column(6,
              div(class = "metric-callout",
                  div(class = "metric-callout-num", textOutput("loan_emi_calc")),
                  div(class = "metric-callout-title", "Monthly EMI Payment")
              )
            ),
            column(6,
              div(class = "metric-callout",
                  div(class = "metric-callout-num", textOutput("loan_total_interest_calc")),
                  div(class = "metric-callout-title", "Total Cumulative Interest")
              )
            )
          ),
          fluidRow(
            column(6,
              div(class = "metric-callout",
                  div(class = "metric-callout-num", textOutput("loan_total_repayment_calc")),
                  div(class = "metric-callout-title", "Total Payment (Principal + Interest)")
              )
            ),
            column(6,
              div(class = "metric-callout",
                  div(class = "metric-callout-num", textOutput("loan_buffer_calc")),
                  div(class = "metric-callout-title", "Repayment Capacity Buffer")
              )
            )
          ),
          box(
            title = tagList(icon("chart-pie"), " Principal vs Interest Repayment Split"),
            width = NULL, status = "info",
            plotlyOutput("loan_donut_breakdown", height = "220px")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 4: RISK ASSESSMENT ENGINE
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_risk",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Multi-Factor Financial Risk Assessment Engine"),
          tags$p(style = "color: #64748b;", "Synthesizes Machine Learning prediction, credit score, DTI, LTV, and cashflow buffers.")
        )
      ),
      fluidRow(
        column(4,
          box(
            title = tagList(icon("award"), " Risk Decision Summary"),
            width = NULL, status = "primary",
            tags$div(
              style = "text-align: center; padding: 15px 0;",
              tags$h4(style = "color: #64748b; font-size: 13px; text-transform: uppercase; margin-bottom: 5px;", "Final Underwriting Decision"),
              uiOutput("risk_page_eligibility_badge"),
              tags$h4(style = "color: #64748b; font-size: 13px; text-transform: uppercase; margin-top: 20px; margin-bottom: 5px;", "Risk Categorization"),
              uiOutput("risk_page_risk_badge"),
              tags$h2(style = "font-weight: 800; color: #0f172a; margin-top: 15px;", textOutput("risk_page_score_val")),
              tags$p(style = "color: #64748b; font-size: 12px;", "Composite Risk Index (0 = Minimal Risk, 100 = Critical Risk)")
            )
          )
        ),
        column(8,
          box(
            title = tagList(icon("chart-bar"), " Risk Contribution Breakdown by Component"),
            width = NULL, status = "primary",
            plotlyOutput("risk_factors_bar", height = "240px")
          )
        )
      ),
      fluidRow(
        column(6,
          box(
            title = tagList(icon("circle-check"), " Positive Credit & Financial Strengths"),
            width = NULL, status = "success",
            uiOutput("risk_positive_factors_list")
          )
        ),
        column(6,
          box(
            title = tagList(icon("triangle-exclamation"), " Financial Vulnerabilities & Risk Alerts"),
            width = NULL, status = "danger",
            uiOutput("risk_negative_factors_list")
          )
        )
      ),
      fluidRow(
        column(12,
          box(
            title = tagList(icon("lightbulb"), " Actionable Advisory & Improvement Recommendations"),
            width = NULL, status = "info",
            uiOutput("risk_recommendations_list")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 5: ML PREDICTION
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_ml",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Machine Learning Model Inference & Multi-Model Benchmarking"),
          tags$p(style = "color: #64748b;", "Compare real-time predictions across Logistic Regression, Random Forest, and XGBoost.")
        )
      ),
      fluidRow(
        column(4,
          box(
            title = tagList(icon("robot"), " Real-Time Model Selector"),
            width = NULL, status = "primary",
            selectInput("ml_model_selector", "Select Active Prediction Model:",
                        choices = c("Random Forest", "XGBoost", "Logistic Regression"),
                        selected = "Random Forest"),
            tags$div(
              style = "background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 15px; margin-top: 15px;",
              tags$p(tags$b("Selected Model: "), textOutput("ml_active_model_name", inline = TRUE)),
              tags$p(tags$b("Approval Probability: "), textOutput("ml_prob_output", inline = TRUE)),
              tags$p(tags$b("Predicted Class: "), textOutput("ml_class_output", inline = TRUE))
            ),
            div(style = "margin-top: 20px;",
                actionButton("btn_predict_now", "Rerun ML Inference", icon = icon("play"), class = "btn-primary btn-block")
            )
          ),
          box(
            title = tagList(icon("table-cells"), " Selected Model Confusion Matrix (854 Test Obs)"),
            width = NULL, status = "info",
            uiOutput("ml_confusion_matrix_ui")
          )
        ),
        column(8,
          box(
            title = tagList(icon("table-list"), " Real Model Evaluation Metrics (Held-Out Test Set: 854 Observations)"),
            width = NULL, status = "primary",
            DTOutput("ml_comparison_dt")
          ),
          box(
            title = tagList(icon("chart-line"), " ROC Curves Comparison (pROC)"),
            width = NULL, status = "primary",
            plotlyOutput("ml_roc_plotly", height = "320px")
          )
        )
      ),
      fluidRow(
        column(12,
          box(
            title = tagList(icon("trophy"), " Best Model Selection Criteria & Empirical Performance Summary"),
            width = NULL, status = "primary",
            uiOutput("ml_best_model_summary_ui")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 6: WHAT-IF ANALYSIS (SIMULATION)
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_whatif",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Interactive What-If Scenario Simulation & Stress Testing"),
          tags$p(style = "color: #64748b;", "Alter loan amount, tenure, interest rate, and income to observe instantaneous shifts in eligibility and risk.")
        )
      ),
      fluidRow(
        column(4,
          box(
            title = tagList(icon("sliders"), " Simulation Controls"),
            width = NULL, status = "primary",
            sliderInput("sim_loan_amount", "Simulated Loan Amount (Rs):",
                        min = 100000, max = 15000000, value = 2500000, step = 100000, pre = "Rs "),
            sliderInput("sim_tenure", "Simulated Loan Tenure (Years):",
                        min = 1, max = 30, value = 15, step = 1),
            sliderInput("sim_interest_rate", "Simulated Interest Rate (% p.a.):",
                        min = 5.0, max = 20.0, value = 8.5, step = 0.25, post = "%"),
            sliderInput("sim_income_annum", "Simulated Annual Income (Rs):",
                        min = 500000, max = 15000000, value = 4800000, step = 200000, pre = "Rs "),
            sliderInput("sim_cibil_score", "Simulated CIBIL Score:",
                        min = 300, max = 900, value = 750, step = 10),
            sliderInput("sim_existing_emi", "Simulated Existing Monthly Debt (Rs):",
                        min = 0, max = 100000, value = 8000, step = 2000, pre = "Rs "),
            actionButton("btn_reset_sim", "Reset to Current Baseline", icon = icon("rotate-left"), class = "btn-default btn-block")
          )
        ),
        column(8,
          box(
            title = tagList(icon("scale-balanced"), " Scenario Comparison: Current vs Simulated"),
            width = NULL, status = "primary",
            div(class = "comparison-container",
                div(class = "comparison-box current",
                    tags$h4(style = "font-weight: 700; color: #1e3a8a;", icon("calendar-day"), " CURRENT BASELINE"),
                    tags$hr(style = "margin: 8px 0;"),
                    uiOutput("sim_current_metrics_ui")
                ),
                div(class = "comparison-box simulated",
                    tags$h4(style = "font-weight: 700; color: #059669;", icon("wand-magic-sparkles"), " SIMULATED SCENARIO"),
                    tags$hr(style = "margin: 8px 0;"),
                    uiOutput("sim_simulated_metrics_ui")
                )
            ),
            tags$div(style = "margin-top: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;",
                     tags$h4(style = "font-weight: 700; color: #0f172a; margin: 0;",
                             icon("chart-line"), " Interactive Simulation Analytics"),
                     tags$div(style = "width: 340px;",
                              selectInput("sim_view_mode", label = NULL,
                                          choices = c(
                                            "Tenure & Affordability Sensitivity Curve" = "curve",
                                            "Monthly Budget & Cash Flow Stress Test" = "budget",
                                            "Multi-Factor Solvency & Risk Radar" = "radar",
                                            "Core Solvency Metrics Comparison (% Scale)" = "metrics"
                                          ),
                                          selected = "curve"))
            ),
            uiOutput("sim_insight_banner_ui"),
            plotlyOutput("sim_comparison_bar", height = "440px")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 7: EXPLORATORY DATA ANALYSIS (EDA)
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_eda",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Exploratory Data Analysis (EDA) Interactive Viewer"),
          tags$p(style = "color: #64748b;", "Analyze historical patterns, approval frequencies, and correlations from the Kaggle dataset.")
        )
      ),
      fluidRow(
        column(4,
          box(
            title = tagList(icon("filter"), " EDA Controls & Filters"),
            width = NULL, status = "primary",
            selectInput("eda_chart_select", "Select Analysis Visualization:",
                        choices = c("Overall Loan Approval Ratio" = "approval_dist",
                                    "CIBIL Credit Score Distribution" = "credit_score",
                                    "Debt-to-Income (DTI) Density" = "dti_dist",
                                    "Annual Income vs Loan Amount" = "income_vs_loan",
                                    "Applications by Education Level" = "education",
                                    "Applications by Self-Employed Status" = "self_employed",
                                    "Correlation Heatmap" = "correlation")),
            selectizeInput("eda_edu_filter", "Filter by Education Level:",
                           choices = c("All", "Graduate", "Not Graduate"),
                           selected = "All", multiple = TRUE,
                           options = list(placeholder = "Select education...", plugins = list("remove_button"))),
            selectizeInput("eda_self_filter", "Filter by Self-Employed:",
                           choices = c("All", "Yes", "No"),
                           selected = "All", multiple = TRUE,
                           options = list(placeholder = "Select employment...", plugins = list("remove_button"))),
            uiOutput("eda_filter_status_ui"),
            tags$div(style = "margin-top: 15px;",
                     actionButton("btn_reset_eda", "Reset Category Filters", icon = icon("rotate-left"), class = "btn-default btn-block"))
          )
        ),
        column(8,
          box(
            title = tagList(icon("chart-area"), " Interactive Visual Exploration (Plotly)"),
            width = NULL, status = "primary",
            plotlyOutput("eda_interactive_plot", height = "460px")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 8: AMORTIZATION SCHEDULE
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_amortization",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Monthly Amortization Schedule & Principal Paydown"),
          tags$p(style = "color: #64748b;", "Detailed month-by-month repayment breakdown with balance trajectories and CSV export.")
        )
      ),
      fluidRow(
        column(12,
          box(
            title = tagList(icon("chart-line"), " Loan Balance Paydown Trajectory Over Time"),
            width = NULL, status = "primary",
            plotlyOutput("amort_balance_chart", height = "280px")
          )
        )
      ),
      fluidRow(
        column(12,
          box(
            title = tagList(icon("table"), " Month-by-Month Amortization Ledger"),
            width = NULL, status = "primary",
            div(style = "margin-bottom: 15px;",
                downloadButton("download_amort_csv", "Export Complete Schedule (CSV)", class = "btn-default btn-sm")
            ),
            DTOutput("amortization_dt")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 9: MODEL PERFORMANCE
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_performance",
      fluidRow(
        column(12,
          tags$h3(style = "font-weight: 700; color: #0f172a;", "Machine Learning Model Evaluation & Benchmark Metrics"),
          tags$p(style = "color: #64748b;", "Rigorous comparative benchmarking across Logistic Regression, Random Forest, and XGBoost.")
        )
      ),
      fluidRow(
        column(6,
          box(
            title = tagList(icon("chart-column"), " Performance Comparison (Accuracy, Precision, Recall, F1, AUC)"),
            width = NULL, status = "primary",
            plotlyOutput("perf_metrics_barplot", height = "320px")
          )
        ),
        column(6,
          box(
            title = tagList(icon("ranking-star"), " Top Predictor Importance (Random Forest - Gini)"),
            width = NULL, status = "primary",
            plotlyOutput("perf_importance_plotly", height = "320px")
          )
        )
      ),
      fluidRow(
        column(12,
          box(
            title = tagList(icon("table"), " Stratified 5-Fold Cross-Validation & Test Evaluation Matrix"),
            width = NULL, status = "primary",
            DTOutput("perf_full_table_dt")
          )
        )
      )
    ),
    
    # -----------------------------------------------------------------------
    # TAB 10: ABOUT PROJECT
    # -----------------------------------------------------------------------
    tabItem(
      tabName = "tab_about",
      fluidRow(
        column(12,
          box(
            title = tagList(icon("circle-info"), " About Project LoanWiser"),
            width = NULL, status = "primary",
            tags$div(
              style = "padding: 10px 20px; font-size: 14.5px; line-height: 1.7;",
              tags$h3(style = "color: #1e3a8a; font-weight: 800; margin-top: 0;", "LOANWISER"),
              tags$h4(style = "color: #475569; font-weight: 600;", "Personalized Loan Eligibility & Financial Risk Analysis Using R"),
              tags$hr(),
              tags$h4(style = "font-weight: 700; color: #0f172a;", "Project Authors:"),
              tags$ul(
                tags$li(tags$b("S.Karpagam"), " (Reg No: 24BDS1210) — Machine Learning & Pipeline Architecture"),
                tags$li(tags$b("Shruti Chaturvedi"), " (Reg No: 24BDS1003) — Financial Mathematics & R Shiny Dashboard")
              ),
              tags$h4(style = "font-weight: 700; color: #0f172a; margin-top: 25px;", "Primary Dataset Citation & Schema:"),
              tags$p("The machine learning pipeline is trained on the official Kaggle dataset:",
                     tags$a(href = "https://www.kaggle.com/competitions/loan-approval-prediction-cpe-232-data-models-intl2/data",
                            target = "_blank", "Loan Approval Prediction - CPE 232 Data Models (INTL)"),
                     " (4,269 applicants, binary target: Approved vs Rejected)."),
              tags$h4(style = "font-weight: 700; color: #0f172a; margin-top: 25px;", "Feature Architecture & Adaptation:"),
              tags$table(
                class = "table table-bordered table-striped",
                style = "margin-top: 10px;",
                tags$thead(
                  tags$tr(
                    tags$th("Category"),
                    tags$th("Variables"),
                    tags$th("Role in System")
                  )
                ),
                tags$tbody(
                  tags$tr(
                    tags$td(tags$b("Original Kaggle Features")),
                    tags$td("income_annum, loan_amount, loan_term, cibil_score, residential_assets_value, commercial_assets_value, luxury_assets_value, bank_asset_value, education, self_employed, no_of_dependents"),
                    tags$td("Baseline ground truth used directly for ML model training and validation.")
                  ),
                  tags$tr(
                    tags$td(tags$b("Derived Features")),
                    tags$td("monthly_income, total_assets, immovable_assets, liquid_assets, loan_to_income, loan_to_asset, asset_coverage_ratio, emi, dti, ltv, disposable_income, repayment_buffer, annual_emi_burden, cibil_risk_category"),
                    tags$td("Mathematically engineered financial ratios that enrich model signals and solvency assessment.")
                  ),
                  tags$tr(
                    tags$td(tags$b("Simulation Inputs")),
                    tags$td("interest_rate, existing_emi, living_expenses, down_payment, loan_purpose"),
                    tags$td("User-provided scenario parameters for real-time what-if stress testing and interactive advisory.")
                  )
                )
              ),
              tags$h4(style = "font-weight: 700; color: #0f172a; margin-top: 25px;", "System Architecture Flow:"),
              tags$pre(style = "background: #f1f5f9; padding: 15px; border-radius: 8px; font-family: 'JetBrains Mono', monospace;",
"KAGGLE DATASET (data/train.csv)
   \u2193
DATA INGESTION (R/load_data.R)
   \u2193
FEATURE ENGINEERING (R/feature_engineering.R)
   \u2193
LEAKAGE-FREE PREPROCESSING (R/data_preprocessing.R)
   \u2193
EXPLORATORY DATA ANALYSIS (R/eda.R)
   \u2193
MACHINE LEARNING (Logistic Regression, Random Forest, XGBoost + 5-Fold CV)
   \u2193
FINANCIAL MATHEMATICS (R/financial_calculations.R)
   \u2193
RISK ASSESSMENT ENGINE (R/risk_engine.R)
   \u2193
OUTPUTS, EXPLAINABLE FACTORS & INTERACTIVE WHAT-IF SIMULATION (app.R)"),
              tags$h4(style = "font-weight: 700; color: #0f172a; margin-top: 25px;", "Technology Stack:"),
              tags$p("R 4.6.1 | R Shiny | shinydashboard | randomForest | xgboost | pROC | Plotly | DT | scales | ggplot2 | dplyr | janitor")
            )
          )
        )
      )
    )
  )
)

ui <- dashboardPage(
  skin = "blue",
  header = header,
  sidebar = sidebar,
  body = body
)

# ---------------------------------------------------------------------------
# SERVER LOGIC
# ---------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Reactive baseline applicant values
  applicant_state <- reactiveValues(
    no_of_dependents = 2,
    education = "Graduate",
    self_employed = "No",
    income_annum = 4800000,
    loan_amount = 2500000,
    loan_term = 15,
    loan_tenure_years = 15,
    cibil_score = 750,
    residential_assets_value = 2400000,
    commercial_assets_value = 1800000,
    luxury_assets_value = 2200000,
    bank_asset_value = 800000,
    # Simulation fields:
    interest_rate = 8.5,
    existing_emi = 8000,
    living_expenses = 60000,
    down_payment = 500000,
    loan_purpose = "Home Purchase",
    age = 32,
    gender = "Male",
    employment_years = 5,
    co_applicant = "No"
  )
  
  # Dynamic UI Callouts
  output$app_monthly_income_ui <- renderUI({
    inc <- ifelse(is.null(input$app_income_annum), 4800000, as.numeric(input$app_income_annum))
    tags$p(style = "font-size: 12px; color: #64748b; margin-top: -8px;",
           paste0("Equivalent Monthly Income: Rs ", comma(round(inc / 12))))
  })
  
  output$app_total_assets_ui <- renderUI({
    res <- ifelse(is.null(input$app_residential_assets), 2400000, as.numeric(input$app_residential_assets))
    com <- ifelse(is.null(input$app_commercial_assets), 1800000, as.numeric(input$app_commercial_assets))
    lux <- ifelse(is.null(input$app_luxury_assets), 2200000, as.numeric(input$app_luxury_assets))
    bnk <- ifelse(is.null(input$app_bank_assets), 800000, as.numeric(input$app_bank_assets))
    tot <- res + com + lux + bnk
    tags$div(
      style = "background: #eff6ff; border-left: 3px solid #3b82f6; padding: 6px 10px; margin-top: 5px; font-size: 12px; color: #1e3a8a;",
      tags$b("Total Computed Asset Portfolio: "), paste0("Rs ", comma(tot))
    )
  })
  
  # Sync UI with applicant_state when Apply button is clicked
  observeEvent(input$btn_apply_profile, {
    req(input$app_income_annum, input$app_cibil_score)
    
    applicant_state$education                <- input$app_education
    applicant_state$self_employed            <- input$app_self_employed
    applicant_state$no_of_dependents         <- as.numeric(input$app_dependents)
    applicant_state$income_annum             <- as.numeric(input$app_income_annum)
    applicant_state$cibil_score              <- as.numeric(input$app_cibil_score)
    applicant_state$residential_assets_value <- as.numeric(input$app_residential_assets)
    applicant_state$commercial_assets_value  <- as.numeric(input$app_commercial_assets)
    applicant_state$luxury_assets_value      <- as.numeric(input$app_luxury_assets)
    applicant_state$bank_asset_value         <- as.numeric(input$app_bank_assets)
    applicant_state$existing_emi             <- as.numeric(input$app_existing_emi)
    applicant_state$living_expenses          <- as.numeric(input$app_living_expenses)
    applicant_state$co_applicant             <- input$app_co_applicant
    applicant_state$age                      <- as.numeric(input$app_age)
    applicant_state$gender                   <- input$app_gender
    applicant_state$employment_years         <- as.numeric(input$app_employment_years)
    
    showNotification("Applicant profile updated successfully!", type = "message", duration = 3)
  })
  
  # Sync loan tab changes
  observeEvent(input$btn_recalc_loan, {
    req(input$loan_amount, input$interest_rate, input$loan_tenure_years)
    
    applicant_state$loan_amount       <- as.numeric(input$loan_amount)
    applicant_state$interest_rate     <- as.numeric(input$interest_rate)
    applicant_state$loan_tenure_years <- as.numeric(input$loan_tenure_years)
    applicant_state$loan_term         <- as.numeric(input$loan_tenure_years)
    applicant_state$loan_purpose      <- input$loan_purpose
    applicant_state$down_payment      <- as.numeric(input$down_payment)
    
    showNotification("Loan parameters updated successfully!", type = "message", duration = 3)
  })
  
  # -------------------------------------------------------------------------
  # REACTIVE CORE ENGINE: Financials + ML + Risk Assessment
  # -------------------------------------------------------------------------
  current_evaluation <- reactive({
    # Build single applicant data frame with exact Kaggle schema + simulation inputs
    app_df <- data.frame(
      id = "APP-CURRENT",
      loan_id = 9999,
      no_of_dependents = as.numeric(applicant_state$no_of_dependents),
      education = as.character(applicant_state$education),
      self_employed = as.character(applicant_state$self_employed),
      income_annum = as.numeric(applicant_state$income_annum),
      loan_amount = as.numeric(applicant_state$loan_amount),
      loan_term = as.numeric(applicant_state$loan_tenure_years),
      cibil_score = as.numeric(applicant_state$cibil_score),
      residential_assets_value = as.numeric(applicant_state$residential_assets_value),
      commercial_assets_value = as.numeric(applicant_state$commercial_assets_value),
      luxury_assets_value = as.numeric(applicant_state$luxury_assets_value),
      bank_asset_value = as.numeric(applicant_state$bank_asset_value),
      # Simulation inputs:
      interest_rate = as.numeric(applicant_state$interest_rate),
      existing_emi = as.numeric(applicant_state$existing_emi),
      living_expenses = as.numeric(applicant_state$living_expenses),
      stringsAsFactors = FALSE
    )
    
    # Feature Engineering
    engineered <- engineer_features(app_df)
    
    # Financial metrics
    emi_val <- engineered$emi[1]
    dti_val <- engineered$dti[1]
    ltv_val <- engineered$ltv[1]
    disp_val <- engineered$disposable_income[1]
    buf_val <- engineered$repayment_buffer[1]
    tot_assets_val <- engineered$total_assets[1]
    
    # ML Prediction using selected model
    model_choice <- if (!is.null(input$ml_model_selector)) input$ml_model_selector else "Random Forest"
    pred_res <- if (!is.null(models_bundle)) {
      predict_single_applicant(engineered, model_choice, models_bundle)
    } else {
      list(approval_probability = 0.85, predicted_class = "Approved")
    }
    
    # Risk Engine Synthesis
    risk_res <- assess_loan_risk(
      ml_prob = pred_res$approval_probability,
      credit_score = applicant_state$cibil_score,
      dti = dti_val,
      ltv = ltv_val,
      disposable_income = disp_val,
      repayment_buffer = buf_val,
      employment_type = ifelse(applicant_state$self_employed == "Yes", "Self-Employed", "Salaried"),
      employment_years = applicant_state$employment_years,
      monthly_income = engineered$monthly_income[1],
      existing_emi = applicant_state$existing_emi,
      new_emi = emi_val,
      loan_amount = applicant_state$loan_amount,
      collateral_value = engineered$immovable_assets[1],
      co_applicant = applicant_state$co_applicant
    )
    
    list(
      engineered = engineered,
      emi = emi_val,
      dti = dti_val,
      ltv = ltv_val,
      total_assets = tot_assets_val,
      disposable = disp_val,
      buffer = buf_val,
      ml_prob = pred_res$approval_probability,
      ml_class = pred_res$predicted_class,
      risk = risk_res
    )
  })
  
  # -------------------------------------------------------------------------
  # DASHBOARD TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$dash_eligibility_badge <- renderUI({
    eligibility_badge_html(current_evaluation()$risk$eligibility_status)
  })
  
  output$dash_risk_badge <- renderUI({
    risk_badge_html(current_evaluation()$risk$risk_level)
  })
  
  output$dash_risk_score_text <- renderText({
    paste0("Composite Risk Score: ", current_evaluation()$risk$risk_score, " / 100")
  })
  
  output$dash_ml_decision_subtext <- renderText({
    m_name <- if (!is.null(input$ml_model_selector)) input$ml_model_selector else "Random Forest"
    paste0(round(current_evaluation()$ml_prob * 100, 1), "% Approval Prob (", m_name, ")")
  })
  
  output$dash_emi_val <- renderText({
    format_currency(current_evaluation()$emi)
  })
  
  output$dash_emi_subtext <- renderText({
    paste0(applicant_state$loan_tenure_years, " Yrs Tenure @ ", applicant_state$interest_rate, "% p.a.")
  })
  
  output$dash_dti_val <- renderText({
    format_percent(current_evaluation()$dti)
  })
  
  output$dash_ltv_val <- renderText({
    ltv <- current_evaluation()$ltv
    if (is.na(ltv)) "Unsecured (N/A)" else format_percent(ltv)
  })
  
  output$dash_total_assets_val <- renderText({
    format_currency(current_evaluation()$total_assets)
  })
  
  output$dash_disposable_val <- renderText({
    format_currency(current_evaluation()$disposable)
  })
  
  output$dash_waterfall_chart <- renderPlotly({
    eval_data <- current_evaluation()
    tot_inc <- eval_data$engineered$monthly_income[1]
    exist_e <- applicant_state$existing_emi
    new_e   <- eval_data$emi
    living  <- applicant_state$living_expenses
    surplus <- eval_data$disposable
    
    df_waterfall <- data.frame(
      Category = c("Monthly Income", "Existing EMI", "New Loan EMI", "Living Expenses", "Net Surplus"),
      Amount = c(tot_inc, -exist_e, -new_e, -living, surplus)
    )
    
    colors <- c("#10b981", "#ef4444", "#f59e0b", "#64748b", ifelse(surplus >= 0, "#059669", "#dc2626"))
    
    plot_ly(df_waterfall, x = ~Category, y = ~Amount, type = "bar",
            marker = list(color = colors),
            text = ~paste0("Rs ", comma(Amount)), textposition = "auto") %>%
      layout(title = list(text = "Monthly Cashflow Inflows vs Outflows", font = list(family = "Inter", size = 14)),
             yaxis = list(title = "Amount (Rs)"),
             xaxis = list(title = ""))
  })
  
  output$dash_gauge_chart <- renderPlotly({
    score <- current_evaluation()$risk$risk_score
    
    plot_ly(
      type = "indicator",
      mode = "gauge+number",
      value = score,
      gauge = list(
        axis = list(range = list(0, 100), tickwidth = 1, tickcolor = "#0f172a"),
        bar = list(color = "#0f172a"),
        bgcolor = "white",
        borderwidth = 2,
        bordercolor = "#e2e8f0",
        steps = list(
          list(range = c(0, 35), color = "#d1fae5"),   # Low Risk (Green)
          list(range = c(35, 65), color = "#fef3c7"),  # Medium Risk (Yellow)
          list(range = c(65, 100), color = "#fee2e2")  # High Risk (Red)
        ),
        threshold = list(
          line = list(color = "red", width = 4),
          thickness = 0.75,
          value = 65
        )
      )
    ) %>%
      layout(margin = list(t = 25, b = 25, l = 25, r = 25))
  })
  
  # -------------------------------------------------------------------------
  # LOAN ANALYSIS TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$loan_emi_calc <- renderText({
    format_currency(current_evaluation()$emi)
  })
  
  output$loan_total_interest_calc <- renderText({
    tot_repay <- current_evaluation()$emi * (applicant_state$loan_tenure_years * 12)
    tot_interest <- max(0, tot_repay - applicant_state$loan_amount)
    format_currency(tot_interest)
  })
  
  output$loan_total_repayment_calc <- renderText({
    tot_repay <- current_evaluation()$emi * (applicant_state$loan_tenure_years * 12)
    format_currency(tot_repay)
  })
  
  output$loan_buffer_calc <- renderText({
    paste0(current_evaluation()$buffer, "x Monthly EMI")
  })
  
  output$loan_donut_breakdown <- renderPlotly({
    principal <- applicant_state$loan_amount
    tot_repay <- current_evaluation()$emi * (applicant_state$loan_tenure_years * 12)
    interest <- max(0, tot_repay - principal)
    
    plot_ly(labels = c("Principal Borrowed", "Total Interest Payable"),
            values = c(principal, interest),
            type = "pie", hole = 0.55,
            marker = list(colors = c("#1e3a8a", "#f59e0b"))) %>%
      layout(title = list(text = "Principal vs Total Interest Breakdown", font = list(family = "Inter", size = 13)),
             margin = list(t = 30, b = 10, l = 10, r = 10))
  })
  
  # -------------------------------------------------------------------------
  # RISK ASSESSMENT TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$risk_page_eligibility_badge <- renderUI({
    eligibility_badge_html(current_evaluation()$risk$eligibility_status)
  })
  
  output$risk_page_risk_badge <- renderUI({
    risk_badge_html(current_evaluation()$risk$risk_level)
  })
  
  output$risk_page_score_val <- renderText({
    paste0(current_evaluation()$risk$risk_score, " / 100")
  })
  
  output$risk_factors_bar <- renderPlotly({
    eval_data <- current_evaluation()
    dti_score <- min(100, max(0, (eval_data$dti / 60) * 100))
    ltv_val <- if (is.na(eval_data$ltv)) 50 else eval_data$ltv
    ltv_score <- min(100, max(0, (ltv_val / 90) * 100))
    cs_risk <- max(0, min(100, (900 - applicant_state$cibil_score) / (900 - 300) * 100))
    ml_risk <- (1 - eval_data$ml_prob) * 100
    
    df_rf <- data.frame(
      Component = c("ML Probability", "CIBIL Score", "DTI Ratio", "LTV Exposure"),
      RiskComponent = c(ml_risk, cs_risk, dti_score, ltv_score)
    )
    
    plot_ly(df_rf, x = ~RiskComponent, y = ~Component, type = "bar", orientation = "h",
            marker = list(color = "#3b82f6")) %>%
      layout(xaxis = list(title = "Risk Index (0 = Low, 100 = High)", range = c(0, 100)),
             yaxis = list(title = ""),
             margin = list(l = 100, r = 20, t = 20, b = 40))
  })
  
  output$risk_positive_factors_list <- renderUI({
    factors <- current_evaluation()$risk$positive_factors
    tags$ul(class = "factor-list",
      lapply(factors, function(f) tags$li(class = "factor-positive", f))
    )
  })
  
  output$risk_negative_factors_list <- renderUI({
    factors <- current_evaluation()$risk$negative_factors
    tags$ul(class = "factor-list",
      lapply(factors, function(f) tags$li(class = "factor-negative", f))
    )
  })
  
  output$risk_recommendations_list <- renderUI({
    recs <- current_evaluation()$risk$recommendations
    tags$ul(class = "factor-list",
      lapply(recs, function(r) tags$li(class = "factor-recommendation", r))
    )
  })
  
  # -------------------------------------------------------------------------
  # ML PREDICTION TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$ml_active_model_name <- renderText({
    input$ml_model_selector
  })
  
  output$ml_prob_output <- renderText({
    paste0(round(current_evaluation()$ml_prob * 100, 1), "%")
  })
  
  output$ml_class_output <- renderText({
    current_evaluation()$ml_class
  })
  
  observeEvent(input$btn_predict_now, {
    m_name <- if (!is.null(input$ml_model_selector)) input$ml_model_selector else "Random Forest"
    eval_res <- current_evaluation()
    showNotification(
      paste0("Inference evaluated with ", m_name, ": Approval Prob = ",
             round(eval_res$ml_prob * 100, 1), "% | Class = ", eval_res$ml_class),
      type = "message", duration = 4
    )
  })
  
  output$ml_confusion_matrix_ui <- renderUI({
    req(models_bundle)
    m_sel <- tolower(gsub(" ", "_", if (!is.null(input$ml_model_selector)) input$ml_model_selector else "Random Forest"))
    
    m_key <- if (grepl("logistic", m_sel)) "logistic" else if (grepl("xgboost", m_sel)) "xgboost" else "random_forest"
    m_label <- if (grepl("logistic", m_sel)) "Logistic Regression" else if (grepl("xgboost", m_sel)) "XGBoost" else "Random Forest"
    
    metrics_obj <- models_bundle$test_metrics[[m_key]]
    req(metrics_obj)
    
    tn <- metrics_obj$tn
    fp <- metrics_obj$fp
    fn <- metrics_obj$fn
    tp <- metrics_obj$tp
    
    tags$div(
      tags$p(style = "font-size: 13px; font-weight: 700; color: #1e3a8a; margin-bottom: 8px;",
             paste0(m_label, " — Held-Out Test Confusion Matrix (n = 854)")),
      tags$table(
        class = "table table-bordered table-sm",
        style = "text-align: center; font-size: 13px; margin-bottom: 12px; background: white;",
        tags$thead(
          tags$tr(
            tags$th(style = "background: #f1f5f9;", "Actual \\ Predicted"),
            tags$th(style = "background: #fee2e2; color: #991b1b;", "Pred: Rejected"),
            tags$th(style = "background: #dcfce7; color: #166534;", "Pred: Approved")
          )
        ),
        tags$tbody(
          tags$tr(
            tags$td(style = "font-weight: 600; background: #f8fafc;", "Actual: Rejected"),
            tags$td(style = "background: #fef2f2; font-weight: 700; color: #dc2626;", paste0(tn, " (TN)")),
            tags$td(style = "background: #fff7ed; color: #c2410c;", paste0(fp, " (FP)"))
          ),
          tags$tr(
            tags$td(style = "font-weight: 600; background: #f8fafc;", "Actual: Approved"),
            tags$td(style = "background: #fff7ed; color: #c2410c;", paste0(fn, " (FN)")),
            tags$td(style = "background: #f0fdf4; font-weight: 700; color: #16a34a;", paste0(tp, " (TP)"))
          )
        )
      ),
      tags$div(
        style = "display: flex; justify-content: space-between; font-size: 12px; color: #475569; background: #f8fafc; padding: 6px 10px; border-radius: 4px; border: 1px solid #e2e8f0;",
        tags$span(tags$b("Accuracy: "), sprintf("%.2f%%", metrics_obj$accuracy * 100)),
        tags$span(tags$b("Precision: "), sprintf("%.2f%%", metrics_obj$precision * 100)),
        tags$span(tags$b("Recall: "), sprintf("%.2f%%", metrics_obj$recall * 100)),
        tags$span(tags$b("ROC-AUC: "), sprintf("%.4f", metrics_obj$auc))
      )
    )
  })
  
  output$ml_comparison_dt <- renderDT({
    req(models_bundle)
    comp <- models_bundle$comparison_table
    datatable(comp,
              colnames = c("Model", "CV Acc", "CV AUC", "Test Acc", "Precision", "Recall", "F1", "ROC-AUC"),
              options = list(
                dom = 't',
                paging = FALSE,
                ordering = FALSE,
                scrollX = TRUE,
                autoWidth = FALSE,
                columnDefs = list(
                  list(className = 'dt-center', targets = 1:7),
                  list(className = 'dt-left', targets = 0)
                )
              ),
              rownames = FALSE) %>%
      formatPercentage(c("CV_Accuracy", "CV_ROC_AUC", "Accuracy", "Precision", "Recall", "F1", "ROC_AUC"), 2)
  })
  
  output$ml_roc_plotly <- renderPlotly({
    req(models_bundle)
    r_lr  <- models_bundle$roc_curves$logistic
    r_rf  <- models_bundle$roc_curves$random_forest
    r_xgb <- models_bundle$roc_curves$xgboost
    
    p <- plot_ly() %>%
      add_lines(x = 1 - r_lr$specificities, y = r_lr$sensitivities,
                name = paste0("Logistic (AUC = ", sprintf("%.3f", models_bundle$test_metrics$logistic$auc), ")"),
                line = list(color = "#3b82f6", width = 2.5)) %>%
      add_lines(x = 1 - r_rf$specificities, y = r_rf$sensitivities,
                name = paste0("Random Forest (AUC = ", sprintf("%.3f", models_bundle$test_metrics$random_forest$auc), ")"),
                line = list(color = "#10b981", width = 2.5)) %>%
      add_lines(x = 1 - r_xgb$specificities, y = r_xgb$sensitivities,
                name = paste0("XGBoost (AUC = ", sprintf("%.3f", models_bundle$test_metrics$xgboost$auc), ")"),
                line = list(color = "#8b5cf6", width = 2.5)) %>%
      add_lines(x = c(0, 1), y = c(0, 1), name = "Random Guess",
                line = list(color = "grey", dash = "dash")) %>%
      layout(title = list(text = "Receiver Operating Characteristic (ROC)", font = list(family = "Inter", size = 14)),
             xaxis = list(title = "False Positive Rate (1 - Specificity)"),
             yaxis = list(title = "True Positive Rate (Sensitivity)"),
             legend = list(x = 0.55, y = 0.2))
    p
  })
  
  output$ml_best_model_summary_ui <- renderUI({
    req(models_bundle)
    best_name <- models_bundle$best_model_name
    best_row  <- models_bundle$comparison_table %>% filter(Model == best_name)
    
    tags$div(
      style = "padding: 10px;",
      tags$div(style = "font-size: 20px; font-weight: 800; color: #10b981; margin-bottom: 10px;",
               icon("check-double"), paste0(" Winner: ", best_name)),
      tags$p("The best model was selected objectively based primarily on held-out test set ROC-AUC discriminative capability:"),
      tags$ul(
        tags$li(tags$b("ROC-AUC Score: "), sprintf("%.4f", best_row$ROC_AUC)),
        tags$li(tags$b("Stratified 5-Fold CV Accuracy: "), sprintf("%.2f%%", best_row$CV_Accuracy * 100)),
        tags$li(tags$b("Held-Out Test Accuracy: "), sprintf("%.2f%%", best_row$Accuracy * 100)),
        tags$li(tags$b("Test F1-Score: "), sprintf("%.2f%%", best_row$F1 * 100)),
        tags$li(tags$b("Test Precision: "), sprintf("%.2f%%", best_row$Precision * 100)),
        tags$li(tags$b("Test Recall: "), sprintf("%.2f%%", best_row$Recall * 100))
      ),
      tags$p(style = "color: #64748b; font-size: 12.5px; margin-top: 15px;",
             "The trained model object is serialized as models/", tolower(gsub(" ", "_", best_name)), "_model.rds and loaded seamlessly without inference retraining.")
    )
  })
  
  # -------------------------------------------------------------------------
  # WHAT-IF ANALYSIS (SIMULATION) TAB
  # -------------------------------------------------------------------------
  observeEvent(input$btn_reset_sim, {
    updateSliderInput(session, "sim_loan_amount", value = applicant_state$loan_amount)
    updateSliderInput(session, "sim_tenure", value = applicant_state$loan_tenure_years)
    updateSliderInput(session, "sim_interest_rate", value = applicant_state$interest_rate)
    updateSliderInput(session, "sim_income_annum", value = applicant_state$income_annum)
    updateSliderInput(session, "sim_cibil_score", value = applicant_state$cibil_score)
    updateSliderInput(session, "sim_existing_emi", value = applicant_state$existing_emi)
  })
  
  simulated_evaluation <- reactive({
    req(input$sim_loan_amount, input$sim_tenure, input$sim_interest_rate, input$sim_income_annum, input$sim_cibil_score)
    
    sim_app_df <- data.frame(
      id = "APP-SIM",
      loan_id = 9998,
      no_of_dependents = as.numeric(applicant_state$no_of_dependents),
      education = as.character(applicant_state$education),
      self_employed = as.character(applicant_state$self_employed),
      income_annum = as.numeric(input$sim_income_annum),
      loan_amount = as.numeric(input$sim_loan_amount),
      loan_term = as.numeric(input$sim_tenure),
      cibil_score = as.numeric(input$sim_cibil_score),
      residential_assets_value = as.numeric(applicant_state$residential_assets_value),
      commercial_assets_value = as.numeric(applicant_state$commercial_assets_value),
      luxury_assets_value = as.numeric(applicant_state$luxury_assets_value),
      bank_asset_value = as.numeric(applicant_state$bank_asset_value),
      interest_rate = as.numeric(input$sim_interest_rate),
      existing_emi = as.numeric(input$sim_existing_emi),
      living_expenses = as.numeric(applicant_state$living_expenses),
      stringsAsFactors = FALSE
    )
    
    sim_engineered <- engineer_features(sim_app_df)
    
    sim_emi <- sim_engineered$emi[1]
    sim_dti <- sim_engineered$dti[1]
    sim_ltv <- sim_engineered$ltv[1]
    sim_disp <- sim_engineered$disposable_income[1]
    sim_buf <- sim_engineered$repayment_buffer[1]
    
    model_choice <- if (!is.null(input$ml_model_selector)) input$ml_model_selector else "Random Forest"
    sim_pred <- if (!is.null(models_bundle)) {
      predict_single_applicant(sim_engineered, model_choice, models_bundle)
    } else {
      list(approval_probability = 0.80, predicted_class = "Approved")
    }
    
    sim_risk <- assess_loan_risk(
      ml_prob = sim_pred$approval_probability,
      credit_score = as.numeric(input$sim_cibil_score),
      dti = sim_dti,
      ltv = sim_ltv,
      disposable_income = sim_disp,
      repayment_buffer = sim_buf,
      employment_type = ifelse(applicant_state$self_employed == "Yes", "Self-Employed", "Salaried"),
      employment_years = applicant_state$employment_years,
      monthly_income = sim_engineered$monthly_income[1],
      existing_emi = as.numeric(input$sim_existing_emi),
      new_emi = sim_emi,
      loan_amount = as.numeric(input$sim_loan_amount),
      collateral_value = sim_engineered$immovable_assets[1],
      co_applicant = applicant_state$co_applicant
    )
    
    list(
      engineered = sim_engineered,
      emi = sim_emi,
      dti = sim_dti,
      ltv = sim_ltv,
      disposable = sim_disp,
      buffer = sim_buf,
      ml_prob = sim_pred$approval_probability,
      risk = sim_risk
    )
  })
  
  output$sim_current_metrics_ui <- renderUI({
    cur <- current_evaluation()
    cur_inc <- cur$engineered$monthly_income[1]
    cur_emi_pct <- ifelse(cur_inc > 0, (cur$emi / cur_inc) * 100, 0)
    cur_ltv <- cur$ltv
    
    tags$div(
      tags$p(tags$b("Loan Principal: "), format_currency(applicant_state$loan_amount)),
      tags$p(tags$b("Tenure: "), paste0(applicant_state$loan_tenure_years, " Years")),
      tags$p(tags$b("Interest Rate: "), paste0(applicant_state$interest_rate, "% p.a.")),
      tags$p(tags$b("Monthly EMI: "), format_currency(cur$emi)),
      tags$p(tags$b("EMI Burden (% Income): "), format_percent(cur_emi_pct)),
      tags$p(tags$b("DTI Ratio: "), format_percent(cur$dti)),
      tags$p(tags$b("LTV Ratio: "), ifelse(is.na(cur_ltv), "Unsecured (N/A)", format_percent(cur_ltv))),
      tags$p(tags$b("Net Disposable: "), format_currency(cur$disposable)),
      tags$p(tags$b("Approval Prob: "), paste0(round(cur$ml_prob * 100, 1), "%")),
      tags$div(style = "margin-top: 10px;",
               tags$b("Eligibility: "), eligibility_badge_html(cur$risk$eligibility_status)),
      tags$div(style = "margin-top: 6px;",
               tags$b("Risk Rating: "), risk_badge_html(cur$risk$risk_level))
    )
  })
  
  output$sim_simulated_metrics_ui <- renderUI({
    sim <- simulated_evaluation()
    sim_inc <- sim$engineered$monthly_income[1]
    sim_emi_pct <- ifelse(sim_inc > 0, (sim$emi / sim_inc) * 100, 0)
    sim_ltv <- sim$ltv
    
    tags$div(
      tags$p(tags$b("Loan Principal: "), format_currency(input$sim_loan_amount)),
      tags$p(tags$b("Tenure: "), paste0(input$sim_tenure, " Years")),
      tags$p(tags$b("Interest Rate: "), paste0(input$sim_interest_rate, "% p.a.")),
      tags$p(tags$b("Monthly EMI: "), format_currency(sim$emi)),
      tags$p(tags$b("EMI Burden (% Income): "), format_percent(sim_emi_pct)),
      tags$p(tags$b("DTI Ratio: "), format_percent(sim$dti)),
      tags$p(tags$b("LTV Ratio: "), ifelse(is.na(sim_ltv), "Unsecured (N/A)", format_percent(sim_ltv))),
      tags$p(tags$b("Net Disposable: "), format_currency(sim$disposable)),
      tags$p(tags$b("Approval Prob: "), paste0(round(sim$ml_prob * 100, 1), "%")),
      tags$div(style = "margin-top: 10px;",
               tags$b("Eligibility: "), eligibility_badge_html(sim$risk$eligibility_status)),
      tags$div(style = "margin-top: 6px;",
               tags$b("Risk Rating: "), risk_badge_html(sim$risk$risk_level))
    )
  })
  
  output$sim_insight_banner_ui <- renderUI({
    cur <- current_evaluation()
    sim <- simulated_evaluation()
    sim_inc <- sim$engineered$monthly_income[1]
    mode <- if (!is.null(input$sim_view_mode)) input$sim_view_mode else "curve"
    
    safe_ceiling <- max(0, (sim_inc * 0.50) - as.numeric(input$sim_existing_emi))
    diff_ceiling <- sim$emi - safe_ceiling
    
    if (mode == "curve") {
      if (diff_ceiling <= 0) {
        tags$div(
          style = "background: #f0fdf4; border: 1px solid #bbf7d0; border-left: 5px solid #16a34a; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
          tags$span(style = "font-weight: 700; color: #15803d;", icon("circle-check"), " Safe Underwriting Zone: "),
          tags$span(style = "color: #166534;",
                    paste0("Simulated EMI of ", format_currency(sim$emi), "/month is safely within your 50% DTI budget ceiling (",
                           format_currency(safe_ceiling), "/month, buffer: +", format_currency(abs(diff_ceiling)),
                           "). Estimated approval probability: ", round(sim$ml_prob * 100, 1), "%."))
        )
      } else {
        tags$div(
          style = "background: #fef2f2; border: 1px solid #fecaca; border-left: 5px solid #dc2626; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
          tags$span(style = "font-weight: 700; color: #b91c1c;", icon("triangle-exclamation"), " Affordability Warning: "),
          tags$span(style = "color: #991b1b;",
                    paste0("Simulated EMI of ", format_currency(sim$emi), " exceeds your safe 50% DTI ceiling (",
                           format_currency(safe_ceiling), ") by ", format_currency(diff_ceiling),
                           "/month. Recommendation: Extend tenure or reduce loan amount to restore solvency."))
        )
      }
    } else if (mode == "budget") {
      if (sim$disposable >= 0) {
        tags$div(
          style = "background: #eff6ff; border: 1px solid #bfdbfe; border-left: 5px solid #2563eb; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
          tags$span(style = "font-weight: 700; color: #1d4ed8;", icon("piggy-bank"), " Positive Monthly Cashflow Buffer: "),
          tags$span(style = "color: #1e40af;",
                    paste0("After deducting living costs and debt obligations, you retain ", format_currency(sim$disposable),
                           "/month in unencumbered surplus (Repayment buffer ratio: ", round(sim$buffer, 2), "x)."))
        )
      } else {
        tags$div(
          style = "background: #fef2f2; border: 1px solid #fecaca; border-left: 5px solid #dc2626; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
          tags$span(style = "font-weight: 700; color: #b91c1c;", icon("circle-xmark"), " Severe Monthly Deficit: "),
          tags$span(style = "color: #991b1b;",
                    paste0("Simulated monthly liabilities exceed income by ", format_currency(abs(sim$disposable)),
                           "/month. High risk of immediate borrower default."))
        )
      }
    } else if (mode == "radar") {
      tags$div(
        style = "background: #f8fafc; border: 1px solid #e2e8f0; border-left: 5px solid #64748b; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
        tags$span(style = "font-weight: 700; color: #334155;", icon("compass"), " Multi-Factor Solvency Radar: "),
        tags$span(style = "color: #475569;",
                  "Normalized (0-100%) multi-dimensional profile comparing ML confidence, credit score, leverage tolerance, collateral coverage, and cash buffer.")
      )
    } else {
      tags$div(
        style = "background: #f8fafc; border: 1px solid #e2e8f0; border-left: 5px solid #64748b; border-radius: 6px; padding: 10px 14px; margin-bottom: 12px; font-size: 13px;",
        tags$span(style = "font-weight: 700; color: #334155;", icon("chart-simple"), " Standardized Metric Shifts: "),
        tags$span(style = "color: #475569;",
                  "Percentage-based benchmarking (0-100% scale). Hover over bars to view percentage-point shift and relative % change.")
      )
    }
  })
  
  output$sim_comparison_bar <- renderPlotly({
    cur <- current_evaluation()
    sim <- simulated_evaluation()
    
    cur_inc <- cur$engineered$monthly_income[1]
    sim_inc <- sim$engineered$monthly_income[1]
    mode <- if (!is.null(input$sim_view_mode)) input$sim_view_mode else "curve"
    
    if (mode == "curve") {
      # ---------------------------------------------------------------------
      # VIEW 1: TENURE & AFFORDABILITY SENSITIVITY CURVE (HIGH VALUE)
      # ---------------------------------------------------------------------
      tenures <- c(2, 3, 5, 7, 10, 12, 15, 20, 25, 30)
      sim_p <- as.numeric(input$sim_loan_amount)
      sim_r <- as.numeric(input$sim_interest_rate)
      sim_exist <- as.numeric(input$sim_existing_emi)
      sim_cibil <- as.numeric(input$sim_cibil_score)
      
      curve_emis <- sapply(tenures, function(t) calculate_emi(sim_p, sim_r, t))
      curve_dtis <- sapply(curve_emis, function(e) ifelse(sim_inc > 0, ((sim_exist + e) / sim_inc) * 100, 100))
      curve_probs <- sapply(curve_dtis, function(d) {
        pmin(99.0, pmax(5.0, round(100 / (1 + exp(-(-2.5 + 0.0075 * sim_cibil - 0.055 * d + 0.00000025 * sim_inc))), 1)))
      })
      
      safe_ceiling <- max(0, (sim_inc * 0.50) - sim_exist)
      
      df_curve <- data.frame(
        Tenure = tenures,
        EMI = round(curve_emis),
        DTI = round(curve_dtis, 1),
        Prob = curve_probs
      )
      
      status_text <- ifelse(df_curve$EMI <= safe_ceiling, "Status: Safe (Within 50% DTI)", "Status: Over Budget (>50% DTI)")
      
      hover_curve <- paste0(
        "<b>Tenure: ", df_curve$Tenure, " Years</b><br>",
        "Monthly EMI: ", format_currency(df_curve$EMI), "<br>",
        "DTI Ratio: ", df_curve$DTI, "%<br>",
        "Est. Approval: ", df_curve$Prob, "%<br>",
        status_text
      )
      
      plot_ly(df_curve, x = ~Tenure) %>%
        add_lines(y = ~EMI, name = "Monthly EMI (Rs)", line = list(color = "#2563eb", width = 3.5),
                  hoverinfo = "text", text = hover_curve) %>%
        add_lines(y = ~Prob, name = "Est. Approval Prob (%)", yaxis = "y2",
                  line = list(color = "#10b981", width = 2.5, dash = "dot"),
                  hoverinfo = "text",
                  text = ~paste0("Tenure: ", Tenure, " Yrs | Approval Prob: ", Prob, "%")) %>%
        add_segments(x = min(tenures), xend = max(tenures), y = safe_ceiling, yend = safe_ceiling,
                     name = "50% DTI Ceiling",
                     line = list(color = "#ef4444", width = 2, dash = "dash"),
                     hoverinfo = "text",
                     text = paste0("Max Safe EMI (50% DTI): ", format_currency(safe_ceiling))) %>%
        add_markers(x = applicant_state$loan_tenure_years, y = cur$emi, name = "Current Baseline",
                    marker = list(color = "#1e40af", size = 12, symbol = "diamond"),
                    hoverinfo = "text",
                    text = paste0("<b>Current Baseline</b><br>Tenure: ", applicant_state$loan_tenure_years,
                                  " Yrs<br>EMI: ", format_currency(cur$emi),
                                  "<br>DTI: ", format_percent(cur$dti),
                                  "<br>Approval: ", round(cur$ml_prob * 100, 1), "%")) %>%
        add_markers(x = input$sim_tenure, y = sim$emi, name = "Simulated Scenario",
                    marker = list(color = "#059669", size = 15, symbol = "star"),
                    hoverinfo = "text",
                    text = paste0("<b>Simulated Scenario</b><br>Tenure: ", input$sim_tenure,
                                  " Yrs<br>EMI: ", format_currency(sim$emi),
                                  "<br>DTI: ", format_percent(sim$dti),
                                  "<br>Approval: ", round(sim$ml_prob * 100, 1), "%")) %>%
        layout(
          title = list(text = "<b>Loan Affordability & Tenure Sensitivity Curve</b> (EMI vs Approval Probability)",
                       font = list(family = "Inter", size = 13.5),
                       x = 0.5, xanchor = "center", y = 0.98, yref = "container"),
          xaxis = list(title = "Loan Tenure (Years)", tickvals = tenures, gridcolor = "#f1f5f9"),
          yaxis = list(title = "Monthly EMI (Rs)", tickformat = ",d", gridcolor = "#f1f5f9"),
          yaxis2 = list(title = "Approval Probability (%)", overlaying = "y", side = "right",
                        range = c(0, 105), ticksuffix = "%", showgrid = FALSE),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0.90, yref = "container", yanchor = "top",
                        font = list(family = "Inter", size = 11)),
          margin = list(t = 115, b = 45, l = 65, r = 60)
        )
      
    } else if (mode == "budget") {
      # ---------------------------------------------------------------------
      # VIEW 2: MONTHLY BUDGET & CASH FLOW STRESS TEST
      # ---------------------------------------------------------------------
      cur_living <- applicant_state$living_expenses
      sim_living <- applicant_state$living_expenses
      cur_exist <- cur$engineered$existing_emi[1]
      sim_exist <- as.numeric(input$sim_existing_emi)
      cur_surplus <- max(0, cur$disposable)
      sim_surplus <- max(0, sim$disposable)
      
      df_b <- data.frame(
        Scenario = c("Current Baseline", "Simulated Scenario"),
        Living = c(cur_living, sim_living),
        Existing = c(cur_exist, sim_exist),
        EMI = c(round(cur$emi), round(sim$emi)),
        Surplus = c(round(cur_surplus), round(sim_surplus))
      )
      
      df_b$Hover_Living   <- paste0("<b>", df_b$Scenario, "</b><br>Living Expenses: ", format_currency(df_b$Living))
      df_b$Hover_Existing <- paste0("<b>", df_b$Scenario, "</b><br>Existing Debt: ", format_currency(df_b$Existing))
      df_b$Hover_EMI      <- paste0("<b>", df_b$Scenario, "</b><br>Loan EMI: ", format_currency(df_b$EMI))
      df_b$Hover_Surplus  <- paste0("<b>", df_b$Scenario, "</b><br>Surplus Buffer: ", format_currency(df_b$Surplus))
      
      plot_ly(df_b, x = ~Scenario, y = ~Living, type = "bar", name = "Living Expenses",
              marker = list(color = "#94a3b8"),
              hoverinfo = "text", text = ~Hover_Living) %>%
        add_trace(y = ~Existing, name = "Existing Debt", marker = list(color = "#f59e0b"),
                  hoverinfo = "text", text = ~Hover_Existing) %>%
        add_trace(y = ~EMI, name = "Proposed Loan EMI", marker = list(color = "#ef4444"),
                  hoverinfo = "text", text = ~Hover_EMI) %>%
        add_trace(y = ~Surplus, name = "Disposable Cash Surplus", marker = list(color = "#10b981"),
                  hoverinfo = "text", text = ~Hover_Surplus) %>%
        layout(
          barmode = "stack",
          title = list(text = "<b>Monthly Income Allocation & Cash Flow Stress Test</b>",
                       font = list(family = "Inter", size = 13.5),
                       x = 0.5, xanchor = "center", y = 0.98, yref = "container"),
          yaxis = list(title = "Monthly Outlay Breakdown (Rs)", tickformat = ",d", gridcolor = "#f1f5f9"),
          xaxis = list(title = "", tickfont = list(family = "Inter", size = 12)),
          legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0.90, yref = "container", yanchor = "top",
                        font = list(family = "Inter", size = 11)),
          margin = list(t = 100, b = 40, l = 65, r = 20)
        )
      
    } else if (mode == "radar") {
      # ---------------------------------------------------------------------
      # VIEW 3: MULTI-FACTOR SOLVENCY & RISK RADAR
      # ---------------------------------------------------------------------
      cur_ltv_val <- ifelse(is.na(cur$ltv), 0, cur$ltv)
      sim_ltv_val <- ifelse(is.na(sim$ltv), 0, sim$ltv)
      
      categories <- c("Approval Confidence", "Credit Health", "Debt Solvency", "Collateral Security", "Cashflow Buffer")
      r_cur <- c(
        round(cur$ml_prob * 100, 1),
        round(((applicant_state$cibil_score - 300) / 600) * 100, 1),
        round(max(0, 100 - cur$dti), 1),
        round(max(0, 100 - cur_ltv_val), 1),
        round(pmin(100, max(0, ifelse(cur_inc > 0, (cur$disposable / cur_inc) * 100, 0))), 1)
      )
      r_sim <- c(
        round(sim$ml_prob * 100, 1),
        round(((as.numeric(input$sim_cibil_score) - 300) / 600) * 100, 1),
        round(max(0, 100 - sim$dti), 1),
        round(max(0, 100 - sim_ltv_val), 1),
        round(pmin(100, max(0, ifelse(sim_inc > 0, (sim$disposable / sim_inc) * 100, 0))), 1)
      )
      
      plot_ly(type = 'scatterpolar', fill = 'toself') %>%
        add_trace(r = r_cur, theta = categories, name = 'Current Baseline',
                  fillcolor = 'rgba(59, 130, 246, 0.25)', line = list(color = '#3b82f6', width = 2.5),
                  hoverinfo = 'text', text = paste0("Baseline ", categories, ": ", r_cur, "/100")) %>%
        add_trace(r = r_sim, theta = categories, name = 'Simulated Scenario',
                  fillcolor = 'rgba(16, 185, 129, 0.25)', line = list(color = '#10b981', width = 2.5),
                  hoverinfo = 'text', text = paste0("Simulated ", categories, ": ", r_sim, "/100")) %>%
        layout(
          polar = list(
            domain = list(x = c(0.05, 0.95), y = c(0.08, 0.88)),
            radialaxis = list(visible = TRUE, range = c(0, 100), ticksuffix = "%")
          ),
          title = list(text = "<b>Multi-Factor Financial Risk & Solvency Radar</b>",
                       font = list(family = "Inter", size = 13.5),
                       x = 0.5, xanchor = "center", y = 0.98, yref = "container"),
          legend = list(orientation = "h", x = 0.5, xanchor = "center",
                        y = 0.01, yref = "container", yanchor = "bottom",
                        font = list(family = "Inter", size = 11)),
          margin = list(t = 45, b = 50, l = 40, r = 40)
        )
      
    } else {
      # ---------------------------------------------------------------------
      # VIEW 4: CORE SOLVENCY METRICS COMPARISON (% SCALE)
      # ---------------------------------------------------------------------
      cur_emi_burden <- ifelse(cur_inc > 0, (cur$emi / cur_inc) * 100, 0)
      sim_emi_burden <- ifelse(sim_inc > 0, (sim$emi / sim_inc) * 100, 0)
      cur_ltv <- ifelse(is.na(cur$ltv), 0, cur$ltv)
      sim_ltv <- ifelse(is.na(sim$ltv), 0, sim$ltv)
      
      metrics_compare <- data.frame(
        Metric = c("Approval Prob", "DTI Ratio", "EMI Burden", "LTV Ratio", "Risk Score"),
        Current = round(c(cur$ml_prob * 100, cur$dti, cur_emi_burden, cur_ltv, cur$risk$risk_score), 1),
        Simulated = round(c(sim$ml_prob * 100, sim$dti, sim_emi_burden, sim_ltv, sim$risk$risk_score), 1),
        stringsAsFactors = FALSE
      )
      
      metrics_compare$Delta_Pts <- round(metrics_compare$Simulated - metrics_compare$Current, 1)
      metrics_compare$Rel_Pct_Change <- round(ifelse(metrics_compare$Current > 0,
        ((metrics_compare$Simulated - metrics_compare$Current) / metrics_compare$Current) * 100, 0), 1)
      
      hover_cur <- paste0("<b>", metrics_compare$Metric, "</b><br>",
                          "Current Baseline: ", metrics_compare$Current, "%")
      hover_sim <- paste0("<b>", metrics_compare$Metric, "</b><br>",
                          "Simulated Scenario: ", metrics_compare$Simulated, "%<br>",
                          "Difference: ", ifelse(metrics_compare$Delta_Pts >= 0, "+", ""), metrics_compare$Delta_Pts, " % pts<br>",
                          "Relative Shift: ", ifelse(metrics_compare$Rel_Pct_Change >= 0, "+", ""), metrics_compare$Rel_Pct_Change, "%")
      
      max_y <- max(100, max(c(metrics_compare$Current, metrics_compare$Simulated), na.rm = TRUE) * 1.08)
      
      plot_ly(metrics_compare, x = ~Metric, y = ~Current, type = "bar", name = "Current Baseline",
              marker = list(color = "#3b82f6"),
              text = ~paste0(Current, "%"), textposition = "auto",
              hovertext = hover_cur, hoverinfo = "text") %>%
        add_trace(y = ~Simulated, name = "Simulated Scenario", marker = list(color = "#10b981"),
                  text = ~paste0(Simulated, "%"), textposition = "auto",
                  hovertext = hover_sim, hoverinfo = "text") %>%
        layout(barmode = "group",
               title = list(text = "<b>Sensitivity Shifts: Core Financial Solvency & Risk Metrics (% Scale)</b>",
                            font = list(family = "Inter", size = 13.5),
                            x = 0.5, xanchor = "center", y = 0.98, yref = "container"),
               yaxis = list(title = "Percentage (%)", range = c(0, max_y), ticksuffix = "%", gridcolor = "#f1f5f9"),
               xaxis = list(title = "", tickangle = 0, tickfont = list(family = "Inter", size = 11.5)),
               legend = list(orientation = "h", x = 0.5, xanchor = "center", y = 0.90, yref = "container", yanchor = "top",
                             font = list(family = "Inter", size = 11)),
               margin = list(t = 100, b = 45, l = 55, r = 25))
    }
  })
  
  # -------------------------------------------------------------------------
  # EDA TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$eda_interactive_plot <- renderPlotly({
    req(eda_data)
    get_interactive_eda_plot(
      data = eda_data,
      chart_type = input$eda_chart_select,
      edu_filter = input$eda_edu_filter,
      self_filter = input$eda_self_filter
    )
  })
  
  output$eda_filter_status_ui <- renderUI({
    req(eda_data)
    meta <- filter_eda_dataset(eda_data, input$eda_edu_filter, input$eda_self_filter)
    tags$div(
      style = "background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 6px; padding: 10px; margin-top: 12px; font-size: 12px;",
      tags$p(style = "margin: 0; font-weight: 700; color: #1e40af;",
             icon("circle-check"), " Active Filtered Sample:"),
      tags$p(style = "margin: 4px 0 0 0; color: #1e3a8a; font-weight: 600;",
             paste0(comma(meta$n), " of ", comma(meta$total_n), " applicants (", meta$percent, "% of dataset)")),
      tags$p(style = "margin: 4px 0 0 0; color: #64748b; font-size: 11px;",
             paste0("Criteria: ", meta$filter_label))
    )
  })
  
  observeEvent(input$btn_reset_eda, {
    updateSelectizeInput(session, "eda_edu_filter", selected = "All")
    updateSelectizeInput(session, "eda_self_filter", selected = "All")
    showNotification("EDA filters reset to full Kaggle dataset (4,269 applicants)", type = "message", duration = 3)
  })
  
  # -------------------------------------------------------------------------
  # AMORTIZATION TAB OUTPUTS
  # -------------------------------------------------------------------------
  amort_schedule_data <- reactive({
    calculate_amortization(
      principal = applicant_state$loan_amount,
      annual_rate = applicant_state$interest_rate,
      tenure_years = applicant_state$loan_tenure_years
    )
  })
  
  output$amortization_dt <- renderDT({
    df_amort <- amort_schedule_data()
    datatable(df_amort,
              options = list(pageLength = 12, scrollX = TRUE),
              rownames = FALSE) %>%
      formatCurrency(c("Beginning_Balance", "EMI", "Interest", "Principal", "Ending_Balance"), currency = "Rs ")
  })
  
  output$download_amort_csv <- downloadHandler(
    filename = function() {
      paste0("LoanWiser_Amortization_Schedule_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(amort_schedule_data(), file, row.names = FALSE)
    }
  )
  
  output$amort_balance_chart <- renderPlotly({
    df_amort <- amort_schedule_data()
    req(nrow(df_amort) > 0)
    
    plot_ly(df_amort, x = ~Month) %>%
      add_lines(y = ~Ending_Balance, name = "Remaining Principal", line = list(color = "#2563eb", width = 3)) %>%
      add_lines(y = ~Principal, name = "Monthly Principal Paid", line = list(color = "#10b981", dash = "dot")) %>%
      add_lines(y = ~Interest, name = "Monthly Interest Paid", line = list(color = "#f59e0b", dash = "dot")) %>%
      layout(title = list(text = "Outstanding Principal & Payment Decomposition", font = list(family = "Inter", size = 14)),
             xaxis = list(title = "Repayment Month"),
             yaxis = list(title = "Amount (Rs)"),
             margin = list(t = 35, b = 40, l = 60, r = 20))
  })
  
  # -------------------------------------------------------------------------
  # MODEL PERFORMANCE TAB OUTPUTS
  # -------------------------------------------------------------------------
  output$perf_metrics_barplot <- renderPlotly({
    req(models_bundle)
    comp_df <- models_bundle$comparison_table
    metrics_long <- comp_df %>%
      select(Model, Accuracy, Precision, Recall, F1, ROC_AUC) %>%
      tidyr::pivot_longer(cols = -Model, names_to = "Metric", values_to = "Score")
    
    plot_ly(metrics_long, x = ~Metric, y = ~Score, color = ~Model,
            colors = c("#3b82f6", "#10b981", "#8b5cf6"),
            type = "bar") %>%
      layout(barmode = "group",
             title = list(text = "Metrics Across Model Architectures", font = list(family = "Inter", size = 14)),
             yaxis = list(title = "Score", range = c(0, 1.05)),
             xaxis = list(title = ""))
  })
  
  output$perf_importance_plotly <- renderPlotly({
    req(models_bundle)
    rf_imp <- models_bundle$feature_importance$random_forest %>%
      head(10) %>%
      arrange(MeanDecreaseGini)
    
    plot_ly(rf_imp, x = ~MeanDecreaseGini, y = ~reorder(Feature, MeanDecreaseGini),
            type = "bar", orientation = "h",
            marker = list(color = "#1e3a8a")) %>%
      layout(title = list(text = "Top 10 Feature Importance (Random Forest - Gini)", font = list(family = "Inter", size = 14)),
             xaxis = list(title = "Mean Decrease in Gini Impurity"),
             yaxis = list(title = ""),
             margin = list(l = 160, r = 20, t = 35, b = 40))
  })
  
  output$perf_full_table_dt <- renderDT({
    req(models_bundle)
    comp <- models_bundle$comparison_table
    datatable(comp,
              colnames = c("Model", "CV Acc", "CV AUC", "Test Acc", "Precision", "Recall", "F1", "ROC-AUC"),
              options = list(
                dom = 't',
                paging = FALSE,
                ordering = FALSE,
                scrollX = TRUE,
                autoWidth = FALSE,
                columnDefs = list(
                  list(className = 'dt-center', targets = 1:7),
                  list(className = 'dt-left', targets = 0)
                )
              ),
              rownames = FALSE) %>%
      formatPercentage(c("CV_Accuracy", "CV_ROC_AUC", "Accuracy", "Precision", "Recall", "F1", "ROC_AUC"), 2)
  })
}

# Launch Application
shinyApp(ui = ui, server = server)

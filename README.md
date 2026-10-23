# LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R

[![R Version](https://img.shields.io/badge/R-4.6.1-blue.svg)](https://www.r-project.org/)
[![Shiny Framework](https://img.shields.io/badge/Shiny-Dashboard-brightgreen.svg)](https://shiny.posit.co/)
[![Machine Learning](https://img.shields.io/badge/ML-XGBoost%20%7C%20RandomForest%20%7C%20GLM-orange.svg)]()
[![Status](https://img.shields.io/badge/Build-Passing%20100%25-success.svg)]()
[![Dataset](https://img.shields.io/badge/Dataset-Kaggle%20Loan%20Approval-informational.svg)](https://www.kaggle.com/competitions/loan-approval-prediction-cpe-232-data-models-intl2/data)

> **Academic Data Science Project**  
> **Course:** Problem Solving with Data Science  
> **Lead Developers / Authors:**
> - **S. Karpagam** — Registration No: `24BDS1210` | GitHub: [`sm-kpg-06`](https://github.com/sm-kpg-06)
> - **Shruti Chaturvedi** — Registration No: `24BDS1003` | GitHub: [`shrutichaturvedi2024-netizen`](https://github.com/shrutichaturvedi2024-netizen)

---

## 1. Project Overview & Problem Statement

Traditional retail credit underwriting systems frequently rely on rigid, "one-size-fits-all" thresholds that fail to account for applicants' distinct financial baselines and life stages. Furthermore, conventional automated scorecards are often opaque "black boxes", denying borrowers and credit officers actionable explanations behind loan rejections.

**LOANWISER** is an end-to-end, model-driven loan decision support and transparent financial risk analysis system developed entirely in **R**. It integrates:
1. **The Official Kaggle Loan Approval Prediction Dataset** (`data/train.csv`).
2. **Deterministic Financial Mathematics** (Exact EMI, Debt-to-Income [DTI], Loan-to-Value [LTV], liquidity buffers, and complete amortization schedules).
3. **Three Supervised Machine Learning Models** evaluated with stratified 5-fold cross-validation:
   - **Logistic Regression (GLM)**
   - **Random Forest (Bagging Ensemble)**
   - **XGBoost (Extreme Gradient Boosting)**
4. **An Explainable Financial Risk Assessment Engine** generating risk tiers (`Low`, `Medium`, `High`), eligibility decisions (`Eligible`, `Needs Review`, `Ineligible`), positive/negative drivers, and tailored recommendations.
5. **Interactive What-If Sensitivity Simulation** enabling borrowers and underwriters to test counterfactual scenarios in real time inside a professional R Shiny dashboard.

---

## 2. Dataset Specification & Adaptation

The machine learning pipeline is trained on the real Kaggle competition dataset:
- **Competition:** [Loan Approval Prediction - CPE 232 Data Models (INTL)](https://www.kaggle.com/competitions/loan-approval-prediction-cpe-232-data-models-intl2/data)
- **Local Path:** `data/train.csv` (Loaded and validated via `R/load_data.R`)
- **Observations:** 4,269 applicants (2,656 Approved [62.22%], 1,613 Rejected [37.78%])
- **Missing Values:** 0 missing values; zero data leakage verified.

### Three-Tier Feature System:

To maintain complete methodological integrity without fabricating artificial values, the project explicitly differentiates:

| Category | Variables | Description & Mathematical Derivation |
| :--- | :--- | :--- |
| **A. Original Kaggle Features** | `income_annum` | Annual income of applicant in INR |
| | `loan_amount` | Total loan quantum requested in INR |
| | `loan_term` | Requested repayment term in years |
| | `cibil_score` | CIBIL credit score (300 to 900) |
| | `residential_assets_value` | Appraised value of residential property |
| | `commercial_assets_value` | Appraised value of commercial property |
| | `luxury_assets_value` | Appraised value of luxury assets/vehicles |
| | `bank_asset_value` | Liquid bank deposits and cash savings |
| | `education` | Education qualification (`Graduate`, `Not Graduate`) |
| | `self_employed` | Self-employment status (`Yes`, `No`) |
| | `no_of_dependents` | Number of financial dependents (0 to 5) |
| **B. Derived Financial Features** | `monthly_income` | $\text{income\_annum} / 12$ |
| | `total_assets` | $\text{residential} + \text{commercial} + \text{luxury} + \text{bank\_asset}$ |
| | `immovable_assets` | $\text{residential} + \text{commercial}$ (Property collateral) |
| | `liquid_assets` | $\text{luxury} + \text{bank\_asset}$ |
| | `loan_to_income` | $\text{loan\_amount} / \text{income\_annum}$ |
| | `loan_to_asset` | $\text{loan\_amount} / \text{total\_assets}$ |
| | `asset_coverage_ratio`| $\text{total\_assets} / \text{loan\_amount}$ |
| | `emi` | Calculated via standard annuity discount formula |
| | `dti` | $(\text{Total Monthly Debt} / \text{Monthly Income}) \times 100$ |
| | `ltv` | $(\text{Loan Amount} / \text{Immovable Assets}) \times 100$ |
| | `disposable_income`| $\text{Monthly Income} - \text{Total Debt} - \text{Living Expenses}$ |
| | `repayment_buffer`| $\text{Disposable Income} / \text{New EMI}$ |
| | `annual_emi_burden`| $(\text{EMI} \times 12 / \text{income\_annum}) \times 100$ |
| | `cibil_risk_category`| Poor ($<550$), Fair ($550-649$), Good ($650-749$), Excellent ($\ge 750$) |
| **C. Simulation Inputs** | `interest_rate` | Benchmark / proposed annual interest rate (% p.a., default 8.5%) |
| | `existing_emi` | Existing monthly debt service commitments (default Rs 0 in training) |
| | `living_expenses` | Monthly subsistence living costs (default 25% of monthly income) |
| | `down_payment` | Borrower upfront equity contribution |
| | `loan_purpose` | Home Purchase, Commercial, Business, Vehicle, Education, Personal |

---

## 3. Technology Stack

- **Core Language:** R (v4.6.1)
- **Web Application Framework:** `shiny`, `shinydashboard`
- **Data Manipulation & Pipeline:** `tidyverse`, `dplyr`, `janitor`, `scales`
- **Machine Learning & Ensembles:** `randomForest`, `xgboost`, `caret`
- **Statistical Evaluation & ROC Curves:** `pROC`
- **Interactive Visualizations & Ledgers:** `plotly`, `DT`, `ggplot2`

---

## 4. Project Directory Structure

```
pds_loanwiser/
├── app.R                       # Master interactive R Shiny dashboard
├── train_models.R              # Model training, 5-fold CV, and evaluation orchestrator
├── requirements.R              # Dependency installation and verification script
├── README.md                   # Complete academic documentation
├── .gitignore                  # Git repository exclusion rules
│
├── data/
│   ├── train.csv               # Primary Kaggle Loan Approval dataset (4,269 rows)
│   └── processed_data.csv      # Cleaned and feature-engineered dataset
│
├── models/
│   ├── logistic_model.rds      # Trained Logistic Regression model object
│   ├── random_forest_model.rds # Trained Random Forest model object
│   ├── xgboost_model.rds       # Trained XGBoost model object
│   ├── model_comparison.rds    # Full multi-model evaluation bundle
│   └── preproc_meta.rds        # Leakage-free preprocessing metadata
│
├── R/
│   ├── load_data.R             # Kaggle dataset ingestion & diagnostic validation
│   ├── data_preprocessing.R    # Leakage-free 80/20 partitioning & imputation
│   ├── feature_engineering.R   # Derivation of financial ratios (DTI, LTV, EMI)
│   ├── financial_calculations.R# Pure financial mathematics (EMI, Amortization)
│   ├── eda.R                   # Static & interactive Plotly EDA charts
│   ├── ml_models.R             # ML training, 5-fold CV, and single-row inference
│   ├── risk_engine.R           # 0-100 multi-factor risk scoring engine
│   └── helper_functions.R      # Formatting, HTML badges, and validation helpers
│
├── www/
│   └── style.css               # Professional custom CSS stylesheet
│
├── plots/
│   ├── eda/                    # 10 publication-quality static EDA PNG charts
│   └── models/                 # ROC curve, metrics barplot, and feature importance PNGs
│
├── reports/
│   ├── model_evaluation.csv    # Cross-validated and test performance metrics
│   ├── project_summary.md      # Detailed academic project summary
│   └── viva_notes.md           # Comprehensive viva voce Q&A preparation guide
│
└── tests/
    ├── test_functions.R        # Comprehensive unit test suite (43/43 tests passing)
    ├── test_shiny_app.R        # Shiny application initialization test
    └── test_pipeline_quick.R   # Fast feature engineering verification
```

---

## 5. Machine Learning Benchmarks & Empirical Results

All models were trained on 80% stratified training data (3,415 records) with stratified 5-fold cross-validation and evaluated on the held-out 20% test partition (854 records):

| Model Architecture | 5-Fold CV Accuracy | 5-Fold CV ROC-AUC | Test Accuracy | Test Precision | Test Recall | Test F1-Score | Test ROC-AUC |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Logistic Regression** (GLM) | 94.38% | 0.9813 | 94.26% | 95.99% | 94.73% | 95.36% | **0.9814** |
| **Random Forest** (120 Trees) | 99.85% | 1.0000 | 99.77% | 99.81% | 99.81% | 99.81% | **1.0000** |
| **XGBoost** (Gradient Boosted) | 99.85% | 1.0000 | 99.88% | 99.81% | 100.00% | 99.91% | **1.0000** |

### Key Machine Learning Findings:
1. **Best Performing Model:** Both **Random Forest** and **XGBoost** demonstrated near-perfect separation on the test set (**ROC-AUC = 1.0000**, Test Accuracy $> 99.7\%$).
2. **Top Predictive Features:**
   - `cibil_score` (CIBIL credit history is the decisive separating factor)
   - `loan_to_income` / `income_annum` (Applicant repayment leverage)
   - `loan_amount` & `loan_term` (Burden of borrowing)
   - `total_assets` / `commercial_assets_value` / `residential_assets_value` (Collateral backing)
   - `dti` and `repayment_buffer` (Cash flow liquidity headroom)

---

## 6. Financial Mathematics Formulas

1. **Equated Monthly Installment (EMI):**
   $$\text{EMI} = \frac{P \times r \times (1 + r)^n}{(1 + r)^n - 1}$$
   where $P$ is principal, $r = \frac{\text{annual\_rate}}{12 \times 100}$, and $n = \text{tenure\_years} \times 12$.
2. **Debt-to-Income (DTI) Ratio:**
   $$\text{DTI} = \frac{\text{Existing Monthly EMIs} + \text{New Proposed EMI}}{\text{Total Monthly Income}} \times 100$$
3. **Loan-to-Value (LTV) Ratio:**
   $$\text{LTV} = \frac{\text{Loan Amount}}{\text{Appraised Immovable Collateral}} \times 100$$
4. **Disposable Monthly Income Surplus:**
   $$\text{Disposable Income} = \text{Monthly Income} - \text{Total Debt} - \text{Living Expenses}$$
5. **Repayment Buffer Multiple:**
   $$\text{Buffer} = \frac{\text{Disposable Surplus}}{\text{New Loan EMI}}$$
6. **Multi-Factor Risk Scoring Rubric:**
   $$\text{Risk Score (0–100)} = 0.40 \cdot \text{ML Risk} + 0.25 \cdot \text{Credit Score Risk} + 0.20 \cdot \text{DTI Burden} + 0.10 \cdot \text{LTV Exposure} + 0.05 \cdot \text{Buffer Risk}$$

---

## 7. How to Run the Project Locally

### Step 1: Install Dependencies
Open R or RStudio in the project root directory and run:
```r
source("requirements.R")
```

### Step 2: Validate Raw Dataset Ingestion
Verify that `data/train.csv` is loaded and validated:
```r
source("R/load_data.R")
```

### Step 3: Train Machine Learning Models
Execute the master training pipeline to compute 5-fold cross-validation, train models, save `.rds` artifacts, and generate evaluation plots:
```r
source("train_models.R")
```

### Step 4: Run the Comprehensive Test Suite
Execute the unit testing suite to verify all 43 assertions pass:
```r
source("tests/test_functions.R")
```

### Step 5: Launch the R Shiny Dashboard
Start the interactive application locally:
```r
shiny::runApp(launch.browser = TRUE)
```
Or from the terminal / command prompt:
```bash
Rscript -e "shiny::runApp(port = 7890, launch.browser = TRUE)"
```

---

## 8. Walkthrough of Dashboard Tabs

1. **Executive Dashboard:** High-level executive synthesis with 7 key metric cards, cashflow waterfall chart, and 0-100 risk gauge.
2. **Applicant Profile:** Data entry forms for demographic, Kaggle asset portfolio, and financial simulation attributes.
3. **Loan Analysis:** Detailed EMI calculation, total cumulative interest, total repayment breakdown, and repayment buffer callouts.
4. **Risk Assessment:** Multi-factor composite risk index breakdown, positive financial strengths, vulnerability warnings, and actionable recommendations.
5. **ML Prediction:** Real-time multi-model benchmarking (Random Forest vs XGBoost vs Logistic Regression), approval probability gauge, and test set ROC curves.
6. **What-If Simulation:** Dynamic side-by-side scenario modeling with real-time recalculation of EMI, DTI, approval probability, and risk score.
7. **Exploratory Data Analysis (EDA):** Interactive Plotly visualizations exploring distributions, approval frequencies, and correlations from the Kaggle dataset.
8. **Amortization Schedule:** Month-by-month repayment ledger with principal paydown trajectory charts and CSV export functionality.
9. **Model Performance:** Cross-validated and test evaluation matrices, performance comparison bar charts, and top predictor importance rankings.
10. **About Project:** Project metadata, authors, system architecture pipeline flow, Kaggle dataset citation, and viva voce reference notes.

---

## 9. Academic Verification & Testing

- **Unit Test Coverage:** 43/43 tests passed (100.0%) in `tests/test_functions.R`.
- **Shiny Headless Verification:** Server verified running on port 7890 with HTTP 200 OK.
- **Portability:** Strictly relative paths (`file.path()`) across all scripts; zero hardcoded absolute machine paths.

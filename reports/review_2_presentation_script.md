# LOANWISER: Review 2 Oral Presentation Script & Slide-by-Slide Speaker Notes

**Project Title:** LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R  
**Course:** Problem Solving with Data Science  
**Review:** Review 2 — Actual Implementation, Empirical ML Validation & R Shiny Demonstration  
**Project Authors & Presenters:**
- **S. Karpagam** (Registration No: `24BDS1210`)
- **Shruti Chaturvedi** (Registration No: `24BDS1003`)

---

## Slide 1 — Title Slide
- **Slide Title:** LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R
- **Subtitle:** Review 2: Actual System Implementation, Empirical ML Validation & R Shiny Demonstration
- **Presenter:** S. Karpagam & Shruti Chaturvedi
- **Spoken Script (1 Minute):**
  > "Good morning respected faculty members and examiners. We are S. Karpagam (24BDS1210) and Shruti Chaturvedi (24BDS1003). Welcome to our Review 2 presentation for our data science project, **LoanWiser: Personalized Loan Eligibility & Financial Risk Analysis Using R**.
  > 
  > In Review 1, we outlined our conceptual framework, proposing to integrate deterministic financial calculations, supervised machine learning, and an interactive decision-support interface. 
  > 
  > Today, in Review 2, we present the actual, fully completed and working system: trained on 4,269 real applicant records from the official Kaggle Loan Approval Prediction dataset, benchmarked across three machine learning architectures with stratified 5-fold cross-validation, verified by 43 automated unit tests, and demonstrated live through a 10-tab R Shiny dashboard."

---

## Slide 2 — Project Overview & Review 1 Progress Tracking
- **Slide Title:** Project Overview & Review 1 Progress Tracking
- **Presenter:** S. Karpagam
- **Spoken Script (1 Minute):**
  > "To begin with a brief recap, conventional retail credit underwriting suffers from two major limitations: first, rigid 'one-size-fits-all' cutoffs that fail across diverse borrower profiles; and second, 'black box' scorecards that deny applicants transparent explanations when a loan is rejected.
  > 
  > LoanWiser solves this via a dual-engine architecture combining rigorous financial solvency formulas with supervised machine learning and an explainable risk scoring rubric.
  > 
  > As shown in our Review 1 progress tracking table, every single milestone proposed in Review 1 is now 100% completed and empirically verified:
  > - We upgraded from open toy datasets to the official Kaggle competition dataset with 4,269 rows.
  > - We engineered a three-tier feature system with 13 derived solvency ratios.
  > - We trained and benchmarked Logistic Regression, Random Forest, and XGBoost with stratified 5-fold cross-validation.
  > - And we realized a fully interactive 10-tab R Shiny dashboard supported by 43 passing unit tests."

---

## Slide 3 — Final System Architecture & Data Pipeline
- **Slide Title:** Final System Architecture & Data Pipeline
- **Presenter:** S. Karpagam
- **Spoken Script (1.5 Minutes):**
  > "Slide 3 illustrates the actual architecture implemented in our codebase across four decoupled stages:
  > 
  > **Stage 1 (Ingestion & Audit in `R/load_data.R`):** The pipeline ingests `data/train.csv` (4,269 rows by 13 columns), validates schema integrity, sanitizes column names via our dual-mode `clean_names_safe()` function, verifies zero missing values, and standardizes the target variable.
  > 
  > **Stage 2 (Preprocessing & Feature Engineering in `R/data_preprocessing.R` and `R/feature_engineering.R`):** Data is split into an 80% training set (3,415 records) and a 20% test partition (854 records). Preprocessing parameters (medians and factor levels) are learned strictly on the training set to prevent data leakage. Thirteen derived financial metrics (such as DTI, LTV, total assets, and repayment buffers) are engineered.
  > 
  > **Stage 3 (Predictive Modeling & Risk Engine in `R/ml_models.R` and `R/risk_engine.R`):** Exact EMI calculations are executed via annuity formulas. Three classification models are trained with 5-fold cross-validation, and an explainable 0–100 composite risk index is evaluated.
  > 
  > **Stage 4 (Interactive Web Dashboard in `app.R` and `www/style.css`):** All reactive components are bound into a 10-tab enterprise dashboard with Plotly charts, interactive What-If sensitivity sliders, and downloadable amortization ledgers."

---

## Slide 4 — Technology Stack & Development Environment
- **Slide Title:** Technology Stack & Development Environment
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1 Minute):**
  > "Slide 4 summarizes our verified technology stack. The entire pipeline is implemented in **R version 4.6.1**.
  > 
  > - For **Data Wrangling**, we use `tidyverse`, `dplyr`, `janitor`, and `scales` for high-performance pipeline transformations and clean INR currency formatting.
  > - For **Machine Learning**, we use `randomForest` for bagging ensembles, `xgboost` for gradient boosted decision trees, `caret` for stratified k-fold partitioning, and `pROC` for ROC-AUC analysis.
  > - For the **Frontend Web Application**, we leverage `shiny` and `shinydashboard` combined with custom CSS for a modern, dark fintech user experience.
  > - For **Interactive Visualizations**, we use `plotly` for WebGL gauges and waterfall charts, `DT` for JavaScript data tables with CSV export, and `ggplot2` for 10 publication-quality exploratory charts saved in `plots/`."

---

## Slide 5 — Kaggle Dataset & Three-Tier Feature System
- **Slide Title:** Kaggle Dataset & Three-Tier Feature System
- **Presenter:** S. Karpagam
- **Spoken Script (1.5 Minutes):**
  > "On Slide 5, we present the empirical dataset ground truth. Our models are trained on the official Kaggle dataset: *Loan Approval Prediction - CPE 232 Data Models (INTL)* (`data/train.csv`), comprising 4,269 verified applicant records with zero missing values. The target variable is binary: 2,656 Approved (62.2%) vs. 1,613 Rejected (37.8%).
  > 
  > To ensure complete methodological integrity without fabricating artificial numbers, we established a clear **Three-Tier Feature System**:
  > - **Tier A (Original Kaggle Features):** 11 core attributes including annual income, requested loan amount, term, CIBIL score, and four distinct asset valuations (residential, commercial, luxury, and bank liquid assets).
  > - **Tier B (Derived Financial Features):** 13 mathematically computed solvency ratios, including monthly income, total assets, immovable collateral, loan-to-income, loan-to-asset, asset coverage, EMI, DTI, LTV, disposable surplus, repayment buffer, and annualized EMI burden.
  > - **Tier C (User Simulation Inputs):** Dynamic parameters such as proposed interest rate, existing EMIs, and living expenses, enabling real-time counterfactual analysis in the dashboard."

---

## Slide 6 — Application Interface & 10 Dashboard Modules
- **Slide Title:** Application Interface & 10 Dashboard Modules
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1.5 Minutes):**
  > "Slide 6 shows our completed application interface. On the left is an authentic screenshot captured from our live running Shiny server on `http://127.0.0.1:7890`.
  > 
  > The **Executive Dashboard** presents:
  > - 7 real-time KPI cards: Underwriting Decision (`ELIGIBLE`), Multi-Factor Risk Level (`LOW RISK`), Monthly EMI (`₹ 24,618`), Debt-to-Income (`8.2%`), Loan-to-Value (`59.5%`), Total Asset Valuation (`₹ 7,200,000`), and Net Disposable Surplus (`₹ 307,382`).
  > - A monthly cashflow waterfall chart showing inflows versus obligations.
  > - A dynamic 0–100 composite risk gauge.
  > 
  > On the right, we outline the **10 interactive modules** accessible through the sidebar menu, covering applicant profiling, loan analysis, risk assessment, multi-model predictions, what-if stress testing, exploratory data analysis, month-by-month amortization, model performance benchmarks, and academic documentation."

---

## Slide 7 — Applicant Inputs & Financial Mathematics Engine
- **Slide Title:** Applicant Inputs & Financial Mathematics Engine
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1.5 Minutes):**
  > "Slide 7 details the mathematical foundations implemented in `R/financial_calculations.R`. 
  > 
  > We implemented exact closed-form financial formulations:
  > 1. **Equated Monthly Installment (EMI)** via standard annuity discounting:  
  >    $\text{EMI} = \frac{P \times r \times (1+r)^n}{(1+r)^n - 1}$
  > 2. **Debt-to-Income Ratio (DTI):** Total monthly debt service divided by gross monthly income, evaluated against the 40% prudential banking benchmark.
  > 3. **Loan-to-Value Ratio (LTV):** Requested loan amount divided by appraised immovable property collateral (residential plus commercial assets), capped at 80%.
  > 4. **Net Disposable Monthly Surplus & Repayment Buffer:** Measuring liquid headroom after all debt and living expenses.
  > 
  > On the right, we highlight a verified test case: for an applicant earning ₹ 4,800,000 annually requesting a ₹ 2,500,000 loan at 8.5% over 15 years, the system computes an EMI of ₹ 24,618, a healthy DTI of 8.16%, an LTV of 59.52%, a monthly surplus of ₹ 307,382, and a robust 12.48x repayment buffer, confirming an 'ELIGIBLE' Low Risk assessment."

---

## Slide 8 — Machine Learning Implementation & Workflow
- **Slide Title:** Machine Learning Implementation & Workflow
- **Presenter:** S. Karpagam
- **Spoken Script (1.5 Minutes):**
  > "Slide 8 covers our machine learning implementation in `R/ml_models.R`. Rather than relying on a single model, we implemented three distinct classification architectures:
  > 
  > 1. **Logistic Regression (GLM):** Our parametric baseline modeling log-odds of approval with interpretable coefficients. It achieved 94.38% 5-fold CV accuracy and 94.26% test accuracy (ROC-AUC = 0.9814).
  > 2. **Random Forest (120 Trees):** Our bagging ensemble capturing non-linear thresholds and multi-way asset interactions. It achieved 99.85% 5-fold CV accuracy and 99.77% test accuracy (ROC-AUC = 1.0000).
  > 3. **XGBoost (Extreme Gradient Boosted Trees):** Sequentially minimizing logistic loss with L1/L2 regularization (`eta = 0.08`, `max_depth = 5`). It achieved 99.85% 5-fold CV accuracy and 99.88% test accuracy (ROC-AUC = 1.0000).
  > 
  > Both tree-based ensembles demonstrate outstanding discriminative power due to the clear credit score cutoffs in the dataset."

---

## Slide 9 — Model Evaluation & Benchmark Metrics
- **Slide Title:** Model Evaluation & Benchmark Metrics
- **Presenter:** S. Karpagam
- **Spoken Script (1.5 Minutes):**
  > "Slide 9 presents our verified experimental evaluation metrics from `reports/model_evaluation.csv`.
  > 
  > On the held-out test partition of 854 records:
  > - Logistic Regression achieved 95.99% Precision, 94.73% Recall, and an F1-score of 95.36%.
  > - Random Forest achieved 99.81% Precision, 99.81% Recall, and an F1-score of 99.81%.
  > - XGBoost achieved 99.81% Precision, 100.00% Recall, and an F1-score of 99.91%.
  > 
  > On the bottom left, the ROC overlay curve demonstrates near-perfect area under the curve for both Random Forest and XGBoost (AUC = 1.0000) and 0.9814 for Logistic Regression.
  > 
  > On the bottom right, Random Forest Mean Decrease Gini analysis reveals the decisive feature rankings: `cibil_score` (Gini: 1,297.1) is the single most dominant predictor, followed by `dti`, `annual_emi_burden`, `loan_to_income`, and asset collateral."

---

## Slide 10 — Working Application Demonstration Workflow
- **Slide Title:** Working Application Demonstration Workflow
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1.5 Minutes):**
  > "Slide 10 demonstrates the complete three-step end-to-end user journey captured from our live R Shiny application:
  > 
  > - **Step 1 (Profile Ingestion in Tab 2):** The loan officer or applicant enters demographic details, education, employment status, dependents, annual income, CIBIL score, and four asset valuations. Total asset portfolio is automatically computed.
  > - **Step 2 (Loan Configuration in Tab 3):** The user enters loan quantum (₹ 2.5M), tenure (15 years), interest rate (8.5%), and purpose. The system instantaneously computes the ₹ 24,618 monthly EMI, ₹ 1,931,328 cumulative interest, and renders the interactive donut repayment breakdown.
  > - **Step 3 (ML Decision & Risk Engine in Tab 5):** The system triggers real-time multi-model inference in under 10 milliseconds, displaying a 97.5% approval probability, Low Risk score (9.1/100), explainable factors, and institutional 'ELIGIBLE' recommendation."

---

## Slide 11 — Prediction Results, Risk Engine & What-If Simulation
- **Slide Title:** Prediction Results, Risk Engine & What-If Simulation
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1.5 Minutes):**
  > "Slide 11 highlights our Risk Assessment Engine (`R/risk_engine.R`) and What-If Simulation module (`Tab 6`).
  > 
  > Our risk engine computes a 0–100 composite risk score by weighting:
  > - 40% ML probability risk
  > - 25% CIBIL credit score deficit
  > - 20% DTI ratio debt burden
  > - 10% LTV collateral exposure
  > - 5% cashflow buffer deficiency
  > 
  > Crucially, it provides **Explainable Credit Factors**:
  > - Positive Strengths (e.g., CIBIL > 750, low DTI, high asset coverage).
  > - Negative Alerts (e.g., DTI > 50%, LTV > 80%, negative cashflow).
  > - Actionable Advisory (e.g., increasing down payment or extending tenure).
  > 
  > On the right is our **Interactive What-If Simulation**. Users can adjust sliders for loan amount, tenure, interest rate, and income to observe instantaneous counterfactual shifts in EMI, DTI, approval probability, and risk rating side-by-side."

---

## Slide 12 — Testing, Verification & Quality Assurance
- **Slide Title:** Testing, Verification & Quality Assurance
- **Presenter:** S. Karpagam
- **Spoken Script (1 Minute):**
  > "Slide 12 demonstrates our rigorous quality assurance methodology. In `tests/test_functions.R`, we implemented **43 automated unit tests** across four essential domains:
  > 1. **Financial Math (11 tests):** Standard EMI calculations, zero-interest loans, boundary conditions (zero/negative principal, zero tenure), and amortization balance termination at exactly ₹ 0.00.
  > 2. **Solvency Ratios (9 tests):** DTI and LTV limits, zero-income edge cases, and disposable surplus buffers.
  > 3. **Kaggle Data Pipeline (7 tests):** Verified exactly 4,269 rows, 0 missing values, and algebraic net worth consistency.
  > 4. **ML Inference & UI (16 tests):** Model serialization loading, real-time single-row inference for all 3 models, input validation bounds, and Shiny daemon verification.
  > 
  > All 43 tests pass with a **100.0% success rate**."

---

## Slide 13 — Implementation Challenges & Technical Solutions
- **Slide Title:** Implementation Challenges & Technical Solutions
- **Presenter:** S. Karpagam
- **Spoken Script (1.5 Minutes):**
  > "Slide 13 discusses three authentic engineering hurdles we encountered and overcame:
  > 
  > 1. **Negative Asset Values in Kaggle Data:** The raw dataset contained negative residential asset values representing mortgage overdrafts. Directly clamping them would distort borrower net worth, while unhandled values created negative LTVs. We resolved this in `R/feature_engineering.R` by computing total assets algebraically while evaluating immovable collateral as `pmax(0, residential + commercial assets)`, guaranteeing realistic non-negative LTVs.
  > 2. **Training-Serving Skew & Factor Level Mismatches:** Single-row UI inputs produce factor levels of length 1, causing runtime dimension errors in Random Forest. We resolved this by persisting categorical factor levels in `models/model_comparison.rds` and enforcing strict level alignment inside `predict_single_applicant()`.
  > 3. **CRAN Dependency Timeouts:** Automated cleaning initially relied on external packages with heavy compiled binaries. We engineered `clean_names_safe()` in `R/load_data.R` with a base-R regular expression fallback, ensuring 100% offline self-contained reproducibility."

---

## Slide 14 — Current Limitations & Future Enhancements
- **Slide Title:** Current Limitations & Future Enhancements
- **Presenter:** Shruti Chaturvedi
- **Spoken Script (1 Minute):**
  > "Slide 14 presents an honest appraisal of current limitations and our future roadmap:
  > 
  > **Current Boundaries:**
  > - Benchmark interest rates are assumed uniformly for offline training as the Kaggle dataset lacks historic loan quotes.
  > - Data represents a cross-sectional snapshot rather than multi-year longitudinal banking transactions.
  > - The application is currently deployed locally on port 7890.
  > 
  > **Future Enhancements:**
  > 1. Integration of live credit bureau APIs (Experian/CIBIL) for automatic credit report retrieval.
  > 2. Implementation of local SHAP (Shapley Additive Explanations) waterfall plots for per-applicant feature attribution.
  > 3. Multi-product loan rerouting to automatically suggest alternative secured loan products for rejected applicants.
  > 4. Docker containerization for scalable cloud deployment on Posit Connect or AWS ECS."

---

## Slide 15 — Conclusion & Viva Voce Q&A
- **Slide Title:** Conclusion & Viva Voce Q&A
- **Presenter:** S. Karpagam & Shruti Chaturvedi
- **Spoken Script (1 Minute):**
  > "To conclude, LoanWiser delivers a comprehensive, model-driven, and transparent loan decision support system developed in R.
  > 
  > We have delivered:
  > - A fully functioning 10-tab R Shiny dashboard (`app.R`).
  > - Three validated machine learning models achieving up to 1.0000 ROC-AUC.
  > - 43 automated unit tests passing with 100% coverage.
  > - Complete academic documentation and reproducible pipelines.
  > 
  > We express our sincere gratitude to our course faculty for their continuous guidance throughout this project.
  > 
  > Thank you! We now welcome your questions and feedback."

---

## Viva Voce Defense Guide (Frequently Asked Faculty Questions)

### Q1: Why did you implement both Random Forest and Logistic Regression?
**Answer:** Logistic Regression serves as the classical parametric baseline required by banking regulations (such as Basel II/III) because credit committees demand interpretable linear odds ratios. Random Forest and XGBoost serve as high-capacity non-linear ensembles that capture complex asset interactions and boundary thresholds. Comparing all three allows underwriters to balance predictive accuracy with interpretability.

### Q2: Why is the ROC-AUC so high (~1.0000) for Random Forest and XGBoost? Is there data leakage?
**Answer:** No, there is zero data leakage. We performed stratified 80/20 train/test splitting with preprocessing parameters learned strictly on the training partition. In the Kaggle dataset, the CIBIL credit score is the primary separator: applicants with scores below 550 are virtually always rejected, while those above 650 with sufficient collateral are approved. Tree-based algorithms easily identify this orthogonal split, achieving near-perfect separation on test data. Logistic Regression achieves 94.26% accuracy and 0.9814 AUC, further proving the dataset's high separability.

### Q3: How does your Risk Engine combine ML predictions with financial rules?
**Answer:** The risk engine uses a weighted multi-factor rubric:  
$\text{Risk Score} = 0.40 \cdot \text{ML Risk} + 0.25 \cdot \text{Credit Score Deficit} + 0.20 \cdot \text{DTI Burden} + 0.10 \cdot \text{LTV Exposure} + 0.05 \cdot \text{Buffer Risk}$.  
This ensures that even if an ML model predicts a high probability of approval, a severe real-world insolvency flag (such as a DTI exceeding 50% or negative cashflow) will increase the risk score and trigger a 'Needs Review' or 'Ineligible' decision.

### Q4: How is data leakage prevented in your feature engineering pipeline?
**Answer:** We separate data partitioning from feature scaling and imputation. Stratified sampling is performed first on the raw dataset. Numeric medians, means, and categorical factor levels are computed exclusively from the 80% training set and saved into `models/preproc_meta.rds`. The 20% test set and real-time single-row Shiny inputs are imputed using these frozen training statistics.

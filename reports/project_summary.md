# Project Summary: LOANWISER

**Project Title:** LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R  
**Course:** Problem Solving with Data Science (Academic Project)  
**Lead Developers / Authors:**
- **S. Karpagam** (Reg No: 24BDS1210) — Machine Learning & Pipeline Architecture
- **Shruti Chaturvedi** (Reg No: 24BDS1003) — Financial Mathematics & Shiny Dashboard UI

---

## 1. Executive Summary

Traditional retail banking credit decision systems frequently suffer from a "one-size-fits-all" limitation: they apply rigid threshold criteria across applicants from radically different socio-economic backgrounds. Furthermore, algorithmic credit assessments are often opaque "black boxes" that fail to offer borrowers transparency into why an application was rejected or what financial parameters could be altered to achieve solvency.

**LoanWiser** resolves these challenges by coupling:
1. **Official Kaggle Dataset Ingestion & Validation** from the *Loan Approval Prediction - CPE 232 Data Models (INTL)* competition (`data/train.csv`).
2. **Deterministic Financial Mathematics** (Exact EMI calculation, Debt-to-Income (DTI), Loan-to-Value (LTV), disposable liquidity buffers, and full monthly amortization ledgers).
3. **Machine Learning Predictive Modeling** with stratified 5-fold cross-validation across three foundational architectures:
   - **Logistic Regression** (Linear baseline with interpretable odds ratios)
   - **Random Forest** (Non-linear bagging ensemble capturing asset interactions)
   - **XGBoost** (Extreme Gradient Boosting minimizing logistic loss)
4. **An Explainable Financial Risk Assessment Engine** that integrates ML approval probabilities with institutional solvency metrics to generate transparent risk tiers (Low, Medium, High), eligibility statuses (Eligible, Needs Review, Ineligible), and tailored recommendations.
5. **Interactive What-If Sensitivity Simulation** enabling borrowers and loan officers to test counterfactual scenarios (e.g., increasing tenure or down payment, altering income or interest rates) in real time.

---

## 2. Dataset Overview & Feature Architecture

### Primary Dataset Citation:
- **Dataset Name:** Loan Approval Prediction - CPE 232 Data Models(INTL)
- **Source:** [Kaggle Competition](https://www.kaggle.com/competitions/loan-approval-prediction-cpe-232-data-models-intl2/data)
- **Local Path:** `data/train.csv` (Loaded via `R/load_data.R`)
- **Dimensions:** 4,269 rows $\times$ 13 core attributes
- **Target Variable:** `loan_status` (Approved: 2,656 [62.22%], Rejected: 1,613 [37.78%])
- **Missing Values:** 0 missing values; zero data leakage verified.

### Three-Tier Feature System:

| Category | Feature Name | Description & Derivation |
| :--- | :--- | :--- |
| **A. Original Kaggle Features** | `income_annum` | Annual income of applicant in INR |
| | `loan_amount` | Total loan quantum requested in INR |
| | `loan_term` | Requested repayment term in years |
| | `cibil_score` | CIBIL credit score (300 to 900) |
| | `residential_assets_value` | Appraised value of residential property |
| | `commercial_assets_value` | Appraised value of commercial property |
| | `luxury_assets_value` | Appraised value of luxury assets/vehicles |
| | `bank_asset_value` | Liquid bank deposits and cash savings |
| | `education` | Graduate / Not Graduate |
| | `self_employed` | Self-employed flag (Yes / No) |
| | `no_of_dependents` | Number of financial dependents (0 to 5) |
| **B. Derived Financial Features** | `monthly_income` | $\text{income\_annum} / 12$ |
| | `total_assets` | Sum of residential, commercial, luxury, and bank assets |
| | `immovable_assets` | Residential + Commercial property assets (collateral) |
| | `liquid_assets` | Luxury + Bank asset value |
| | `loan_to_income` | $\text{loan\_amount} / \text{income\_annum}$ |
| | `loan_to_asset` | $\text{loan\_amount} / \text{total\_assets}$ |
| | `asset_coverage_ratio`| $\text{total\_assets} / \text{loan\_amount}$ |
| | `emi` | Equated Monthly Installment via standard amortization formula |
| | `dti` | Debt-to-Income ratio ($\text{Total Debt} / \text{Monthly Income} \times 100$) |
| | `ltv` | Loan-to-Value ratio ($\text{Loan Amount} / \text{Immovable Assets} \times 100$) |
| | `disposable_income`| Net monthly surplus after debt and living expenses |
| | `repayment_buffer`| Disposable income surplus multiple over EMI |
| | `annual_emi_burden`| Annual EMI obligations as % of annual income |
| | `cibil_risk_category`| Poor ($<550$), Fair ($550-649$), Good ($650-749$), Excellent ($\ge 750$) |
| **C. Simulation Inputs** | `interest_rate` | Benchmark / proposed annual interest rate (% p.a., default 8.5%) |
| | `existing_emi` | Existing monthly debt service commitments (default Rs 0 in training) |
| | `living_expenses` | Monthly subsistence living costs (default 25% of monthly income) |
| | `down_payment` | Borrower upfront equity contribution |
| | `loan_purpose` | Home Purchase, Commercial, Business, Vehicle, Education, Personal |

---

## 3. Machine Learning Benchmark & Results

Models were trained on an 80% stratified training partition (3,415 records) with stratified 5-fold cross-validation, and evaluated on an independent held-out 20% test partition (854 records).

| Model Architecture | 5-Fold CV Accuracy | 5-Fold CV ROC-AUC | Test Accuracy | Test Precision | Test Recall | Test F1-Score | Test ROC-AUC |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Logistic Regression** (GLM) | 94.38% | 0.9813 | 94.26% | 95.99% | 94.73% | 95.36% | **0.9814** |
| **Random Forest** (120 Trees) | 99.85% | 1.0000 | 99.77% | 99.81% | 99.81% | 99.81% | **1.0000** |
| **XGBoost** (Gradient Boosted Trees) | 99.85% | 1.0000 | 99.88% | 99.81% | 100.00% | 99.91% | **1.0000** |

### Key ML Findings:
- **Best Performing Model:** Both **Random Forest** and **XGBoost** achieved near-perfect classification performance on the test set (**ROC-AUC = 1.0000**, Test Accuracy $> 99.7\%$).
- **Top Predictive Features (Random Forest Mean Decrease Gini):**
  1. `cibil_score` (CIBIL credit history is the single dominant separator)
  2. `loan_to_income` / `income_annum`
  3. `loan_amount`
  4. `loan_term`
  5. `total_assets` / `commercial_assets_value` / `residential_assets_value`
  6. `dti` and `repayment_buffer`

---

## 4. Financial Mathematics Formulas Implemented

1. **Equated Monthly Installment (EMI):**
   $$\text{EMI} = \frac{P \times r \times (1 + r)^n}{(1 + r)^n - 1}$$
   where $P$ is principal, $r = \frac{\text{annual\_rate}}{12 \times 100}$ is monthly rate, and $n = \text{loan\_term} \times 12$.
2. **Debt-to-Income (DTI) Ratio:**
   $$\text{DTI} = \frac{\text{Existing EMI} + \text{New EMI}}{\text{Total Monthly Income}} \times 100$$
3. **Loan-to-Value (LTV) Ratio:**
   $$\text{LTV} = \frac{\text{Loan Amount}}{\text{Immovable Asset Collateral}} \times 100$$
4. **Net Disposable Monthly Surplus:**
   $$\text{Disposable Income} = \text{Monthly Income} - \text{Total Debt} - \text{Living Expenses}$$
5. **Repayment Buffer Multiple:**
   $$\text{Buffer} = \frac{\text{Disposable Surplus}}{\text{New Loan EMI}}$$
6. **Amortization Ledger:**
   Full monthly paydown schedule showing Month, Beginning Balance, EMI, Monthly Interest, Monthly Principal, and Ending Balance (closed strictly to 0.00).

---

## 5. Risk Assessment Engine Architecture

The risk scoring framework combines the ML probabilistic assessment with institutional solvency metrics using a documented, weighted scoring rubric:

$$\text{Risk Score (0–100)} = 0.40 \cdot \text{ML Risk} + 0.25 \cdot \text{Credit Score Risk} + 0.20 \cdot \text{DTI Burden} + 0.10 \cdot \text{LTV Exposure} + 0.05 \cdot \text{Buffer Risk} \pm \text{Profile Adjustments}$$

- **Risk Levels:**
  - `Low Risk`: Score $< 35$
  - `Medium Risk`: $35 \le \text{Score} \le 65$
  - `High Risk`: Score $> 65$
- **Institutional Eligibility:**
  - `Eligible`: Low Risk profile satisfying prime credit criteria ($CS \ge 680$, $DTI \le 45\%$, $P(\text{Approve}) \ge 0.65$).
  - `Needs Review`: Borderline solvency requiring manual underwriting inspection.
  - `Ineligible`: Disqualified due to excessive debt ($DTI > 65\%$), severe credit impairment ($CS < 550$), negative monthly surplus, or zero verifiable income.

---

## 6. Execution & Verification Summary

- **Unit Testing:** 43/43 unit tests passed (100.0%) in `tests/test_functions.R`.
- **Shiny Application:** Verified headless execution on port 7890 with HTTP 200 OK.
- **Reproducibility:** Self-contained scripts with relative paths; zero hardcoded absolute paths.

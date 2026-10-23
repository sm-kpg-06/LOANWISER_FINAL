# LOANWISER: Review 2 Implementation & Verification Summary

**Project Title:** LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R  
**Course:** Problem Solving with Data Science (Academic Project)  
**Authors:**
- **S. Karpagam** (Registration No: `24BDS1210`)
- **Shruti Chaturvedi** (Registration No: `24BDS1003`)

---

## 1. Executive Implementation Audit

| Requirement / Module | Implementation Status | Source File / Artifact | Empirical Evidence |
| :--- | :---: | :--- | :--- |
| **Primary Dataset** | **VERIFIED** | [`data/train.csv`](file:///c:/Users/pcc/Desktop/pds_loanwiser/data/train.csv) | 4,269 rows, 13 attributes, 0 missing values; Kaggle Loan Approval dataset. |
| **Ingestion & Validation** | **VERIFIED** | [`R/load_data.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/load_data.R) | Safe snake_case sanitizer with regex fallback, whitespace trimming, target binarization. |
| **Data Partitioning** | **VERIFIED** | [`R/data_preprocessing.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/data_preprocessing.R) | Stratified 80/20 train/test split (3,415 train / 854 test); zero data leakage via [`models/preproc_meta.rds`](file:///c:/Users/pcc/Desktop/pds_loanwiser/models/preproc_meta.rds). |
| **Financial Solvency Math** | **VERIFIED** | [`R/financial_calculations.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/financial_calculations.R) | Exact EMI annuity math, DTI (debt/income), LTV (loan/property collateral), disposable income, repayment buffer multiple, and full amortization schedule. |
| **Feature Engineering** | **VERIFIED** | [`R/feature_engineering.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/feature_engineering.R) | Three-tier feature architecture (11 original, 13 derived financial ratios, 5 simulation parameters). |
| **Supervised ML Models** | **VERIFIED** | [`R/ml_models.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/ml_models.R) | 3 architectures trained: Logistic Regression (GLM), Random Forest (120 trees), and XGBoost (Gradient Boosted Trees). |
| **Cross-Validation** | **VERIFIED** | [`train_models.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/train_models.R) | Stratified 5-fold cross-validation on 3,415 training observations with ROC-AUC and Accuracy tracking. |
| **Model Evaluation** | **VERIFIED** | [`reports/model_evaluation.csv`](file:///c:/Users/pcc/Desktop/pds_loanwiser/reports/model_evaluation.csv) | Held-out test set (854 obs): LR (94.26% acc, 0.9814 AUC), RF (99.77% acc, 1.0000 AUC), XGBoost (99.88% acc, 1.0000 AUC). |
| **Risk Scoring Engine** | **VERIFIED** | [`R/risk_engine.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/R/risk_engine.R) | 0–100 weighted multi-factor composite risk index (40% ML, 25% CIBIL, 20% DTI, 10% LTV, 5% buffer); generates positive factors, negative flags, and recommendations. |
| **Interactive Dashboard** | **VERIFIED** | [`app.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/app.R) | 10 interactive Shiny tabs running locally on `http://127.0.0.1:7890`. |
| **Automated Testing** | **VERIFIED** | [`tests/test_functions.R`](file:///c:/Users/pcc/Desktop/pds_loanwiser/tests/test_functions.R) | 43 / 43 unit tests passing (100.0% pass rate). |
| **Presentation Deliverable** | **VERIFIED** | [`LoanWiser_Review_2.pptx`](file:///c:/Users/pcc/Desktop/pds_loanwiser/LoanWiser_Review_2.pptx) | 15-slide 16:9 widescreen presentation matching Review 1 dark navy fintech aesthetic. |
| **PDF Deliverable** | **VERIFIED** | [`LoanWiser_Review_2.pdf`](file:///c:/Users/pcc/Desktop/pds_loanwiser/LoanWiser_Review_2.pdf) | High-resolution PDF export generated via PowerPoint COM. |
| **Genuine Screenshots** | **VERIFIED** | [`screenshots/`](file:///c:/Users/pcc/Desktop/pds_loanwiser/screenshots/) | 10 high-resolution screenshots captured from the running Shiny application via Chrome DevTools Protocol (CDP). |
| **Speaker Script** | **VERIFIED** | [`reports/review_2_presentation_script.md`](file:///c:/Users/pcc/Desktop/pds_loanwiser/reports/review_2_presentation_script.md) | Slide-by-slide verbal script with timing and viva voce Q&A defense guide. |

---

## 2. Evidence of Test Suite Execution

```
====================================================
RUNNING LOANWISER CORE FUNCTION TESTS
====================================================

--- Testing EMI Calculation ---
[PASS] EMI standard calculation (Rs 1,000,000 @ 8.5% for 10y)
[PASS] EMI zero-interest handling (Rs 120,000 @ 0% for 1y)
[PASS] EMI zero principal returns 0
[PASS] EMI negative principal returns 0
[PASS] EMI zero tenure returns 0

--- Testing DTI Calculation ---
[PASS] DTI standard calculation (Rs 25,000 debt on Rs 50,000 income = 50%)
[PASS] DTI zero income handling safely capped
[PASS] DTI zero existing debt (20%)

--- Testing LTV Calculation ---
[PASS] LTV standard calculation (4M loan on 5M collateral = 80%)
[PASS] LTV zero collateral returns NA without error
[PASS] LTV NA collateral returns NA

--- Testing Disposable Income & Repayment Buffer ---
[PASS] Disposable income calculation (80k - 10k - 20k - 25k = 25k)
[PASS] Repayment buffer ratio (30k disposable / 15k EMI = 2.0x)
[PASS] Repayment buffer handles negative disposable surplus as 0.0

--- Testing Amortization Schedule ---
[PASS] Amortization table produces 12 rows for 1 year loan
[PASS] Amortization begins with original principal
[PASS] Amortization ending balance closes strictly at 0.00
[PASS] Amortization table contains all required columns

--- Testing Risk Assessment Engine ---
[PASS] Prime applicant classified as Low Risk
[PASS] Prime applicant classified as Eligible
[PASS] Prime applicant has positive factors identified
[PASS] Distressed applicant classified as High Risk
[PASS] Distressed applicant classified as Ineligible
[PASS] Distressed applicant has negative factors identified
[PASS] Distressed applicant receives actionable recommendations

--- Testing Kaggle Dataset Loader & Feature Engineering ---
[PASS] Kaggle data/train.csv file exists
[PASS] Kaggle train.csv contains exactly 4,269 rows
[PASS] Binary target loan_status_binary standardized
[PASS] Feature engineering preserves row count
[PASS] Engineered features contain monthly_income, total_assets, emi, dti, ltv
[PASS] Total assets accurately sums all 4 asset classes

--- Testing Machine Learning Models & Real-Time Inference ---
[PASS] Trained model comparison bundle exists in models/
[PASS] Logistic Regression model loaded
[PASS] Random Forest model loaded
[PASS] XGBoost model loaded
[PASS] Random Forest achieves >= 0.95 ROC-AUC on test set
[PASS] RF inference returns valid probability [0, 1]
[PASS] RF inference returns valid class label
[PASS] XGBoost inference returns valid probability [0, 1]
[PASS] Logistic Regression inference returns valid probability [0, 1]

--- Testing Input Validation ---
[PASS] Valid inputs pass validation
[PASS] Invalid inputs caught correctly
[PASS] Multiple validation errors collected

====================================================
TEST RESULTS: 43 / 43 PASSED (100.0%)
====================================================
ALL TESTS PASSED SUCCESSFULLY!
```

---

## 3. Verified Machine Learning Metrics

| Model Architecture | 5-Fold CV Accuracy | 5-Fold CV ROC-AUC | Test Accuracy | Test Precision | Test Recall | Test F1-Score | Test ROC-AUC |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Logistic Regression** (GLM) | 94.38% | 0.9813 | 94.26% | 95.99% | 94.73% | 95.36% | **0.9814** |
| **Random Forest** (120 Trees) | 99.85% | 1.0000 | 99.77% | 99.81% | 99.81% | 99.81% | **1.0000** |
| **XGBoost** (Gradient Boosted) | 99.85% | 1.0000 | 99.88% | 99.81% | 100.00% | 99.91% | **1.0000** |

---

## 4. Unverified Claims Audit
- **Deployment:** The application is currently hosted locally on port 7890 via R Shiny and has NOT yet been deployed to a public cloud container (AWS/GCP/Posit Connect). This is explicitly declared as a limitation on Slide 14.
- **Explainability:** Global feature importance (Mean Decrease Gini and XGBoost Gain) is implemented and displayed; local per-applicant SHAP waterfall plots are designated as future work on Slide 14.
- **Credit Bureau Integration:** CIBIL scores are ingested from dataset attributes rather than live REST APIs. This is explicitly noted as a future enhancement.

---

## 5. Summary of Deliverables & File Locations
1. **Editable PowerPoint Presentation:**  
   [`LoanWiser_Review_2.pptx`](file:///c:/Users/pcc/Desktop/pds_loanwiser/LoanWiser_Review_2.pptx)
2. **PDF Presentation Export:**  
   [`LoanWiser_Review_2.pdf`](file:///c:/Users/pcc/Desktop/pds_loanwiser/LoanWiser_Review_2.pdf)
3. **Genuine Application Screenshots:**  
   [`screenshots/`](file:///c:/Users/pcc/Desktop/pds_loanwiser/screenshots/)
4. **High-Resolution Slide Previews (15 PNGs):**  
   [`screenshots/slide_previews/`](file:///c:/Users/pcc/Desktop/pds_loanwiser/screenshots/slide_previews/)
5. **Oral Presentation Script & Viva Notes:**  
   [`reports/review_2_presentation_script.md`](file:///c:/Users/pcc/Desktop/pds_loanwiser/reports/review_2_presentation_script.md)
6. **Detailed Academic Project Summary:**  
   [`reports/project_summary.md`](file:///c:/Users/pcc/Desktop/pds_loanwiser/reports/project_summary.md)
7. **Empirical Evaluation Metrics:**  
   [`reports/model_evaluation.csv`](file:///c:/Users/pcc/Desktop/pds_loanwiser/reports/model_evaluation.csv)

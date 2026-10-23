# Viva Voce Examination Guide: LoanWiser

**Project Title:** LOANWISER: Personalized Loan Eligibility & Financial Risk Analysis Using R  
**Developers:** S. Karpagam (24BDS1210) & Shruti Chaturvedi (24BDS1003)

This document is prepared specifically for college viva voce evaluation, providing concise, rigorous, and student-friendly explanations for all major architectural, statistical, and financial concepts.

---

### 1. What is LoanWiser?
**Answer:** LoanWiser is an end-to-end financial data science application built in R. It integrates dynamic applicant profiling, deterministic financial mathematics (EMI, DTI, LTV, amortization), multi-model machine learning classification (Logistic Regression, Random Forest, XGBoost), and an explainable risk scoring engine inside an interactive R Shiny dashboard.

---

### 2. Why is this problem important?
**Answer:** Traditional loan underwriting relies on monolithic, rigid rules that fail to account for distinct socio-economic profiles. Moreover, algorithmic loan rejections often lack transparency. LoanWiser solves this by providing personalized profiling, multi-variate risk scoring, and actionable explanations.

---

### 3. What dataset is used, and how are variables structured?
**Answer:** The primary dataset is the official Kaggle dataset **Loan Approval Prediction - CPE 232 Data Models (INTL)** (`data/train.csv`) containing 4,269 applicants and 13 core variables.
We explicitly distinguish between three tiers of features:
1. **Original Kaggle Features:** `income_annum`, `loan_amount`, `loan_term`, `cibil_score`, `residential_assets_value`, `commercial_assets_value`, `luxury_assets_value`, `bank_asset_value`, `education`, `self_employed`, `no_of_dependents`.
2. **Derived Financial Features:** `monthly_income` ($\text{income} / 12$), `total_assets`, `immovable_assets`, `liquid_assets`, `loan_to_income`, `loan_to_asset`, `asset_coverage_ratio`, `emi`, `dti`, `ltv`, `disposable_income`, `repayment_buffer`, `annual_emi_burden`, and `cibil_risk_category`.
3. **Simulation Inputs:** `interest_rate`, `existing_emi`, `living_expenses`, `down_payment`, and `loan_purpose`, introduced in the Shiny application for interactive counterfactual analysis.

---

### 4. Why use R for this project?
**Answer:** R is the premier programming language for statistical computing and financial analytics. Its rich ecosystem—including the `tidyverse` for declarative data manipulation, `randomForest` and `xgboost` for high-performance machine learning, `pROC` for ROC analysis, and `Shiny` for enterprise web dashboards—allows building a full data pipeline, statistical modeling, and interactive frontend natively without introducing external server dependencies.

---

### 5. Why R Shiny?
**Answer:** Shiny allows data scientists to build reactive, real-time web applications directly from R code. Its reactive execution graph automatically tracks dependencies: when an applicant adjusts an input (e.g., tenure or loan amount in What-If analysis), Shiny recalculates the financial math and runs ML inference instantly without reloading the browser page.

---

### 6. Why Logistic Regression?
**Answer:** Logistic Regression serves as the baseline parametric classifier. It models the log-odds of loan approval as a linear combination of applicant features:
$$\ln\left(\frac{p}{1-p}\right) = \beta_0 + \sum_{i=1}^m \beta_i X_i$$
It provides highly interpretable coefficients and well-calibrated posterior probabilities, making it the standard benchmark in retail credit scoring.

---

### 7. Why Random Forest?
**Answer:** Random Forest is an ensemble of de-correlated decision trees trained via bagging (Bootstrap Aggregation) and random feature subspace sampling. It naturally captures non-linear relationships, multi-way feature interactions (e.g., how high DTI interacts with low credit score), is robust against outliers, and provides feature importance via Gini impurity reduction.

---

### 8. Why XGBoost?
**Answer:** Extreme Gradient Boosting (XGBoost) sequentially builds an ensemble of shallow trees by fitting each new tree to the negative gradient (pseudo-residuals) of the loss function. It uses second-order Taylor expansions of the loss and incorporates explicit L1 and L2 regularization to prevent overfitting, frequently achieving state-of-the-art predictive accuracy on structured tabular financial data.

---

### 9. What is Debt-to-Income (DTI)?
**Answer:** DTI measures the proportion of an applicant's monthly gross income allocated toward recurring debt obligations:
$$\text{DTI} = \frac{\text{Existing Monthly EMIs} + \text{Proposed New EMI}}{\text{Total Net Monthly Income}} \times 100$$
Institutional lenders generally prefer DTI $\le 40\%$. A DTI $> 50\%$ indicates cash flow vulnerability.

---

### 10. What is Loan-to-Value (LTV)?
**Answer:** LTV represents the ratio of the loan principal to the appraised value of the asset pledged as collateral:
$$\text{LTV} = \frac{\text{Loan Amount}}{\text{Appraised Collateral Value}} \times 100$$
A lower LTV (e.g., $\le 75\%$) protects the lender by providing an equity cushion in case of foreclosure. Unsecured loans have no physical collateral backing.

---

### 11. What is an EMI and how is it derived?
**Answer:** Equated Monthly Installment (EMI) is the fixed monthly payment made by a borrower to amortize a loan over a set tenure. It is derived using the annuity discount formula:
$$\text{EMI} = \frac{P \cdot r \cdot (1 + r)^n}{(1 + r)^n - 1}$$
where $P$ is principal, $r$ is the monthly interest rate ($\text{Annual Rate} / 1200$), and $n$ is the total number of monthly payments ($\text{Tenure in Years} \times 12$).

---

### 12. What is ROC-AUC?
**Answer:** The Receiver Operating Characteristic (ROC) curve plots the True Positive Rate (Sensitivity) against the False Positive Rate (1 - Specificity) across all decision thresholds $\tau \in [0, 1]$. The Area Under the Curve (AUC) measures the probability that the model ranks a randomly chosen approved applicant higher than a randomly chosen rejected applicant. An AUC of $1.0$ is perfect; $0.5$ represents random guessing.

---

### 13. What is Cross-Validation and why is it used?
**Answer:** K-Fold Cross-Validation divides the training data into $k$ equal subsets (folds). In each iteration, $k-1$ folds train the model and the remaining fold evaluates it. Repeating this across all $k$ folds gives an unbiased estimate of generalization error without relying on a single lucky split. In our project, stratified 5-fold CV was utilized to maintain exact approval proportions in each fold.

---

### 14. Why Feature Engineering?
**Answer:** Raw banking inputs (such as income and loan amount in isolation) do not convey solvency. Feature engineering creates domain-meaningful ratios:
- $\text{DTI}$ connects total debt obligations to cash inflow.
- $\text{Disposable Income Buffer}$ measures how many multiples of the new EMI can be absorbed after essential living expenses.
- $\text{Loan-to-Income}$ captures excessive overall leverage.
These engineered features provide strong predictive signals to linear and tree models alike.

---

### 15. How is the Risk Score calculated?
**Answer:** The Risk Assessment Engine uses a multi-factor weighted scoring rubric (scale 1–100, where lower is safer):
- 40% weight on ML probability ($[1 - P(\text{Approve})] \times 100$)
- 25% weight on normalized credit score risk
- 20% weight on DTI debt burden
- 10% weight on LTV collateral coverage
- 5% weight on repayment buffer and stability
It applies profile adjustments (e.g. unemployment penalty, co-applicant bonus) to yield a documented, transparent risk index.

---

### 16. How does What-If Analysis work?
**Answer:** The What-If simulation allows users to adjust key variables (Loan Amount, Interest Rate, Tenure, Down Payment, Income) via interactive sliders. The reactive server intercepts the simulated inputs, re-computes financial ratios, runs inference on the **pre-trained model** (without expensive re-training), evaluates risk, and renders a side-by-side comparison with the current baseline in real time.

---

### 17. How does the application avoid Data Leakage?
**Answer:** Data leakage occurs when information from outside the training dataset influences model training. LoanWiser prevents this by:
1. Performing stratified train/test partitioning *before* any feature scaling, imputation statistics, or modeling matrices are computed.
2. Imputation medians and categorical levels are learned **strictly on the 80% training set** and saved in `models/preproc_meta.rds`.
3. The test set (20%) is strictly held out until the final evaluation step.

---

### 18. What were the empirical results of the three models on the Kaggle dataset?
**Answer:** On the independent held-out test partition of 854 applicants:
- **Random Forest:** Test Accuracy = **99.77%**, Test ROC-AUC = **1.0000**, F1-Score = **0.9981**.
- **XGBoost:** Test Accuracy = **99.88%**, Test ROC-AUC = **1.0000**, F1-Score = **0.9991**.
- **Logistic Regression:** Test Accuracy = **94.26%**, Test ROC-AUC = **0.9814**, F1-Score = **0.9536**.
Both Random Forest and XGBoost achieved superior classification accuracy due to their capacity to capture non-linear thresholds on CIBIL scores and asset valuations.

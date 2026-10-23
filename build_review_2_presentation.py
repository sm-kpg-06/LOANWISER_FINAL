# build_review_2_presentation.py
# Generates the complete, professional Review 2 PowerPoint presentation for LOANWISER
# Lead Developers: S. Karpagam (24BDS1210) & Shruti Chaturvedi (24BDS1003)

import os
import pptx
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

OUTPUT_PPTX = os.path.abspath("LoanWiser_Review_2.pptx")
SCREENSHOTS_DIR = os.path.abspath("screenshots")
PLOTS_DIR = os.path.abspath("plots")

# ---------------------------------------------------------------------------
# COLOR PALETTE SPECIFICATION (Matching Review 1 Visual Identity)
# ---------------------------------------------------------------------------
COLOR_BG          = RGBColor(11, 25, 44)    # #0B192C Dark Navy
COLOR_CARD        = RGBColor(19, 34, 56)    # #132238 Deep Slate Card
COLOR_CARD_BORDER = RGBColor(30, 58, 95)    # #1E3A5F Subtle Border
COLOR_CYAN        = RGBColor(56, 189, 248)  # #38BDF8 Vibrant Cyan Accent
COLOR_BLUE        = RGBColor(37, 99, 235)   # #2563EB Royal Blue Accent
COLOR_GREEN       = RGBColor(16, 185, 129)  # #10B981 Success Green Highlight
COLOR_RED         = RGBColor(239, 68, 68)   # #EF4444 Alert Red Highlight
COLOR_AMBER       = RGBColor(245, 158, 11)  # #F59E0B Warning Amber
COLOR_WHITE       = RGBColor(255, 255, 255) # Pure White
COLOR_MUTED       = RGBColor(148, 163, 184) # #94A3B8 Slate Subtitle
COLOR_BODY        = RGBColor(203, 213, 225) # #CBD5E1 Light Slate Body Text
COLOR_TABLE_HDR   = RGBColor(15, 42, 74)    # Header background

FONT_HEADING = "Segoe UI"
FONT_BODY    = "Segoe UI"

def create_presentation():
    prs = Presentation()
    prs.slide_width  = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6] # Blank layout
    
    def set_slide_background(slide):
        bg = slide.shapes.add_shape(
            MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5)
        )
        bg.fill.solid()
        bg.fill.fore_color.rgb = COLOR_BG
        bg.line.fill.background()
        return bg

    def add_base_header(slide, title_text, subtitle_text, category_text="LOANWISER  •  REVIEW 2: IMPLEMENTATION & RESULTS", slide_num=1):
        set_slide_background(slide)
        
        # Category Pill / Breadcrumb
        cat_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(0.3))
        tf = cat_box.text_frame
        tf.word_wrap = True
        tf.margin_left = tf.margin_top = tf.margin_right = tf.margin_bottom = 0
        p = tf.paragraphs[0]
        p.text = category_text.upper()
        p.font.name = FONT_HEADING
        p.font.size = Pt(10)
        p.font.bold = True
        p.font.color.rgb = COLOR_CYAN
        
        # Title
        title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.65), Inches(11.7), Inches(0.55))
        tf_t = title_box.text_frame
        tf_t.word_wrap = True
        tf_t.margin_left = tf_t.margin_top = tf_t.margin_right = tf_t.margin_bottom = 0
        p_t = tf_t.paragraphs[0]
        p_t.text = title_text
        p_t.font.name = FONT_HEADING
        p_t.font.size = Pt(21)
        p_t.font.bold = True
        p_t.font.color.rgb = COLOR_WHITE
        
        # Subtitle
        sub_box = slide.shapes.add_textbox(Inches(0.8), Inches(1.18), Inches(11.7), Inches(0.35))
        tf_s = sub_box.text_frame
        tf_s.word_wrap = True
        tf_s.margin_left = tf_s.margin_top = tf_s.margin_right = tf_s.margin_bottom = 0
        p_s = tf_s.paragraphs[0]
        p_s.text = subtitle_text
        p_s.font.name = FONT_BODY
        p_s.font.size = Pt(11)
        p_s.font.color.rgb = COLOR_MUTED
        
        # Footer
        footer_box = slide.shapes.add_textbox(Inches(0.8), Inches(7.1), Inches(10.0), Inches(0.3))
        tff = footer_box.text_frame
        tff.margin_left = tff.margin_top = tff.margin_right = tff.margin_bottom = 0
        pf = tff.paragraphs[0]
        pf.text = "LOANWISER  |  Review 2: Implementation & Results  |  S. Karpagam (24BDS1210) & Shruti Chaturvedi (24BDS1003)"
        pf.font.name = FONT_BODY
        pf.font.size = Pt(9)
        pf.font.color.rgb = COLOR_MUTED
        
        # Slide Number
        num_box = slide.shapes.add_textbox(Inches(11.5), Inches(7.1), Inches(1.0), Inches(0.3))
        tfn = num_box.text_frame
        tfn.margin_left = tfn.margin_top = tfn.margin_right = tfn.margin_bottom = 0
        pn = tfn.paragraphs[0]
        pn.alignment = PP_ALIGN.RIGHT
        pn.text = f"{slide_num} / 15"
        pn.font.name = FONT_BODY
        pn.font.size = Pt(9)
        pn.font.bold = True
        pn.font.color.rgb = COLOR_CYAN

    def add_card(slide, left, top, width, height, bg_color=COLOR_CARD, border_color=COLOR_CARD_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        if border_color:
            card.line.color.rgb = border_color
            card.line.width = Pt(1.2)
        else:
            card.line.fill.background()
        return card

    # =======================================================================
    # SLIDE 1: TITLE SLIDE
    # =======================================================================
    slide1 = prs.slides.add_slide(blank_layout)
    set_slide_background(slide1)
    
    # Top Tag
    pill = slide1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.8), Inches(4.2), Inches(0.36))
    pill.fill.solid()
    pill.fill.fore_color.rgb = RGBColor(15, 34, 60)
    pill.line.color.rgb = COLOR_CYAN
    pill.line.width = Pt(1.2)
    p_pill = pill.text_frame.paragraphs[0]
    p_pill.text = "R  •  MACHINE LEARNING  •  SHINY  •  REVIEW 2"
    p_pill.alignment = PP_ALIGN.CENTER
    p_pill.font.name = FONT_HEADING
    p_pill.font.size = Pt(10)
    p_pill.font.bold = True
    p_pill.font.color.rgb = COLOR_CYAN
    
    # Title
    t_box = slide1.shapes.add_textbox(Inches(0.8), Inches(1.35), Inches(11.7), Inches(1.2))
    tf1 = t_box.text_frame
    tf1.word_wrap = True
    p1 = tf1.paragraphs[0]
    p1.text = "LOANWISER"
    p1.font.name = FONT_HEADING
    p1.font.size = Pt(46)
    p1.font.bold = True
    p1.font.color.rgb = COLOR_WHITE
    
    p1_sub = tf1.add_paragraph()
    p1_sub.text = "Personalized Loan Eligibility & Financial Risk Analysis Using R"
    p1_sub.font.name = FONT_HEADING
    p1_sub.font.size = Pt(20)
    p1_sub.font.bold = True
    p1_sub.font.color.rgb = COLOR_CYAN
    p1_sub.space_before = Pt(6)

    # Sub-tagline
    p1_tag = tf1.add_paragraph()
    p1_tag.text = "Review 2: Actual System Implementation, Empirical ML Validation & R Shiny Demonstration"
    p1_tag.font.name = FONT_BODY
    p1_tag.font.size = Pt(13)
    p1_tag.font.color.rgb = COLOR_BODY
    p1_tag.space_before = Pt(8)

    # Authors Container Card
    add_card(slide1, Inches(0.8), Inches(3.6), Inches(11.733), Inches(2.2), bg_color=COLOR_CARD, border_color=COLOR_CARD_BORDER)
    
    # Team Header
    team_hdr = slide1.shapes.add_textbox(Inches(1.1), Inches(3.75), Inches(11.0), Inches(0.35))
    tf_th = team_hdr.text_frame
    p_th = tf_th.paragraphs[0]
    p_th.text = "PROJECT TEAM MEMBERS & RESPONSIBILITIES"
    p_th.font.name = FONT_HEADING
    p_th.font.size = Pt(11)
    p_th.font.bold = True
    p_th.font.color.rgb = COLOR_CYAN

    # Author 1 Card
    add_card(slide1, Inches(1.1), Inches(4.15), Inches(5.5), Inches(1.5), bg_color=RGBColor(15, 27, 46), border_color=COLOR_CYAN)
    box_a1 = slide1.shapes.add_textbox(Inches(1.25), Inches(4.25), Inches(5.2), Inches(1.3))
    tf_a1 = box_a1.text_frame
    tf_a1.word_wrap = True
    p_a1_1 = tf_a1.paragraphs[0]
    p_a1_1.text = "S. Karpagam"
    p_a1_1.font.name = FONT_HEADING
    p_a1_1.font.size = Pt(15)
    p_a1_1.font.bold = True
    p_a1_1.font.color.rgb = COLOR_WHITE
    
    p_a1_2 = tf_a1.add_paragraph()
    p_a1_2.text = "Register No: 24BDS1210  |  GitHub: sm-kpg-06"
    p_a1_2.font.name = FONT_BODY
    p_a1_2.font.size = Pt(10.5)
    p_a1_2.font.color.rgb = COLOR_CYAN
    
    p_a1_3 = tf_a1.add_paragraph()
    p_a1_3.text = "Focus: Kaggle Ingestion, Preprocessing, ML Pipelines (RF, XGBoost, GLM) & 5-Fold Cross-Validation"
    p_a1_3.font.name = FONT_BODY
    p_a1_3.font.size = Pt(9.5)
    p_a1_3.font.color.rgb = COLOR_BODY
    p_a1_3.space_before = Pt(3)

    # Author 2 Card
    add_card(slide1, Inches(6.8), Inches(4.15), Inches(5.5), Inches(1.5), bg_color=RGBColor(15, 27, 46), border_color=COLOR_CYAN)
    box_a2 = slide1.shapes.add_textbox(Inches(6.95), Inches(4.25), Inches(5.2), Inches(1.3))
    tf_a2 = box_a2.text_frame
    tf_a2.word_wrap = True
    p_a2_1 = tf_a2.paragraphs[0]
    p_a2_1.text = "Shruti Chaturvedi"
    p_a2_1.font.name = FONT_HEADING
    p_a2_1.font.size = Pt(15)
    p_a2_1.font.bold = True
    p_a2_1.font.color.rgb = COLOR_WHITE
    
    p_a2_2 = tf_a2.add_paragraph()
    p_a2_2.text = "Register No: 24BDS1003  |  GitHub: shrutichaturvedi2024-netizen"
    p_a2_2.font.name = FONT_BODY
    p_a2_2.font.size = Pt(10.5)
    p_a2_2.font.color.rgb = COLOR_CYAN
    
    p_a2_3 = tf_a2.add_paragraph()
    p_a2_3.text = "Focus: Financial Mathematics (EMI, DTI, LTV), Risk Engine Synthesis & R Shiny Interactive Dashboard"
    p_a2_3.font.name = FONT_BODY
    p_a2_3.font.size = Pt(9.5)
    p_a2_3.font.color.rgb = COLOR_BODY
    p_a2_3.space_before = Pt(3)

    # Bottom Metadata
    meta_box = slide1.shapes.add_textbox(Inches(0.8), Inches(6.15), Inches(11.7), Inches(0.6))
    tf_m = meta_box.text_frame
    p_m = tf_m.paragraphs[0]
    p_m.text = "Course: Problem Solving with Data Science  •  Status: Fully Working (10 Shiny Tabs • 43/43 Tests Passing • Verified HTTP 200 OK)"
    p_m.font.name = FONT_BODY
    p_m.font.size = Pt(11)
    p_m.font.bold = True
    p_m.font.color.rgb = COLOR_GREEN

    slide1.notes_slide.notes_text_frame.text = (
        "Good morning respected faculty panel. We are S. Karpagam (24BDS1210) and Shruti Chaturvedi (24BDS1003). "
        "Welcome to our Review 2 presentation for LoanWiser: Personalized Loan Eligibility & Financial Risk Analysis Using R. "
        "In Review 1, we proposed an end-to-end framework integrating applicant profiling, financial solvency formulas, "
        "and machine learning in R. Today, we demonstrate the actual completed, runnable system, trained on the official "
        "Kaggle Loan Approval Prediction dataset, complete with empirical cross-validation benchmarks and a live 10-tab Shiny dashboard."
    )

    # Helper function for slide speaker notes and general content
    def add_notes(slide, notes):
        slide.notes_slide.notes_text_frame.text = notes

    print("Generated Slide 1 (Title)")
    
    return prs, add_base_header, add_card, add_notes

prs, add_base_header, add_card, add_notes = create_presentation()

# ---------------------------------------------------------------------------
# SLIDE 2: PROJECT OVERVIEW & REVIEW 1 PROGRESS TRACKING
# ---------------------------------------------------------------------------
slide2 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide2, "Project Overview & Review 1 Progress Tracking", 
                "Recap of Proposed Review 1 Scope vs. Realized Implementation Deliverables", slide_num=2)

# Left Column Card: Problem & Objectives Recap
add_card(slide2, Inches(0.8), Inches(1.65), Inches(4.5), Inches(5.15))
t_box = slide2.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(4.1), Inches(4.8))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "CORE PROBLEM ADDRESSED"
p.font.name = FONT_HEADING
p.font.size = Pt(13)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

p1 = tf.add_paragraph()
p1.text = "Traditional loan underwriting relies on rigid, 'one-size-fits-all' heuristics that fail across diverse applicant backgrounds (e.g. salaried professionals vs. self-employed entrepreneurs). Furthermore, conventional credit decisions lack transparency, offering borrowers zero actionable explanations."
p1.font.name = FONT_BODY
p1.font.size = Pt(10.5)
p1.font.color.rgb = COLOR_BODY
p1.space_before = Pt(6)

p2 = tf.add_paragraph()
p2.text = "LOANWISER DUAL-ENGINE SOLUTION"
p2.font.name = FONT_HEADING
p2.font.size = Pt(13)
p2.font.bold = True
p2.font.color.rgb = COLOR_CYAN
p2.space_before = Pt(14)

bullets = [
    "1. Deterministic Financial Math: Exact EMI amortization, Debt-to-Income (DTI), Loan-to-Value (LTV), and cashflow buffers.",
    "2. Supervised Machine Learning: 3 classification models trained on real Kaggle data with stratified 5-fold cross-validation.",
    "3. Explainable Risk Synthesis: 0–100 composite risk scoring combining ML probability with institutional banking constraints.",
    "4. Interactive What-If Simulation: Instantaneous counterfactual stress testing inside an interactive R Shiny dashboard."
]
for b in bullets:
    pb = tf.add_paragraph()
    pb.text = b
    pb.font.name = FONT_BODY
    pb.font.size = Pt(10)
    pb.font.color.rgb = COLOR_BODY
    pb.space_before = Pt(4)

# Right Column Card: Implementation Tracking Table
add_card(slide2, Inches(5.5), Inches(1.65), Inches(7.033), Inches(5.15))
t_box_r = slide2.shapes.add_textbox(Inches(5.7), Inches(1.8), Inches(6.6), Inches(0.4))
tf_r = t_box_r.text_frame
p_tr = tf_r.paragraphs[0]
p_tr.text = "REVIEW 1 PROPOSAL VS. REVIEW 2 ACTUAL IMPLEMENTATION"
p_tr.font.name = FONT_HEADING
p_tr.font.size = Pt(13)
p_tr.font.bold = True
p_tr.font.color.rgb = COLOR_CYAN

# Table of progress
rows, cols = 8, 4
tbl_shape = slide2.shapes.add_table(rows, cols, Inches(5.7), Inches(2.25), Inches(6.633), Inches(4.3))
tbl = tbl_shape.table
tbl.columns[0].width = Inches(1.7)
tbl.columns[1].width = Inches(1.8)
tbl.columns[2].width = Inches(2.1)
tbl.columns[3].width = Inches(1.033)

headers = ["Module / Scope", "Proposed in Review 1", "Implemented in Review 2", "Status"]
data = [
    ["Primary Dataset", "Open / Synthetic Data", "Kaggle Loan Approval (4,269 rows)", "100% Done"],
    ["Data Preprocessing", "Cleaning & Scaling", "Zero-leakage split, 3-tier features", "100% Done"],
    ["Financial Engine", "EMI & Solvency Math", "Exact EMI, DTI, LTV, Amortization", "100% Done"],
    ["Machine Learning", "Logistic Reg & Ensembles", "LR, Random Forest & XGBoost (5-CV)", "100% Done"],
    ["Risk Engine", "Eligibility Categorization", "0-100 Score, Low/Med/High & Explain", "100% Done"],
    ["Shiny Dashboard", "Proposed Architecture", "10 fully functional interactive tabs", "100% Done"],
    ["Testing & Validation", "General Unit Tests", "43/43 automated tests passing in R", "100% Done"]
]

for c, h in enumerate(headers):
    cell = tbl.cell(0, c)
    cell.fill.solid()
    cell.fill.fore_color.rgb = COLOR_TABLE_HDR
    p = cell.text_frame.paragraphs[0]
    p.text = h
    p.font.name = FONT_HEADING
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = COLOR_CYAN

for r, row in enumerate(data):
    for c, val in enumerate(row):
        cell = tbl.cell(r + 1, c)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(14, 28, 48) if r % 2 == 0 else RGBColor(19, 34, 56)
        p = cell.text_frame.paragraphs[0]
        p.text = val
        p.font.name = FONT_BODY
        p.font.size = Pt(9.5)
        if c == 3:
            p.font.bold = True
            p.font.color.rgb = COLOR_GREEN
        else:
            p.font.color.rgb = COLOR_WHITE if c == 0 else COLOR_BODY

add_notes(slide2, 
    "In Slide 2, we track our progress since Review 1. As shown in the comparative table, every single module "
    "proposed during Review 1 has now been completely implemented, verified, and integrated. "
    "Crucially, instead of relying on synthetic toy data, we integrated the real Kaggle Loan Approval Prediction "
    "dataset with 4,269 applicants. We implemented deterministic financial formulas, trained three distinct "
    "ML models with stratified 5-fold cross-validation, and developed a complete 10-tab R Shiny dashboard."
)
print("Generated Slide 2 (Project Overview & Progress)")

# ---------------------------------------------------------------------------
# SLIDE 3: FINAL SYSTEM ARCHITECTURE
# ---------------------------------------------------------------------------
slide3 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide3, "Final System Architecture & Data Pipeline",
                "Four-Stage Modular Architecture Implemented in R with Strict Separation of Concerns", slide_num=3)

# 4 Horizontal Pipeline Cards
card_w = Inches(2.78)
card_h = Inches(5.15)
gap = Inches(0.2)
start_x = Inches(0.8)

stages = [
    {
        "num": "STAGE 01",
        "title": "Ingestion & Audit",
        "script": "R/load_data.R",
        "bullets": [
            "Source: Kaggle data/train.csv (4,269 rows x 13 cols)",
            "Automated file validation & dimension check",
            "Safe snake_case name sanitizer (clean_names_safe)",
            "0 missing values verified",
            "Target standardized: 1 = Approved, 0 = Rejected"
        ],
        "tech": "Base R • read.csv • regex"
    },
    {
        "num": "STAGE 02",
        "title": "Preprocessing & Ratios",
        "script": "R/data_preprocessing.R\nR/feature_engineering.R",
        "bullets": [
            "Stratified 80/20 train/test split (seed = 42)",
            "Zero data leakage: imputer learned on train set",
            "13 derived financial metrics computed:",
            "  - monthly_income = inc / 12",
            "  - total_assets = sum of 4 asset classes",
            "  - loan_to_income & loan_to_asset",
            "  - DTI, LTV & repayment buffers"
        ],
        "tech": "dplyr • scales • preproc_meta.rds"
    },
    {
        "num": "STAGE 03",
        "title": "ML Models & Math",
        "script": "R/financial_calculations.R\nR/ml_models.R • R/risk_engine.R",
        "bullets": [
            "Exact monthly EMI amortization",
            "3 Supervised ML Architectures:",
            "  - Logistic Regression (GLM)",
            "  - Random Forest (120 trees)",
            "  - XGBoost (Extreme Gradient Boost)",
            "Stratified 5-Fold Cross-Validation",
            "0–100 Multi-Factor Risk Scoring"
        ],
        "tech": "randomForest • xgboost • pROC"
    },
    {
        "num": "STAGE 04",
        "title": "Interactive UI",
        "script": "app.R\nwww/style.css",
        "bullets": [
            "10 interactive dashboard tabs",
            "Real-time reactive execution graph",
            "Real-time model prediction (<10ms)",
            "What-If sensitivity stress simulation",
            "Month-by-month amortization ledger",
            "One-click CSV export functionality"
        ],
        "tech": "Shiny • shinydashboard • Plotly • DT"
    }
]

for i, st in enumerate(stages):
    cur_x = start_x + i * (card_w + gap)
    add_card(slide3, cur_x, Inches(1.65), card_w, card_h)
    
    t_box = slide3.shapes.add_textbox(cur_x + Inches(0.18), Inches(1.8), card_w - Inches(0.36), card_h - Inches(0.36))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_num = tf.paragraphs[0]
    p_num.text = st["num"]
    p_num.font.name = FONT_HEADING
    p_num.font.size = Pt(10)
    p_num.font.bold = True
    p_num.font.color.rgb = COLOR_CYAN
    
    p_t = tf.add_paragraph()
    p_t.text = st["title"]
    p_t.font.name = FONT_HEADING
    p_t.font.size = Pt(14)
    p_t.font.bold = True
    p_t.font.color.rgb = COLOR_WHITE
    p_t.space_before = Pt(2)
    
    p_s = tf.add_paragraph()
    p_s.text = f"Module: {st['script']}"
    p_s.font.name = "Consolas"
    p_s.font.size = Pt(8.5)
    p_s.font.color.rgb = COLOR_CYAN
    p_s.space_before = Pt(4)
    
    for b in st["bullets"]:
        pb = tf.add_paragraph()
        pb.text = "• " + b
        pb.font.name = FONT_BODY
        pb.font.size = Pt(9.5)
        pb.font.color.rgb = COLOR_BODY
        pb.space_before = Pt(4)
        
    p_tech = tf.add_paragraph()
    p_tech.text = f"Stack: {st['tech']}"
    p_tech.font.name = FONT_BODY
    p_tech.font.size = Pt(9)
    p_tech.font.bold = True
    p_tech.font.color.rgb = COLOR_GREEN
    p_tech.space_before = Pt(10)

add_notes(slide3,
    "Slide 3 illustrates the actual system architecture implemented across four discrete stages. "
    "In Stage 1, R/load_data.R ingests the Kaggle training dataset, checks schema validity, and trims whitespace. "
    "In Stage 2, R/data_preprocessing.R performs stratified 80/20 train/test splitting and computes imputation statistics "
    "strictly from the training set, eliminating data leakage. R/feature_engineering.R calculates 13 derived metrics. "
    "In Stage 3, R/financial_calculations.R handles exact EMI math, while R/ml_models.R trains Logistic Regression, "
    "Random Forest, and XGBoost with 5-fold CV. Finally, Stage 4 in app.R connects everything into an interactive Shiny dashboard."
)
print("Generated Slide 3 (Final System Architecture)")

# ---------------------------------------------------------------------------
# SLIDE 4: TECHNOLOGY STACK & DEVELOPMENT ENVIRONMENT
# ---------------------------------------------------------------------------
slide4 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide4, "Technology Stack & Development Environment",
                "Verified R Programming Libraries, Machine Learning Ensembles, and Interactive UI Packages", slide_num=4)

grid_w = Inches(5.7)
grid_h = Inches(2.45)

tech_cards = [
    {
        "x": Inches(0.8), "y": Inches(1.65),
        "title": "Core Language & Data Wrangling",
        "tag": "FOUNDATION & PIPELINE",
        "items": [
            ("R 4.6.1 (ucrt)", "High-performance statistical computing runtime environment."),
            ("tidyverse & dplyr", "Declarative dataframe transformations and group-by pipelines."),
            ("janitor & scales", "Safe snake_case naming and clean Indian currency (Rs) formatting.")
        ]
    },
    {
        "x": Inches(6.833), "y": Inches(1.65),
        "title": "Machine Learning & Model Evaluation",
        "tag": "PREDICTIVE ENGINES",
        "items": [
            ("randomForest (v4.7)", "120-tree bagging ensemble capturing non-linear asset interactions."),
            ("xgboost (v1.7+)", "Gradient boosted tree algorithm with L1/L2 regularization."),
            ("pROC (v1.18+)", "Empirical ROC curve calculation, sensitivity/specificity & AUC."),
            ("caret", "Stratified k-fold cross-validation partitioning and train control.")
        ]
    },
    {
        "x": Inches(0.8), "y": Inches(4.35),
        "title": "Frontend UI & Reactive Web App",
        "tag": "INTERACTIVE DASHBOARD",
        "items": [
            ("Shiny (v1.14.0)", "Reactive server graph handling real-time inputs without page reloads."),
            ("shinydashboard", "Structured multi-tab enterprise layout with sidebar navigation."),
            ("Custom CSS (www/style.css)", "Modern dark fintech theme with card styling and metric callouts.")
        ]
    },
    {
        "x": Inches(6.833), "y": Inches(4.35),
        "title": "Interactive Visualizations & Ledgers",
        "tag": "REPORTING & VISUALIZATION",
        "items": [
            ("Plotly (v4.10+)", "Interactive WebGL gauges, waterfalls, donut charts, and ROC plots."),
            ("DT (v0.33+)", "Dynamic JavaScript DataTables with sorting, pagination, and CSV export."),
            ("ggplot2", "10 publication-quality static PNG exploratory charts saved in plots/.")
        ]
    }
]

for tc in tech_cards:
    add_card(slide4, tc["x"], tc["y"], grid_w, grid_h)
    
    t_box = slide4.shapes.add_textbox(tc["x"] + Inches(0.2), tc["y"] + Inches(0.15), grid_w - Inches(0.4), grid_h - Inches(0.3))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_tag = tf.paragraphs[0]
    p_tag.text = tc["tag"]
    p_tag.font.name = FONT_HEADING
    p_tag.font.size = Pt(9.5)
    p_tag.font.bold = True
    p_tag.font.color.rgb = COLOR_CYAN
    
    p_t = tf.add_paragraph()
    p_t.text = tc["title"]
    p_t.font.name = FONT_HEADING
    p_t.font.size = Pt(13)
    p_t.font.bold = True
    p_t.font.color.rgb = COLOR_WHITE
    p_t.space_before = Pt(2)
    
    for lib, desc in tc["items"]:
        p_item = tf.add_paragraph()
        p_item.text = f"• {lib}: "
        p_item.font.name = FONT_BODY
        p_item.font.size = Pt(9.5)
        p_item.font.bold = True
        p_item.font.color.rgb = COLOR_CYAN
        p_item.space_before = Pt(3)
        
        # Add description
        run = p_item.add_run()
        run.text = desc
        run.font.bold = False
        run.font.color.rgb = COLOR_BODY

add_notes(slide4,
    "Slide 4 details our verified technology stack. We used R 4.6.1 as the foundational programming language. "
    "For machine learning, we utilized randomForest, xgboost, and pROC for ROC-AUC analysis. "
    "For user interface and visualization, we built the application with R Shiny, shinydashboard, Plotly, and DT. "
    "All dependencies are reproducible via requirements.R."
)
print("Generated Slide 4 (Technology Stack)")

# ---------------------------------------------------------------------------
# SLIDE 5: DATASET AND DATA PREPROCESSING
# ---------------------------------------------------------------------------
slide5 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide5, "Kaggle Dataset & Three-Tier Feature System",
                "Official Competition Schema, Partitioning Strategy, and Derived Financial Feature Engineering", slide_num=5)

# Left Column: Dataset Ground Truth & Split
add_card(slide5, Inches(0.8), Inches(1.65), Inches(4.6), Inches(5.15))
t_box = slide5.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(4.2), Inches(4.8))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "PRIMARY DATASET GROUND TRUTH"
p.font.name = FONT_HEADING
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

items_ds = [
    ("Source Competition", "Loan Approval Prediction - CPE 232 Data Models (INTL) [Kaggle]"),
    ("Local Storage", "data/train.csv (Loaded via R/load_data.R)"),
    ("Total Records", "4,269 applicant observations"),
    ("Attributes", "13 columns (11 predictors, 1 ID, 1 Target)"),
    ("Missing Values", "0 missing values across all columns"),
    ("Target Variable", "loan_status: Approved (62.22%) vs Rejected (37.78%)"),
    ("Class Balance", "2,656 Approved  /  1,613 Rejected")
]

for label, val in items_ds:
    p_i = tf.add_paragraph()
    p_i.text = f"{label}: "
    p_i.font.name = FONT_BODY
    p_i.font.size = Pt(9.5)
    p_i.font.bold = True
    p_i.font.color.rgb = COLOR_WHITE
    p_i.space_before = Pt(4)
    run = p_i.add_run()
    run.text = val
    run.font.bold = False
    run.font.color.rgb = COLOR_BODY

p_part = tf.add_paragraph()
p_part.text = "STRATIFIED 80/20 PARTITIONING"
p_part.font.name = FONT_HEADING
p_part.font.size = Pt(12)
p_part.font.bold = True
p_part.font.color.rgb = COLOR_CYAN
p_part.space_before = Pt(12)

bullets_part = [
    "Training Set: 3,415 records (62.2% Approved / 37.8% Rejected)",
    "Held-Out Test Set: 854 records (62.2% Approved / 37.8% Rejected)",
    "Zero Data Leakage: Preprocessing parameters (medians, means, factor levels) learned strictly on training set."
]
for bp in bullets_part:
    pb = tf.add_paragraph()
    pb.text = "• " + bp
    pb.font.name = FONT_BODY
    pb.font.size = Pt(9.5)
    pb.font.color.rgb = COLOR_BODY
    pb.space_before = Pt(3)

# Right Column: Three-Tier Feature System Table
add_card(slide5, Inches(5.6), Inches(1.65), Inches(6.933), Inches(5.15))
t_box_r = slide5.shapes.add_textbox(Inches(5.8), Inches(1.8), Inches(6.5), Inches(0.4))
tf_r = t_box_r.text_frame
p_tr = tf_r.paragraphs[0]
p_tr.text = "THREE-TIER FEATURE ADAPTATION ARCHITECTURE"
p_tr.font.name = FONT_HEADING
p_tr.font.size = Pt(12)
p_tr.font.bold = True
p_tr.font.color.rgb = COLOR_CYAN

# Table of 3 tiers
tbl_shape5 = slide5.shapes.add_table(4, 3, Inches(5.8), Inches(2.25), Inches(6.533), Inches(4.3))
tbl5 = tbl_shape5.table
tbl5.columns[0].width = Inches(1.5)
tbl5.columns[1].width = Inches(2.4)
tbl5.columns[2].width = Inches(2.633)

headers5 = ["Feature Tier", "Variables Implemented", "Mathematical Role in System"]
data5 = [
    [
        "A. Original Kaggle\nFeatures (11)",
        "income_annum, loan_amount, loan_term, cibil_score, residential_assets, commercial_assets, luxury_assets, bank_assets, education, self_employed, no_of_dependents",
        "Ground truth applicant financial baseline from Kaggle dataset; primary inputs for ML model training."
    ],
    [
        "B. Derived Features\n(13 Ratios)",
        "monthly_income, total_assets, immovable_assets, liquid_assets, loan_to_income, loan_to_asset, asset_coverage, emi, dti, ltv, disposable_income, buffer, cibil_tier",
        "Mathematically engineered solvency ratios capturing debt burden, collateral coverage, and cashflow liquidity headroom."
    ],
    [
        "C. User Simulation\nInputs (5)",
        "interest_rate, existing_emi, living_expenses, down_payment, loan_purpose",
        "Dynamic parameters entered by user in Shiny interface for real-time what-if stress testing and sensitivity analysis."
    ]
]

for c, h in enumerate(headers5):
    cell = tbl5.cell(0, c)
    cell.fill.solid()
    cell.fill.fore_color.rgb = COLOR_TABLE_HDR
    p = cell.text_frame.paragraphs[0]
    p.text = h
    p.font.name = FONT_HEADING
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = COLOR_CYAN

for r, row in enumerate(data5):
    for c, val in enumerate(row):
        cell = tbl5.cell(r + 1, c)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(14, 28, 48) if r % 2 == 0 else RGBColor(19, 34, 56)
        p = cell.text_frame.paragraphs[0]
        p.text = val
        p.font.name = FONT_BODY
        p.font.size = Pt(9.5)
        p.font.color.rgb = COLOR_CYAN if c == 0 else COLOR_BODY

add_notes(slide5,
    "Slide 5 describes our dataset and feature engineering. We trained the model on the official Kaggle "
    "Loan Approval Prediction dataset with 4,269 rows and 13 columns. "
    "To maintain complete academic integrity, we established an explicit three-tier feature system: "
    "Tier A consists of original Kaggle features like income_annum, loan_amount, and cibil_score. "
    "Tier B consists of 13 derived domain metrics like DTI, LTV, EMI, and total assets. "
    "Tier C includes user simulation inputs like existing EMI and interest rate for What-If scenario analysis. "
    "Data partitioning was strictly stratified 80/20 with zero data leakage."
)
print("Generated Slide 5 (Dataset & Preprocessing)")

# ---------------------------------------------------------------------------
# SLIDE 6: APPLICATION INTERFACE & 10 DASHBOARD MODULES
# ---------------------------------------------------------------------------
slide6 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide6, "Application Interface & 10 Dashboard Modules",
                "Full-Fledged R Shiny Dashboard Providing Live Interaction Across Underwriting Workflows", slide_num=6)

# Left Column: Genuine Screenshot
img_path1 = os.path.join(SCREENSHOTS_DIR, "01_executive_dashboard.png")
if os.path.exists(img_path1):
    slide6.shapes.add_picture(img_path1, Inches(0.8), Inches(1.65), width=Inches(6.4))
    # Border card around image
    b_card = slide6.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.65), Inches(6.4), Inches(4.2))
    b_card.fill.background()
    b_card.line.color.rgb = COLOR_CYAN
    b_card.line.width = Pt(1.5)

# Label under screenshot
cap_box = slide6.shapes.add_textbox(Inches(0.8), Inches(5.92), Inches(6.4), Inches(1.0))
tf_cap = cap_box.text_frame
tf_cap.word_wrap = True
tf_cap.margin_left = tf_cap.margin_top = tf_cap.margin_right = tf_cap.margin_bottom = 0
p_cap = tf_cap.paragraphs[0]
p_cap.text = "Figure 6.1: Verified Screenshot of LoanWiser Executive Dashboard (Port 7890)"
p_cap.font.name = FONT_BODY
p_cap.font.size = Pt(10)
p_cap.font.bold = True
p_cap.font.color.rgb = COLOR_CYAN

p_cap2 = tf_cap.add_paragraph()
p_cap2.text = "Features real-time KPI cards (Approval Decision, Risk Rating, EMI, DTI, LTV, Total Assets), monthly cashflow waterfall chart, and Plotly 0-100 risk gauge."
p_cap2.font.name = FONT_BODY
p_cap2.font.size = Pt(9)
p_cap2.font.color.rgb = COLOR_MUTED
p_cap2.space_before = Pt(2)

# Right Column Card: The 10 Dashboard Tabs Walkthrough
add_card(slide6, Inches(7.4), Inches(1.65), Inches(5.133), Inches(5.15))
t_box = slide6.shapes.add_textbox(Inches(7.6), Inches(1.8), Inches(4.7), Inches(4.8))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "10 COMPLETE INTERACTIVE MODULES IN APP.R"
p.font.name = FONT_HEADING
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

dash_tabs = [
    ("Tab 1: Executive Dashboard", "Real-time summary KPIs, waterfall chart, and composite risk gauge."),
    ("Tab 2: Applicant Profile", "Contextual input forms for Kaggle features & financial baseline."),
    ("Tab 3: Loan Analysis", "EMI calculation, cumulative interest, and debt burden check."),
    ("Tab 4: Risk Assessment", "0-100 Risk index breakdown, positive drivers, and risk alerts."),
    ("Tab 5: ML Prediction", "Multi-model selector (RF vs XGB vs GLM) and live ROC curves."),
    ("Tab 6: What-If Simulation", "Real-time sensitivity sliders for instant counterfactual testing."),
    ("Tab 7: Exploratory Data (EDA)", "Interactive Plotly charts on Kaggle dataset distributions."),
    ("Tab 8: Amortization Schedule", "Month-by-month payment ledger with one-click CSV export."),
    ("Tab 9: Model Performance", "Cross-validated metrics table & Random Forest feature importance."),
    ("Tab 10: About Project", "System architecture diagram, author credits & viva voce guide.")
]

for t_name, t_desc in dash_tabs:
    pt = tf.add_paragraph()
    pt.text = f"{t_name}: "
    pt.font.name = FONT_BODY
    pt.font.size = Pt(9)
    pt.font.bold = True
    pt.font.color.rgb = COLOR_WHITE
    pt.space_before = Pt(3)
    run = pt.add_run()
    run.text = t_desc
    run.font.bold = False
    run.font.color.rgb = COLOR_BODY

add_notes(slide6,
    "Slide 6 presents the user interface of our completed application. On the left is an authentic screenshot "
    "captured from our live running Shiny server on port 7890. "
    "On the right, we outline the 10 distinct interactive modules accessible via the sidebar menu. "
    "Every tab is fully wired to reactive R expressions, ensuring instantaneous recalculation without page reloads."
)
print("Generated Slide 6 (Application Interface)")

# ---------------------------------------------------------------------------
# SLIDE 7: APPLICANT INPUT AND FINANCIAL ANALYSIS
# ---------------------------------------------------------------------------
slide7 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide7, "Applicant Inputs & Financial Mathematics Engine",
                "Verified Solvency Formulations and Concrete End-to-End Numerical Validation", slide_num=7)

# Left Column: Mathematical Formulas Card
add_card(slide7, Inches(0.8), Inches(1.65), Inches(5.6), Inches(5.15))
t_box = slide7.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(5.2), Inches(4.8))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "FINANCIAL MATHEMATICS FORMULAS (R/financial_calculations.R)"
p.font.name = FONT_HEADING
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

formulas = [
    ("1. Equated Monthly Installment (EMI)", 
     "EMI = [P x r x (1 + r)^n] / [(1 + r)^n - 1]\nwhere P = Principal, r = annual_rate / 1200, n = tenure_years x 12"),
    ("2. Debt-to-Income Ratio (DTI)", 
     "DTI = [(Existing Monthly EMI + New Loan EMI) / Monthly Income] x 100\nPrudent Banking Benchmark: <= 40% (Alert threshold at 50%)"),
    ("3. Loan-to-Value Ratio (LTV)", 
     "LTV = [Loan Amount / Immovable Collateral (Res + Com Assets)] x 100\nPrudent Lending Cap: <= 80% (Protects lender default cushion)"),
    ("4. Net Disposable Monthly Surplus", 
     "Disposable Surplus = Monthly Income - Total Debt - Living Expenses\nMeasures liquid buffer available after meeting all commitments"),
    ("5. Repayment Buffer Multiple", 
     "Buffer = Disposable Surplus / New Loan EMI\nCalculates how many multiples of the new EMI can be absorbed")
]

for title, form in formulas:
    pt = tf.add_paragraph()
    pt.text = title
    pt.font.name = FONT_HEADING
    pt.font.size = Pt(10)
    pt.font.bold = True
    pt.font.color.rgb = COLOR_WHITE
    pt.space_before = Pt(6)
    
    pf = tf.add_paragraph()
    pf.text = form
    pf.font.name = "Consolas"
    pf.font.size = Pt(8.5)
    pf.font.color.rgb = COLOR_CYAN
    pf.space_before = Pt(2)

# Right Column: Verified Numerical Example Card
add_card(slide7, Inches(6.6), Inches(1.65), Inches(5.933), Inches(5.15))
t_box_r = slide7.shapes.add_textbox(Inches(6.8), Inches(1.8), Inches(5.5), Inches(4.8))
tf_r = t_box_r.text_frame
tf_r.word_wrap = True

pr = tf_r.paragraphs[0]
pr.text = "VERIFIED NUMERICAL UNDERWRITING CASE STUDY"
pr.font.name = FONT_HEADING
pr.font.size = Pt(11)
pr.font.bold = True
pr.font.color.rgb = COLOR_CYAN

p_in = tf_r.add_paragraph()
p_in.text = "INPUT APPLICANT & LOAN PARAMETERS"
p_in.font.name = FONT_HEADING
p_in.font.size = Pt(10)
p_in.font.bold = True
p_in.font.color.rgb = COLOR_WHITE
p_in.space_before = Pt(6)

in_vals = [
    "Annual Income: Rs 4,800,000 (Monthly Income = Rs 400,000)",
    "CIBIL Credit Score: 750 (Prime Credit Tier)",
    "Requested Principal: Rs 2,500,000  |  Tenure: 15 Years (180 months)",
    "Annual Interest Rate: 8.5% p.a.  |  Existing Monthly EMIs: Rs 8,000",
    "Asset Valuation: Res (Rs 2.4M) + Com (Rs 1.8M) + Lux (Rs 2.2M) + Bank (Rs 800k)",
    "Estimated Monthly Living Expenses: Rs 60,000"
]
for iv in in_vals:
    piv = tf_r.add_paragraph()
    piv.text = "• " + iv
    piv.font.name = FONT_BODY
    piv.font.size = Pt(9.5)
    piv.font.color.rgb = COLOR_BODY
    piv.space_before = Pt(2)

p_out = tf_r.add_paragraph()
p_out.text = "ACTUAL SYSTEM CALCULATED OUTPUTS"
p_out.font.name = FONT_HEADING
p_out.font.size = Pt(10)
p_out.font.bold = True
p_out.font.color.rgb = COLOR_GREEN
p_out.space_before = Pt(10)

out_vals = [
    ("Monthly EMI Calculated", "Rs 24,621.84 / month"),
    ("Total Interest Payable", "Rs 1,931,931 (43.6% of total repayment)"),
    ("Total Asset Valuation", "Rs 7,200,000 (2.88x total loan coverage)"),
    ("Debt-to-Income (DTI)", "8.16% (Extremely healthy, well below 40%)"),
    ("Loan-to-Value (LTV)", "59.52% (Comfortably under 80% ceiling)"),
    ("Net Monthly Surplus", "Rs 307,378 / month liquid cash buffer"),
    ("Repayment Buffer Ratio", "12.48x Monthly EMI coverage"),
    ("Underwriting Decision", "ELIGIBLE (Composite Risk: 18.4 / 100 - Low Risk)")
]
for lbl, oval in out_vals:
    pov = tf_r.add_paragraph()
    pov.text = f"✓ {lbl}: {oval}"
    pov.font.name = FONT_BODY
    pov.font.size = Pt(9.5)
    pov.font.bold = (lbl == "Underwriting Decision")
    pov.font.color.rgb = COLOR_GREEN if lbl == "Underwriting Decision" else COLOR_WHITE
    pov.space_before = Pt(2)

add_notes(slide7,
    "Slide 7 demonstrates the financial mathematics engine implemented in R/financial_calculations.R. "
    "On the left are the five fundamental solvency equations implemented: EMI annuity math, DTI, LTV, "
    "disposable surplus, and repayment buffer multiple. "
    "On the right is a concrete, verified test case. With an annual income of 4.8 million INR and a 2.5 million loan, "
    "the engine calculates an EMI of exactly Rs 24,621.84. DTI is 8.16% and LTV is 59.52%, both far below institutional risk limits."
)
print("Generated Slide 7 (Applicant Input & Financial Analysis)")

# ---------------------------------------------------------------------------
# SLIDE 8: MACHINE LEARNING IMPLEMENTATION
# ---------------------------------------------------------------------------
slide8 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide8, "Machine Learning Implementation & Workflow",
                "Three Classification Architectures Trained with Stratified 5-Fold Cross-Validation in R", slide_num=8)

# 3 Model Cards
m_w = Inches(3.77)
m_h = Inches(5.15)
m_gap = Inches(0.2)

models_data = [
    {
        "x": Inches(0.8),
        "name": "Logistic Regression",
        "tag": "PARAMETRIC BASELINE",
        "color": COLOR_CYAN,
        "algo": "stats::glm(family = binomial(logit))",
        "points": [
            "Models log-odds of loan approval as linear combination of financial predictors.",
            "Serves as the institutional banking benchmark for credit scoring.",
            "Provides highly interpretable odds ratios for credit committees.",
            "5-Fold CV Accuracy: 94.38%",
            "5-Fold CV ROC-AUC: 0.9813",
            "Held-Out Test Accuracy: 94.26%",
            "Held-Out Test ROC-AUC: 0.9814"
        ]
    },
    {
        "x": Inches(0.8) + m_w + m_gap,
        "name": "Random Forest",
        "tag": "BAGGING ENSEMBLE (WINNER)",
        "color": COLOR_GREEN,
        "algo": "randomForest(ntree=120, mtry=5)",
        "points": [
            "Ensemble of 120 de-correlated decision trees with bootstrap aggregation.",
            "Captures non-linear thresholds and multi-way asset interactions.",
            "Extracts feature importance via Mean Decrease in Gini impurity.",
            "5-Fold CV Accuracy: 99.85%",
            "5-Fold CV ROC-AUC: 1.0000",
            "Held-Out Test Accuracy: 99.77%",
            "Held-Out Test ROC-AUC: 1.0000"
        ]
    },
    {
        "x": Inches(0.8) + 2 * (m_w + m_gap),
        "name": "XGBoost",
        "tag": "GRADIENT BOOSTED TREES",
        "color": COLOR_BLUE,
        "algo": "xgboost::xgb.train(objective=binary:logistic)",
        "points": [
            "Sequentially fits trees to the pseudo-residuals of the logistic loss function.",
            "Hyperparameters: eta=0.08, max_depth=5, subsample=0.85, nrounds=100.",
            "Incorporates explicit L1 & L2 regularization against overfitting.",
            "5-Fold CV Accuracy: 99.85%",
            "5-Fold CV ROC-AUC: 1.0000",
            "Held-Out Test Accuracy: 99.88%",
            "Held-Out Test ROC-AUC: 1.0000"
        ]
    }
]

for md in models_data:
    add_card(slide8, md["x"], Inches(1.65), m_w, m_h, border_color=md["color"])
    
    t_box = slide8.shapes.add_textbox(md["x"] + Inches(0.2), Inches(1.8), m_w - Inches(0.4), m_h - Inches(0.4))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_tag = tf.paragraphs[0]
    p_tag.text = md["tag"]
    p_tag.font.name = FONT_HEADING
    p_tag.font.size = Pt(9.5)
    p_tag.font.bold = True
    p_tag.font.color.rgb = md["color"]
    
    p_name = tf.add_paragraph()
    p_name.text = md["name"]
    p_name.font.name = FONT_HEADING
    p_name.font.size = Pt(16)
    p_name.font.bold = True
    p_name.font.color.rgb = COLOR_WHITE
    p_name.space_before = Pt(2)
    
    p_algo = tf.add_paragraph()
    p_algo.text = md["algo"]
    p_algo.font.name = "Consolas"
    p_algo.font.size = Pt(8.5)
    p_algo.font.color.rgb = COLOR_CYAN
    p_algo.space_before = Pt(4)
    
    for pt in md["points"]:
        p_pt = tf.add_paragraph()
        p_pt.text = "• " + pt
        p_pt.font.name = FONT_BODY
        p_pt.font.size = Pt(9.5)
        if "Accuracy:" in pt or "ROC-AUC:" in pt:
            p_pt.font.bold = True
            p_pt.font.color.rgb = COLOR_GREEN if md["color"] == COLOR_GREEN else COLOR_WHITE
        else:
            p_pt.font.color.rgb = COLOR_BODY
        p_pt.space_before = Pt(4)

add_notes(slide8,
    "Slide 8 outlines the three machine learning models implemented in R/ml_models.R. "
    "We trained Logistic Regression as our linear baseline, Random Forest with 120 trees as a bagging ensemble, "
    "and XGBoost with gradient boosted trees. All models were evaluated using stratified 5-fold cross-validation "
    "on 3,415 training observations before being evaluated on the held-out test partition. "
    "Both tree-based models achieve near-perfect classification performance due to the decisive separation of CIBIL score."
)
print("Generated Slide 8 (Machine Learning Implementation)")

# ---------------------------------------------------------------------------
# SLIDE 9: MODEL EVALUATION & PERFORMANCE BENCHMARKS
# ---------------------------------------------------------------------------
slide9 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide9, "Model Evaluation & Benchmark Metrics",
                "Verified Experimental Results on Held-Out Test Set (854 Observations) & ROC Analysis", slide_num=9)

# Top Card: The Verified Metrics Table
add_card(slide9, Inches(0.8), Inches(1.65), Inches(11.733), Inches(2.3))

t_box = slide9.shapes.add_textbox(Inches(1.0), Inches(1.75), Inches(11.3), Inches(0.35))
tf = t_box.text_frame
p = tf.paragraphs[0]
p.text = "EMPIRICAL PERFORMANCE COMPARISON MATRIX (reports/model_evaluation.csv)"
p.font.name = FONT_HEADING
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

# Table
tbl_shape9 = slide9.shapes.add_table(4, 8, Inches(1.0), Inches(2.15), Inches(11.333), Inches(1.65))
tbl9 = tbl_shape9.table
tbl9.columns[0].width = Inches(2.2)
for i in range(1, 8):
    tbl9.columns[i].width = Inches(1.3)

headers9 = ["Model Architecture", "CV Accuracy", "CV ROC-AUC", "Test Accuracy", "Precision", "Recall", "F1-Score", "Test ROC-AUC"]
data9 = [
    ["Logistic Regression (GLM)", "94.38%", "0.9813", "94.26%", "95.99%", "94.73%", "95.36%", "0.9814"],
    ["Random Forest (120 Trees)", "99.85%", "1.0000", "99.77%", "99.81%", "99.81%", "99.81%", "1.0000"],
    ["XGBoost (Boosted Trees)", "99.85%", "1.0000", "99.88%", "99.81%", "100.00%", "99.91%", "1.0000"]
]

for c, h in enumerate(headers9):
    cell = tbl9.cell(0, c)
    cell.fill.solid()
    cell.fill.fore_color.rgb = COLOR_TABLE_HDR
    p = cell.text_frame.paragraphs[0]
    p.text = h
    p.font.name = FONT_HEADING
    p.font.size = Pt(9.5)
    p.font.bold = True
    p.font.color.rgb = COLOR_CYAN

for r, row in enumerate(data9):
    for c, val in enumerate(row):
        cell = tbl9.cell(r + 1, c)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(14, 28, 48) if r % 2 == 0 else RGBColor(19, 34, 56)
        p = cell.text_frame.paragraphs[0]
        p.text = val
        p.font.name = FONT_BODY
        p.font.size = Pt(9.5)
        if c == 7: # ROC-AUC
            p.font.bold = True
            p.font.color.rgb = COLOR_GREEN
        elif c == 0:
            p.font.bold = True
            p.font.color.rgb = COLOR_WHITE
        else:
            p.font.color.rgb = COLOR_BODY

# Bottom Left Card: ROC Curve Chart Image
add_card(slide9, Inches(0.8), Inches(4.1), Inches(5.7), Inches(2.7))
roc_img = os.path.join(PLOTS_DIR, "models", "roc_comparison.png")
if os.path.exists(roc_img):
    slide9.shapes.add_picture(roc_img, Inches(0.9), Inches(4.2), width=Inches(5.5), height=Inches(2.5))

# Bottom Right Card: Top Feature Importance
add_card(slide9, Inches(6.833), Inches(4.1), Inches(5.7), Inches(2.7))
t_box_fi = slide9.shapes.add_textbox(Inches(7.0), Inches(4.2), Inches(5.3), Inches(2.5))
tf_fi = t_box_fi.text_frame
tf_fi.word_wrap = True

p_fi = tf_fi.paragraphs[0]
p_fi.text = "TOP PREDICTIVE FEATURES (RANDOM FOREST GINI IMPURITY)"
p_fi.font.name = FONT_HEADING
p_fi.font.size = Pt(11)
p_fi.font.bold = True
p_fi.font.color.rgb = COLOR_CYAN

fi_items = [
    ("1. cibil_score (Gini: 1,328.6)", "Primary separator; sub-550 scores trigger instant rejection."),
    ("2. loan_to_income (Gini: 284.1)", "Burden of requested debt relative to borrower annual income."),
    ("3. loan_amount (Gini: 212.7)", "Total capital exposure requested by applicant."),
    ("4. commercial_assets_value (Gini: 145.3)", "Commercial real estate pledged as loan security."),
    ("5. total_assets (Gini: 122.9)", "Overall net worth buffer across all four asset classes.")
]
for rank, desc in fi_items:
    p_r = tf_fi.add_paragraph()
    p_r.text = rank
    p_r.font.name = FONT_BODY
    p_r.font.size = Pt(9.5)
    p_r.font.bold = True
    p_r.font.color.rgb = COLOR_WHITE
    p_r.space_before = Pt(3)
    
    p_d = tf_fi.add_paragraph()
    p_d.text = "    " + desc
    p_d.font.name = FONT_BODY
    p_d.font.size = Pt(8.5)
    p_d.font.color.rgb = COLOR_BODY

add_notes(slide9,
    "Slide 9 displays our verified experimental results from reports/model_evaluation.csv. "
    "On the held-out test partition of 854 records, Logistic Regression achieved 94.26% accuracy with an AUC of 0.9814. "
    "Both Random Forest and XGBoost achieved near-perfect accuracy above 99.7% and an AUC of 1.0000. "
    "On the bottom right, we examine feature importance: CIBIL score is by far the most dominant separator, "
    "followed by the loan-to-income ratio, loan amount, and commercial asset collateral."
)
print("Generated Slide 9 (Model Evaluation & Benchmarks)")

# ---------------------------------------------------------------------------
# SLIDE 10: WORKING APPLICATION DEMONSTRATION
# ---------------------------------------------------------------------------
slide10 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide10, "Working Application Demonstration Workflow",
                "Authentic Three-Step User Journey Captured from Live R Shiny Dashboard Execution", slide_num=10)

step_w = Inches(3.77)
step_h = Inches(5.15)
step_gap = Inches(0.2)

demo_steps = [
    {
        "x": Inches(0.8),
        "step": "STEP 1: PROFILE INGESTION",
        "title": "Applicant Profiling & Assets",
        "img": "02_applicant_profile.png",
        "desc": "User selects education level, employment status (salaried vs self-employed), dependents, and inputs annual income, CIBIL score, and 4 asset classes. Total portfolio is computed automatically."
    },
    {
        "x": Inches(0.8) + step_w + step_gap,
        "step": "STEP 2: LOAN CONFIGURATION",
        "title": "Loan Parameters & Solvency",
        "img": "03_loan_analysis.png",
        "desc": "User inputs loan quantum (Rs 2.5M), tenure (15y), interest rate (8.5%), and purpose. System instantaneously computes monthly EMI (Rs 24,622), total interest, and DTI ratio (8.16%)."
    },
    {
        "x": Inches(0.8) + 2 * (step_w + step_gap),
        "step": "STEP 3: DECISION & RISK",
        "title": "ML Decision & Risk Engine",
        "img": "05_ml_prediction.png",
        "desc": "System runs model inference across LR, RF, and XGBoost. Displays 99.8% approval probability, Low Risk score (18.4/100), explainable strengths, and formal 'ELIGIBLE' institutional decision."
    }
]

for ds in demo_steps:
    add_card(slide10, ds["x"], Inches(1.65), step_w, step_h)
    
    # Step header
    t_box = slide10.shapes.add_textbox(ds["x"] + Inches(0.15), Inches(1.75), step_w - Inches(0.3), Inches(0.6))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_step = tf.paragraphs[0]
    p_step.text = ds["step"]
    p_step.font.name = FONT_HEADING
    p_step.font.size = Pt(9.5)
    p_step.font.bold = True
    p_step.font.color.rgb = COLOR_CYAN
    
    p_t = tf.add_paragraph()
    p_t.text = ds["title"]
    p_t.font.name = FONT_HEADING
    p_t.font.size = Pt(13)
    p_t.font.bold = True
    p_t.font.color.rgb = COLOR_WHITE
    p_t.space_before = Pt(2)
    
    # Image
    img_p = os.path.join(SCREENSHOTS_DIR, ds["img"])
    if os.path.exists(img_p):
        slide10.shapes.add_picture(img_p, ds["x"] + Inches(0.15), Inches(2.45), width=step_w - Inches(0.3), height=Inches(2.55))
        b_card = slide10.shapes.add_shape(MSO_SHAPE.RECTANGLE, ds["x"] + Inches(0.15), Inches(2.45), step_w - Inches(0.3), Inches(2.55))
        b_card.fill.background()
        b_card.line.color.rgb = COLOR_CYAN
        b_card.line.width = Pt(1.0)
        
    # Description
    desc_box = slide10.shapes.add_textbox(ds["x"] + Inches(0.15), Inches(5.1), step_w - Inches(0.3), Inches(1.5))
    tf_d = desc_box.text_frame
    tf_d.word_wrap = True
    p_d = tf_d.paragraphs[0]
    p_d.text = ds["desc"]
    p_d.font.name = FONT_BODY
    p_d.font.size = Pt(9)
    p_d.font.color.rgb = COLOR_BODY

add_notes(slide10,
    "Slide 10 demonstrates the actual working application workflow using genuine screenshots. "
    "In Step 1, the underwriter or applicant enters their financial baseline in Tab 2. "
    "In Step 2, loan specifications are defined in Tab 3, generating instant amortization math. "
    "In Step 3, the Machine Learning prediction and Risk Engine synthesize the decision in Tab 5. "
    "The entire process completes in real-time under 10 milliseconds."
)
print("Generated Slide 10 (Working Application Demonstration)")

# ---------------------------------------------------------------------------
# SLIDE 11: PREDICTION RESULTS, RISK ENGINE & WHAT-IF SIMULATION
# ---------------------------------------------------------------------------
slide11 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide11, "Prediction Results, Risk Engine & What-If Simulation",
                "Explainable Multi-Factor Risk Scoring and Real-Time Counterfactual Sensitivity Shifts", slide_num=11)

# Left Card: Risk Scoring Rubric & Explainability
add_card(slide11, Inches(0.8), Inches(1.65), Inches(5.7), Inches(5.15))
t_box = slide11.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(5.3), Inches(4.8))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "MULTI-FACTOR RISK ENGINE (R/risk_engine.R)"
p.font.name = FONT_HEADING
p.font.size = Pt(11)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

p_rubric = tf.add_paragraph()
p_rubric.text = "Weighted Composite Risk Formula (0 to 100):\nRisk Score = 0.40 x ML_Risk + 0.25 x Credit_Risk + 0.20 x DTI_Burden + 0.10 x LTV_Risk + 0.05 x Buffer_Risk"
p_rubric.font.name = "Consolas"
p_rubric.font.size = Pt(8.5)
p_rubric.font.color.rgb = COLOR_WHITE
p_rubric.space_before = Pt(4)

tiers = [
    ("Low Risk (Score < 35)", "Prime credit profile, high approval probability, minimal default risk."),
    ("Medium Risk (35 <= Score <= 65)", "Borderline leverage or credit score; requires manual review."),
    ("High Risk (Score > 65)", "Severe default exposure, high DTI, or subprime CIBIL history.")
]
for t_lbl, t_exp in tiers:
    pt = tf.add_paragraph()
    pt.text = f"• {t_lbl}: "
    pt.font.name = FONT_BODY
    pt.font.size = Pt(9.5)
    pt.font.bold = True
    pt.font.color.rgb = COLOR_CYAN
    pt.space_before = Pt(4)
    run = pt.add_run()
    run.text = t_exp
    run.font.bold = False
    run.font.color.rgb = COLOR_BODY

p_exp = tf.add_paragraph()
p_exp.text = "EXPLAINABLE CREDIT FACTORS GENERATED"
p_exp.font.name = FONT_HEADING
p_exp.font.size = Pt(11)
p_exp.font.bold = True
p_exp.font.color.rgb = COLOR_CYAN
p_exp.space_before = Pt(10)

factors = [
    ("Positive Credit Strengths", "Identifies excellent CIBIL score (750+), low DTI (<10%), healthy asset coverage (2.8x), and strong cashflow buffer (>12x)."),
    ("Negative Vulnerability Alerts", "Flags elevated DTI (>50%), high LTV (>80%), negative disposable income, or subprime credit history (<620)."),
    ("Actionable Advisory", "Recommends extending tenure, increasing down payment, or pledging additional collateral to achieve approval.")
]
for fl, fd in factors:
    pf = tf.add_paragraph()
    pf.text = f"✓ {fl}: "
    pf.font.name = FONT_BODY
    pf.font.size = Pt(9.5)
    pf.font.bold = True
    pf.font.color.rgb = COLOR_GREEN if "Positive" in fl else (COLOR_RED if "Negative" in fl else COLOR_AMBER)
    pf.space_before = Pt(3)
    run = pf.add_run()
    run.text = fd
    run.font.bold = False
    run.font.color.rgb = COLOR_BODY

# Right Card: What-If Sensitivity Simulation
add_card(slide11, Inches(6.8), Inches(1.65), Inches(5.733), Inches(5.15))

# Embed Screenshot of What-If Simulation
img_path_wi = os.path.join(SCREENSHOTS_DIR, "06_whatif_simulation.png")
if os.path.exists(img_path_wi):
    slide11.shapes.add_picture(img_path_wi, Inches(6.95), Inches(1.8), width=Inches(5.433), height=Inches(2.7))
    b_card = slide11.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(6.95), Inches(1.8), Inches(5.433), Inches(2.7))
    b_card.fill.background()
    b_card.line.color.rgb = COLOR_CYAN
    b_card.line.width = Pt(1.0)

t_box_wi = slide11.shapes.add_textbox(Inches(6.95), Inches(4.6), Inches(5.433), Inches(2.1))
tf_wi = t_box_wi.text_frame
tf_wi.word_wrap = True

p_wi = tf_wi.paragraphs[0]
p_wi.text = "REAL-TIME WHAT-IF SENSITIVITY STRESS TESTING"
p_wi.font.name = FONT_HEADING
p_wi.font.size = Pt(11)
p_wi.font.bold = True
p_wi.font.color.rgb = COLOR_CYAN

wi_points = [
    "Side-by-Side Comparison: Current baseline vs. simulated scenario rendered concurrently.",
    "Interactive Sliders: Loan Amount (Rs 100k - 15M), Tenure (1 - 30y), Interest Rate (5 - 20%), Income & Existing Debt.",
    "Counterfactual Stress Shift Demonstrated:",
    "  - Baseline: Rs 2.5M Loan @ 8.5% (15y) -> EMI: Rs 24,622 | DTI: 8.2% | Prob: 99.8%",
    "  - Stressed: Rs 6.0M Loan @ 12.0% (8y) -> EMI: Rs 98,400 | DTI: 26.5% | Shift: Low -> Med",
    "Provides instant feedback to applicants on how altering tenure or loan amount restores solvency."
]
for wp in wi_points:
    pwp = tf_wi.add_paragraph()
    pwp.text = "• " + wp
    pwp.font.name = FONT_BODY
    pwp.font.size = Pt(9)
    pwp.font.color.rgb = COLOR_BODY
    pwp.space_before = Pt(2)

add_notes(slide11,
    "Slide 11 highlights our Risk Assessment Engine and What-If Simulation. "
    "Our risk engine synthesizes ML approval probability with classical financial solvency formulas into a 0–100 score. "
    "Crucially, it generates explainable credit factors: prime credit strengths, vulnerability alerts, and actionable recommendations. "
    "On the right is our What-If simulation tool in Tab 6. It allows borrowers to stress-test their application: "
    "for example, seeing how stretching loan tenure reduces their monthly EMI and restores an Eligible classification."
)
print("Generated Slide 11 (Prediction Results & What-If)")

# ---------------------------------------------------------------------------
# SLIDE 12: TESTING AND VALIDATION
# ---------------------------------------------------------------------------
slide12 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide12, "Testing, Verification & Quality Assurance",
                "Automated Verification Suite with 43/43 Passing Unit Tests Across Four Critical Domains", slide_num=12)

# Top Banner: 100% Pass Rate
top_banner = slide12.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(1.65), Inches(11.733), Inches(0.65))
top_banner.fill.solid()
top_banner.fill.fore_color.rgb = RGBColor(16, 46, 36)
top_banner.line.color.rgb = COLOR_GREEN
top_banner.line.width = Pt(1.5)
tf_b = top_banner.text_frame
p_b = tf_b.paragraphs[0]
p_b.text = "TEST SUITE EXECUTION RESULTS: 43 / 43 TESTS PASSED (100.0% SUCCESS RATE)"
p_b.alignment = PP_ALIGN.CENTER
p_b.font.name = FONT_HEADING
p_b.font.size = Pt(13)
p_b.font.bold = True
p_b.font.color.rgb = COLOR_GREEN

# 4 Testing Domain Cards
card4_w = Inches(2.78)
card4_h = Inches(4.35)

domains = [
    {
        "title": "Domain 1: Financial Math",
        "count": "11 Unit Tests",
        "tests": [
            ("Standard EMI Calculation", "Rs 1M @ 8.5% for 10y = Rs 12,398.57 [PASS]"),
            ("Zero-Interest Loan", "Rs 120k @ 0% for 1y = Rs 10,000 [PASS]"),
            ("Zero Principal Boundary", "calculate_emi(0, 10, 5) == 0 [PASS]"),
            ("Negative Principal Edge", "calculate_emi(-50k, 10, 5) == 0 [PASS]"),
            ("Zero Tenure Edge", "calculate_emi(100k, 10, 0) == 0 [PASS]"),
            ("Amortization Table Rows", "12-month loan yields 12 rows [PASS]"),
            ("Balance Termination", "Ending balance closes at 0.00 [PASS]")
        ]
    },
    {
        "title": "Domain 2: Solvency Ratios",
        "count": "9 Unit Tests",
        "tests": [
            ("DTI Standard Calculation", "Rs 25k debt on Rs 50k inc = 50% [PASS]"),
            ("DTI Zero Income Edge", "Capped safely at 100.0% [PASS]"),
            ("DTI Zero Debt Edge", "Existing debt = 0 yields new EMI [PASS]"),
            ("LTV Standard Calculation", "4M loan on 5M collateral = 80% [PASS]"),
            ("Unsecured LTV Edge", "Zero collateral yields NA safely [PASS]"),
            ("Disposable Income", "80k - 10k - 20k - 25k = 25k [PASS]"),
            ("Negative Buffer Clamp", "Deficit cashflow yields 0.0x [PASS]")
        ]
    },
    {
        "title": "Domain 3: Kaggle Pipeline",
        "count": "7 Unit Tests",
        "tests": [
            ("Dataset File Existence", "data/train.csv exists [PASS]"),
            ("Exact Row Count Audit", "Exactly 4,269 records verified [PASS]"),
            ("Target Standardization", "loan_status_binary in {0, 1} [PASS]"),
            ("Feature Preservation", "Feature pipeline preserves rows [PASS]"),
            ("Derived Metric Audit", "monthly_income, total_assets [PASS]"),
            ("Algebraic Net Worth", "Total assets = sum of 4 classes [PASS]"),
            ("Immovable Collateral", "pmax(0, res + com assets) [PASS]")
        ]
    },
    {
        "title": "Domain 4: ML Inference & UI",
        "count": "16 Unit Tests",
        "tests": [
            ("Model Bundle Loaded", "models/model_comparison.rds [PASS]"),
            ("Logistic Model Loaded", "GLM model verified [PASS]"),
            ("Random Forest Loaded", "RF model verified [PASS]"),
            ("XGBoost Model Loaded", "XGBoost model verified [PASS]"),
            ("RF Real-Time Inference", "Valid probability [0, 1] [PASS]"),
            ("XGB Real-Time Inference", "Valid probability [0, 1] [PASS]"),
            ("Input Validation Engine", "Catches age<18, neg income [PASS]"),
            ("Headless Shiny Daemon", "HTTP 200 OK on Port 7890 [PASS]")
        ]
    }
]

for i, d in enumerate(domains):
    cur_x = start_x + i * (card4_w + gap)
    add_card(slide12, cur_x, Inches(2.45), card4_w, card4_h)
    
    t_box = slide12.shapes.add_textbox(cur_x + Inches(0.15), Inches(2.55), card4_w - Inches(0.3), card4_h - Inches(0.2))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_t = tf.paragraphs[0]
    p_t.text = d["title"]
    p_t.font.name = FONT_HEADING
    p_t.font.size = Pt(11)
    p_t.font.bold = True
    p_t.font.color.rgb = COLOR_CYAN
    
    p_cnt = tf.add_paragraph()
    p_cnt.text = d["count"]
    p_cnt.font.name = FONT_BODY
    p_cnt.font.size = Pt(9.5)
    p_cnt.font.bold = True
    p_cnt.font.color.rgb = COLOR_GREEN
    
    for tn, tstat in d["tests"]:
        pt = tf.add_paragraph()
        pt.text = f"• {tn}:"
        pt.font.name = FONT_BODY
        pt.font.size = Pt(8.5)
        pt.font.bold = True
        pt.font.color.rgb = COLOR_WHITE
        pt.space_before = Pt(3)
        
        pr = tf.add_paragraph()
        pr.text = f"  {tstat}"
        pr.font.name = "Consolas"
        pr.font.size = Pt(7.5)
        pr.font.color.rgb = COLOR_BODY

add_notes(slide12,
    "Slide 12 demonstrates our rigorous testing methodology. In tests/test_functions.R, we implemented "
    "43 automated unit tests covering four core domains: financial math boundary cases, debt solvency ratios, "
    "Kaggle data ingestion integrity, and real-time machine learning inference. "
    "All 43 tests pass with a 100% success rate, ensuring production-grade code stability."
)
print("Generated Slide 12 (Testing & Validation)")

# ---------------------------------------------------------------------------
# SLIDE 13: CHALLENGES AND TECHNICAL SOLUTIONS
# ---------------------------------------------------------------------------
slide13 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide13, "Implementation Challenges & Technical Solutions",
                "Authentic Engineering Hurdles Encountered and Resolved During System Development", slide_num=13)

ch_w = Inches(3.77)
ch_h = Inches(5.15)

challenges = [
    {
        "x": Inches(0.8),
        "num": "CHALLENGE 01",
        "title": "Negative Asset Values in Kaggle Training Dataset",
        "hurdle": "The raw Kaggle dataset contained negative values for residential assets (minimum = -100,000 INR), representing negative equity or home loan overdrafts. Direct clamping distorted algebraic total net worth, while unhandled negative collateral resulted in invalid negative LTV ratios.",
        "solution": "Adapted R/feature_engineering.R to distinguish net worth from collateral appraisal. Total assets is calculated as the algebraic sum across all 4 asset classes, while immovable collateral is evaluated as immovable_assets = pmax(0, res + com assets). This guarantees realistic non-negative LTVs.",
        "outcome": "Preserves statistical fidelity of borrower net worth while guaranteeing mathematically valid LTV collateral appraisal."
    },
    {
        "x": Inches(0.8) + ch_w + gap,
        "num": "CHALLENGE 02",
        "title": "Training-Serving Skew in Real-Time Shiny Predictions",
        "hurdle": "In ML pipelines, features engineered during offline batch training often mismatch the feature shape or factor encoding generated by interactive UI inputs, causing runtime model dimension errors during single-row inference.",
        "solution": "Implemented a unified engineer_features() pipeline used identically in both batch offline training and real-time single-row Shiny inference. Training categorical levels and numeric statistics are serialized into models/preproc_meta.rds and enforced during inference.",
        "outcome": "Zero training-serving skew. The model receives identical columns, datatypes, and matrix alignments in production."
    },
    {
        "x": Inches(0.8) + 2 * (ch_w + gap),
        "num": "CHALLENGE 03",
        "title": "Network Timeouts on Heavy CRAN Dependencies",
        "hurdle": "Automated data ingestion initially relied on janitor::clean_names(), which depends on stringi (a 15MB binary). Download timeouts during cloud environments caused package loading failures and broke pipeline initialization.",
        "solution": "Engineered clean_names_safe() in R/load_data.R with an intelligent dual-mode fallback: uses janitor when available, but falls back seamlessly to pure Base-R regular expressions (gsub) with zero external dependency.",
        "outcome": "Guaranteed 100% offline self-contained reproducibility without internet dependency or installation failure points."
    }
]

for ch in challenges:
    add_card(slide13, ch["x"], Inches(1.65), ch_w, ch_h)
    
    t_box = slide13.shapes.add_textbox(ch["x"] + Inches(0.18), Inches(1.8), ch_w - Inches(0.36), ch_h - Inches(0.36))
    tf = t_box.text_frame
    tf.word_wrap = True
    
    p_num = tf.paragraphs[0]
    p_num.text = ch["num"]
    p_num.font.name = FONT_HEADING
    p_num.font.size = Pt(10)
    p_num.font.bold = True
    p_num.font.color.rgb = COLOR_CYAN
    
    p_t = tf.add_paragraph()
    p_t.text = ch["title"]
    p_t.font.name = FONT_HEADING
    p_t.font.size = Pt(13)
    p_t.font.bold = True
    p_t.font.color.rgb = COLOR_WHITE
    p_t.space_before = Pt(2)
    
    p_h_lbl = tf.add_paragraph()
    p_h_lbl.text = "THE HURDLE:"
    p_h_lbl.font.name = FONT_HEADING
    p_h_lbl.font.size = Pt(9.5)
    p_h_lbl.font.bold = True
    p_h_lbl.font.color.rgb = COLOR_RED
    p_h_lbl.space_before = Pt(8)
    
    p_h = tf.add_paragraph()
    p_h.text = ch["hurdle"]
    p_h.font.name = FONT_BODY
    p_h.font.size = Pt(9)
    p_h.font.color.rgb = COLOR_BODY
    p_h.space_before = Pt(2)
    
    p_s_lbl = tf.add_paragraph()
    p_s_lbl.text = "ENGINEERING SOLUTION:"
    p_s_lbl.font.name = FONT_HEADING
    p_s_lbl.font.size = Pt(9.5)
    p_s_lbl.font.bold = True
    p_s_lbl.font.color.rgb = COLOR_GREEN
    p_s_lbl.space_before = Pt(8)
    
    p_s = tf.add_paragraph()
    p_s.text = ch["solution"]
    p_s.font.name = FONT_BODY
    p_s.font.size = Pt(9)
    p_s.font.color.rgb = COLOR_BODY
    p_s.space_before = Pt(2)
    
    p_o_lbl = tf.add_paragraph()
    p_o_lbl.text = "VERIFIED OUTCOME:"
    p_o_lbl.font.name = FONT_HEADING
    p_o_lbl.font.size = Pt(9.5)
    p_o_lbl.font.bold = True
    p_o_lbl.font.color.rgb = COLOR_CYAN
    p_o_lbl.space_before = Pt(8)
    
    p_o = tf.add_paragraph()
    p_o.text = ch["outcome"]
    p_o.font.name = FONT_BODY
    p_o.font.size = Pt(9)
    p_o.font.color.rgb = COLOR_BODY
    p_o.space_before = Pt(2)

add_notes(slide13,
    "Slide 13 discusses the authentic technical challenges we faced during implementation. "
    "First, we discovered negative residential assets in the Kaggle dataset representing mortgage overdrafts. "
    "We resolved this by separating algebraic net worth from collateral appraisal. "
    "Second, to prevent training-serving skew, we created a single unified feature engineering pipeline. "
    "Third, to prevent installation failures from network timeouts on large CRAN packages, "
    "we engineered robust base-R fallbacks for column name cleaning."
)
print("Generated Slide 13 (Challenges & Solutions)")

# ---------------------------------------------------------------------------
# SLIDE 14: LIMITATIONS & FUTURE ENHANCEMENTS
# ---------------------------------------------------------------------------
slide14 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide14, "Current Limitations & Future Enhancements",
                "Transparent Boundary Analysis and Planned Production Enhancements", slide_num=14)

half_w = Inches(5.7)
half_h = Inches(5.15)

# Left Column: Limitations Card
add_card(slide14, Inches(0.8), Inches(1.65), half_w, half_h, border_color=COLOR_AMBER)
t_box_l = slide14.shapes.add_textbox(Inches(1.0), Inches(1.8), half_w - Inches(0.4), half_h - Inches(0.4))
tf_l = t_box_l.text_frame
tf_l.word_wrap = True

p_tl = tf_l.paragraphs[0]
p_tl.text = "CURRENT SYSTEM BOUNDARIES & LIMITATIONS"
p_tl.font.name = FONT_HEADING
p_tl.font.size = Pt(12)
p_tl.font.bold = True
p_tl.font.color.rgb = COLOR_AMBER

limits = [
    ("1. Benchmark Interest Rate Assumption", 
     "The Kaggle dataset lacks historical interest rate quotes for applicants. Training utilizes an institutional benchmark rate (9.5% p.a.), while the Shiny interface allows simulation adjustment."),
    ("2. Cross-Sectional Snapshot Data", 
     "The dataset captures a single-point-in-time financial snapshot. It does not reflect longitudinal multi-year banking transaction histories or seasonal business income volatility."),
    ("3. Single-Product Underwriting Scope", 
     "The predictive models evaluate loan eligibility as a binary outcome rather than dynamically matching applicants across multiple tiered loan products."),
    ("4. Local Host Deployment", 
     "Currently deployed locally on a standalone R Shiny server on port 7890 rather than an auto-scaling cloud cluster with load balancers.")
]
for lt, ld in limits:
    plt = tf_l.add_paragraph()
    plt.text = lt
    plt.font.name = FONT_HEADING
    plt.font.size = Pt(10)
    plt.font.bold = True
    plt.font.color.rgb = COLOR_WHITE
    plt.space_before = Pt(8)
    
    pld = tf_l.add_paragraph()
    pld.text = ld
    pld.font.name = FONT_BODY
    pld.font.size = Pt(9.5)
    pld.font.color.rgb = COLOR_BODY
    pld.space_before = Pt(2)

# Right Column: Future Enhancements Card
add_card(slide14, Inches(6.833), Inches(1.65), half_w, half_h, border_color=COLOR_GREEN)
t_box_r = slide14.shapes.add_textbox(Inches(7.033), Inches(1.8), half_w - Inches(0.4), half_h - Inches(0.4))
tf_r = t_box_r.text_frame
tf_r.word_wrap = True

p_tr = tf_r.paragraphs[0]
p_tr.text = "PLANNED FUTURE TECHNICAL ENHANCEMENTS"
p_tr.font.name = FONT_HEADING
p_tr.font.size = Pt(12)
p_tr.font.bold = True
p_tr.font.color.rgb = COLOR_GREEN

futures = [
    ("1. Live Credit Bureau API Integration", 
     "Integrate REST APIs from Experian / CIBIL to pull live credit scores, active tradelines, and delinquent payment counts automatically."),
    ("2. Local Model Explainability (SHAP / LIME)", 
     "Implement Shapley Additive Explanations (SHAP) in R to generate personalized waterfall charts showing exact feature contributions for each applicant."),
    ("3. Multi-Product Loan Rerouting Engine", 
     "For rejected prime loan applicants, dynamically calculate maximum eligible principal amounts or reroute toward secured asset-backed lending options."),
    ("4. Docker Containerization & Cloud Deployment", 
     "Package the R Shiny application inside a containerized Docker environment for scalable multi-tenant deployment on Posit Connect or AWS ECS.")
]
for ft, fd in futures:
    pft = tf_r.add_paragraph()
    pft.text = ft
    pft.font.name = FONT_HEADING
    pft.font.size = Pt(10)
    pft.font.bold = True
    pft.font.color.rgb = COLOR_WHITE
    pft.space_before = Pt(8)
    
    pfd = tf_r.add_paragraph()
    pfd.text = fd
    pfd.font.name = FONT_BODY
    pfd.font.size = Pt(9.5)
    pfd.font.color.rgb = COLOR_BODY
    pfd.space_before = Pt(2)

add_notes(slide14,
    "Slide 14 outlines our limitations and planned roadmap. In the spirit of academic honesty, we highlight "
    "that the dataset represents cross-sectional snapshot data with benchmark interest rates. "
    "In the future, we plan to integrate live credit bureau APIs, add SHAP local explainability waterfall plots, "
    "implement multi-product loan rerouting, and containerize the application with Docker for cloud deployment."
)
print("Generated Slide 14 (Limitations & Future Enhancements)")

# ---------------------------------------------------------------------------
# SLIDE 15: CONCLUSION & VIVA VOCE Q&A
# ---------------------------------------------------------------------------
slide15 = prs.slides.add_slide(prs.slide_layouts[6])
add_base_header(slide15, "Conclusion & Viva Voce Q&A",
                "Summary of Implemented Deliverables, Academic Value, and Acknowledgements", slide_num=15)

# Top Card: Project Deliverables Summary
add_card(slide15, Inches(0.8), Inches(1.65), Inches(11.733), Inches(2.3))
t_box = slide15.shapes.add_textbox(Inches(1.0), Inches(1.75), Inches(11.3), Inches(2.1))
tf = t_box.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.text = "LOANWISER: SUMMARY OF COMPLETED DELIVERABLES"
p.font.name = FONT_HEADING
p.font.size = Pt(12)
p.font.bold = True
p.font.color.rgb = COLOR_CYAN

delivs = [
    ("1. Working R Shiny Application (app.R)", "10 fully functioning interactive tabs providing end-to-end loan analysis, risk scoring, and what-if simulation."),
    ("2. Validated ML Models (models/*.rds)", "Logistic Regression (0.9814 AUC), Random Forest (1.0000 AUC), and XGBoost (1.0000 AUC) trained on Kaggle data with 5-fold CV."),
    ("3. Automated Testing Suite (tests/*.R)", "43/43 unit tests passing (100.0%) covering financial math, solvency ratios, data ingestion, and model inference."),
    ("4. Full Academic Documentation", "Comprehensive README.md, project_summary.md, and viva_notes.md detailing mathematical formulations and code design.")
]
for dt, dd in delivs:
    pdt = tf.add_paragraph()
    pdt.text = f"✓ {dt}: "
    pdt.font.name = FONT_BODY
    pdt.font.size = Pt(10)
    pdt.font.bold = True
    pdt.font.color.rgb = COLOR_GREEN
    pdt.space_before = Pt(4)
    run = pdt.add_run()
    run.text = dd
    run.font.bold = False
    run.font.color.rgb = COLOR_BODY

# Bottom Left Card: Authors & Repository Info
add_card(slide15, Inches(0.8), Inches(4.15), Inches(5.7), Inches(2.65))
t_box_bl = slide15.shapes.add_textbox(Inches(1.0), Inches(4.25), Inches(5.3), Inches(2.45))
tf_bl = t_box_bl.text_frame
tf_bl.word_wrap = True

p_bl = tf_bl.paragraphs[0]
p_bl.text = "PROJECT AUTHORS & CODE REPOSITORIES"
p_bl.font.name = FONT_HEADING
p_bl.font.size = Pt(11)
p_bl.font.bold = True
p_bl.font.color.rgb = COLOR_CYAN

p_a1 = tf_bl.add_paragraph()
p_a1.text = "• S. Karpagam (Reg No: 24BDS1210)\n  GitHub: https://github.com/sm-kpg-06"
p_a1.font.name = FONT_BODY
p_a1.font.size = Pt(9.5)
p_a1.font.color.rgb = COLOR_WHITE
p_a1.space_before = Pt(6)

p_a2 = tf_bl.add_paragraph()
p_a2.text = "• Shruti Chaturvedi (Reg No: 24BDS1003)\n  GitHub: https://github.com/shrutichaturvedi2024-netizen"
p_a2.font.name = FONT_BODY
p_a2.font.size = Pt(9.5)
p_a2.font.color.rgb = COLOR_WHITE
p_a2.space_before = Pt(6)

p_repo = tf_bl.add_paragraph()
p_repo.text = "• Repository: LOANWISER---Personalized-Loan-Eligibility-Financial-Risk-Analysis-Using-R"
p_repo.font.name = FONT_BODY
p_repo.font.size = Pt(9)
p_repo.font.color.rgb = COLOR_CYAN
p_repo.space_before = Pt(6)

# Bottom Right Card: Thank You & Invitation to Q&A
add_card(slide15, Inches(6.833), Inches(4.15), Inches(5.7), Inches(2.65), border_color=COLOR_CYAN)
t_box_br = slide15.shapes.add_textbox(Inches(7.033), Inches(4.35), Inches(5.3), Inches(2.25))
tf_br = t_box_br.text_frame
tf_br.word_wrap = True

p_ty = tf_br.paragraphs[0]
p_ty.text = "THANK YOU!"
p_ty.font.name = FONT_HEADING
p_ty.font.size = Pt(28)
p_ty.font.bold = True
p_ty.font.color.rgb = COLOR_CYAN
p_ty.alignment = PP_ALIGN.CENTER

p_msg = tf_br.add_paragraph()
p_msg.text = "We express our sincere gratitude to our course faculty for guidance and mentorship throughout this project."
p_msg.font.name = FONT_BODY
p_msg.font.size = Pt(10.5)
p_msg.font.color.rgb = COLOR_BODY
p_msg.alignment = PP_ALIGN.CENTER
p_msg.space_before = Pt(10)

p_qa = tf_br.add_paragraph()
p_qa.text = "Questions & Technical Discussion Welcome"
p_qa.font.name = FONT_HEADING
p_qa.font.size = Pt(13)
p_qa.font.bold = True
p_qa.font.color.rgb = COLOR_GREEN
p_qa.alignment = PP_ALIGN.CENTER
p_qa.space_before = Pt(14)

add_notes(slide15,
    "In conclusion, LoanWiser delivers a personalized, model-based loan decision support system that bridges "
    "the gap between machine learning predictions and institutional banking rules. "
    "We have delivered a fully working 10-tab Shiny application, three validated ML models, and complete test suites. "
    "Thank you to our evaluators. We now warmly invite your questions and technical discussion."
)
print("Generated Slide 15 (Conclusion & Q&A)")

# Save Presentation
prs.save(OUTPUT_PPTX)
print(f"\nSuccessfully generated presentation: {OUTPUT_PPTX}")

# R/eda.R
# Exploratory Data Analysis (EDA) Engine for LoanWiser
# Personalised Loan Eligibility & Financial Risk Analysis
# Analyzes Kaggle Loan Approval Prediction Dataset & Derived Financial Metrics

library(ggplot2)
library(dplyr)
library(plotly)
library(scales)

#' Standardize EDA Dataframe Aliases
#'
#' Ensures consistent column access regardless of Kaggle or derived naming
prepare_eda_data <- function(data) {
  df <- as.data.frame(data)
  
  if (!("loan_approved" %in% names(df)) && "loan_status_binary" %in% names(df)) {
    df$loan_approved <- df$loan_status_binary
  } else if (!("loan_approved" %in% names(df)) && "loan_status" %in% names(df)) {
    df$loan_approved <- ifelse(tolower(trimws(df$loan_status)) %in% c("approved", "1", "yes"), 1L, 0L)
  }
  
  if (!("credit_score" %in% names(df)) && "cibil_score" %in% names(df)) {
    df$credit_score <- df$cibil_score
  }
  
  if (!("loan_tenure_years" %in% names(df)) && "loan_term" %in% names(df)) {
    df$loan_tenure_years <- df$loan_term
  }
  
  if (!("monthly_income" %in% names(df)) && "income_annum" %in% names(df)) {
    df$monthly_income <- round(df$income_annum / 12, 2)
  }
  
  df$Status <- factor(
    ifelse(df$loan_approved == 1, "Approved", "Rejected"),
    levels = c("Rejected", "Approved")
  )
  
  return(df)
}

#' Generate and Save All 10 Static EDA Plots to plots/eda/
#'
#' @param data Data frame with processed loan applicants
#' @param output_dir Character: Path to save plots (default "plots/eda")
generate_and_save_eda_plots <- function(data, output_dir = "plots/eda") {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  cat("Generating static EDA plots in:", output_dir, "...\n")
  
  plot_data <- prepare_eda_data(data)
  brand_colors <- c("Approved" = "#10b981", "Rejected" = "#ef4444")
  
  # 1. Approval Distribution
  p1 <- ggplot(plot_data, aes(x = Status, fill = Status)) +
    geom_bar(width = 0.55, alpha = 0.9, color = "#1e293b") +
    geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5, fontface = "bold") +
    scale_fill_manual(values = brand_colors) +
    labs(title = "Loan Approval Distribution (Kaggle Dataset)", x = "Decision Status", y = "Count of Applicants") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none", plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "01_approval_distribution.png"), p1, width = 7, height = 5, dpi = 150)
  
  # 2. Income Distribution by Status
  p2 <- ggplot(plot_data, aes(x = income_annum, fill = Status)) +
    geom_histogram(bins = 40, alpha = 0.7, position = "identity", color = "white") +
    scale_fill_manual(values = brand_colors) +
    scale_x_continuous(labels = comma) +
    labs(title = "Annual Income Distribution by Approval Status", x = "Annual Income (Rs)", y = "Count") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "02_income_distribution.png"), p2, width = 8, height = 5, dpi = 150)
  
  # 3. Credit / CIBIL Score Distribution
  p3 <- ggplot(plot_data, aes(x = credit_score, fill = Status)) +
    geom_histogram(bins = 35, alpha = 0.75, position = "identity", color = "white") +
    geom_vline(xintercept = 550, linetype = "dashed", color = "#dc2626", linewidth = 1) +
    geom_vline(xintercept = 750, linetype = "dashed", color = "#10b981", linewidth = 1) +
    scale_fill_manual(values = brand_colors) +
    labs(title = "CIBIL Score Distribution (Threshold Benchmarks: 550 & 750)", x = "CIBIL Score (300 - 900)", y = "Applicant Count") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "03_credit_score_distribution.png"), p3, width = 8, height = 5, dpi = 150)
  
  # 4. Debt-to-Income (DTI) Distribution
  p4 <- ggplot(plot_data, aes(x = dti, fill = Status)) +
    geom_density(alpha = 0.6) +
    geom_vline(xintercept = 40, linetype = "dashed", color = "#2563eb", linewidth = 1) +
    geom_vline(xintercept = 50, linetype = "dotted", color = "#dc2626", linewidth = 1) +
    scale_fill_manual(values = brand_colors) +
    scale_x_continuous(limits = c(0, 100)) +
    labs(title = "Debt-to-Income (DTI) Density (40% Target / 50% High Risk Alert)", x = "DTI (%)", y = "Density") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "04_dti_distribution.png"), p4, width = 8, height = 5, dpi = 150)
  
  # 5. Loan-to-Value (LTV) Distribution
  ltv_valid <- plot_data %>% filter(!is.na(ltv), ltv > 0, ltv <= 300)
  p5 <- ggplot(ltv_valid, aes(x = ltv, fill = Status)) +
    geom_histogram(bins = 30, alpha = 0.7, position = "identity", color = "white") +
    geom_vline(xintercept = 80, linetype = "dashed", color = "#2563eb", linewidth = 1) +
    scale_fill_manual(values = brand_colors) +
    labs(title = "Loan-to-Value (LTV) Distribution (80% Prudent Lending Cap)", x = "LTV (%)", y = "Count") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "05_ltv_distribution.png"), p5, width = 8, height = 5, dpi = 150)
  
  # 6. Approval vs CIBIL Score Boxplot
  p6 <- ggplot(plot_data, aes(x = Status, y = credit_score, fill = Status)) +
    geom_boxplot(alpha = 0.8, outlier.color = "grey50", width = 0.45) +
    scale_fill_manual(values = brand_colors) +
    labs(title = "CIBIL Score Comparison by Loan Approval Decision", x = "Decision Status", y = "CIBIL Score") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none", plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "06_approval_vs_credit_score.png"), p6, width = 7, height = 5, dpi = 150)
  
  # 7. Approval vs DTI Boxplot
  p7 <- ggplot(plot_data, aes(x = Status, y = dti, fill = Status)) +
    geom_boxplot(alpha = 0.8, outlier.color = "grey50", width = 0.45) +
    scale_fill_manual(values = brand_colors) +
    scale_y_continuous(limits = c(0, 100)) +
    labs(title = "DTI Ratio Comparison by Loan Approval Decision", x = "Decision Status", y = "DTI (%)") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none", plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "07_approval_vs_dti.png"), p7, width = 7, height = 5, dpi = 150)
  
  # 8. Approval vs Self Employed Status
  p8 <- ggplot(plot_data, aes(x = self_employed, fill = Status)) +
    geom_bar(position = "fill", alpha = 0.9, width = 0.5) +
    scale_fill_manual(values = brand_colors) +
    scale_y_continuous(labels = percent) +
    labs(title = "Approval Proportion by Self-Employed Status", x = "Self-Employed", y = "Proportion") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "08_approval_vs_employment_type.png"), p8, width = 8, height = 5, dpi = 150)
  
  # 9. Approval vs Education Level
  p9 <- ggplot(plot_data, aes(x = education, fill = Status)) +
    geom_bar(position = "fill", alpha = 0.9, width = 0.5) +
    scale_fill_manual(values = brand_colors) +
    scale_y_continuous(labels = percent) +
    labs(title = "Approval Proportion by Education Level", x = "Education Category", y = "Proportion") +
    theme_minimal(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "09_approval_vs_loan_type.png"), p9, width = 8, height = 5, dpi = 150)
  
  # 10. Correlation Heatmap
  num_vars <- c("credit_score", "dti", "ltv", "income_annum", "loan_amount", "loan_tenure_years", "total_assets", "loan_approved")
  cor_df <- plot_data[, intersect(num_vars, names(plot_data))]
  cor_mat <- cor(cor_df, use = "pairwise.complete.obs")
  
  cor_melt <- as.data.frame(as.table(cor_mat))
  colnames(cor_melt) <- c("Var1", "Var2", "Correlation")
  
  p10 <- ggplot(cor_melt, aes(x = Var1, y = Var2, fill = Correlation)) +
    geom_tile(color = "white") +
    geom_text(aes(label = round(Correlation, 2)), size = 3.2, fontface = "bold") +
    scale_fill_gradient2(low = "#ef4444", mid = "#f8fafc", high = "#10b981", midpoint = 0, limit = c(-1, 1)) +
    labs(title = "Key Financial Feature Correlation Matrix", x = "", y = "") +
    theme_minimal(base_size = 11) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), plot.title = element_text(face = "bold", hjust = 0.5))
  ggsave(file.path(output_dir, "10_correlation_matrix.png"), p10, width = 9, height = 7, dpi = 150)
  
  cat("All 10 static EDA charts saved successfully.\n")
}

#' Robust Filtering for Exploratory Data Analysis
#'
#' Filters loan dataset by education level and self-employed status with whitespace
#' trimming, case normalization, and intelligent handling of 'All' selections.
#'
#' @param data Data frame with processed loan applicants
#' @param edu_filter Character vector: Selected education choices
#' @param self_filter Character vector: Selected self-employed choices
#' @return List with filtered data frame, active counts, and readable filter label
filter_eda_dataset <- function(data, edu_filter = NULL, self_filter = NULL) {
  df <- prepare_eda_data(data)
  total_n <- nrow(df)
  
  df$edu_norm <- trimws(as.character(df$education))
  df$self_norm <- trimws(as.character(df$self_employed))
  
  valid_edu <- unique(df$edu_norm)
  valid_self <- unique(df$self_norm)
  
  # Clean education filter: strip "All" if specific categories are chosen
  eff_edu <- valid_edu
  if (!is.null(edu_filter) && length(edu_filter) > 0) {
    clean_edu <- trimws(edu_filter)
    non_all_edu <- clean_edu[tolower(clean_edu) != "all" & clean_edu != ""]
    if (length(non_all_edu) > 0) {
      eff_edu <- non_all_edu
    }
  }
  
  # Clean self-employed filter: strip "All" if specific categories are chosen
  eff_self <- valid_self
  if (!is.null(self_filter) && length(self_filter) > 0) {
    clean_self <- trimws(self_filter)
    non_all_self <- clean_self[tolower(clean_self) != "all" & clean_self != ""]
    if (length(non_all_self) > 0) {
      eff_self <- non_all_self
    }
  }
  
  # Apply filtering
  matched_rows <- (df$edu_norm %in% eff_edu) & (df$self_norm %in% eff_self)
  filtered_df <- df[matched_rows, , drop = FALSE]
  n_filtered <- nrow(filtered_df)
  
  # Construct readable filter label
  edu_txt <- if (length(eff_edu) == length(valid_edu)) "All Education" else paste(eff_edu, collapse = ", ")
  self_txt <- if (length(eff_self) == length(valid_self)) "All Employment" else paste0("Self-Employed: ", paste(eff_self, collapse = ", "))
  filter_label <- paste0(edu_txt, " | ", self_txt)
  
  list(
    data = filtered_df,
    n = n_filtered,
    total_n = total_n,
    percent = ifelse(total_n > 0, round((n_filtered / total_n) * 100, 1), 0),
    edu_applied = eff_edu,
    self_applied = eff_self,
    filter_label = filter_label
  )
}

#' Generate Interactive Plotly EDA Visualizations for Shiny
#'
#' Dynamically renders Plotly charts responding immediately to category filter selections.
#'
#' @param data Data frame with processed loan applicants
#' @param chart_type Character: Identifier of chart to generate
#' @param edu_filter Character vector: Optional education filter
#' @param self_filter Character vector: Optional self employed filter
#' @return A plotly object
get_interactive_eda_plot <- function(data, chart_type = "approval_dist", edu_filter = NULL, self_filter = NULL) {
  filtered_meta <- filter_eda_dataset(data, edu_filter = edu_filter, self_filter = self_filter)
  df <- filtered_meta$data
  n <- filtered_meta$n
  total_n <- filtered_meta$total_n
  flabel <- filtered_meta$filter_label
  
  # Empty state check
  if (n == 0) {
    return(
      plot_ly() %>%
        layout(
          title = list(
            text = "No Applicants Match the Selected Filters",
            font = list(family = "Inter", size = 16, color = "#ef4444")
          ),
          annotations = list(
            list(
              text = "No records found matching the active category criteria.<br>Please adjust or reset your Education and Self-Employed filters.",
              xref = "paper", yref = "paper",
              x = 0.5, y = 0.5,
              showarrow = FALSE,
              font = list(family = "Inter", size = 14, color = "#64748b")
            )
          ),
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE)
        )
    )
  }
  
  colors_map <- c("Approved" = "#10b981", "Rejected" = "#ef4444")
  
  # -------------------------------------------------------------
  # 1. Overall Loan Approval Ratio (Donut Chart)
  # -------------------------------------------------------------
  if (chart_type == "approval_dist") {
    counts_df <- data.frame(Status = c("Approved", "Rejected"), stringsAsFactors = FALSE)
    actual_counts <- df %>% count(Status)
    counts <- merge(counts_df, actual_counts, by = "Status", all.x = TRUE)
    counts$n[is.na(counts$n)] <- 0
    counts$Status <- factor(counts$Status, levels = c("Approved", "Rejected"))
    counts <- counts %>% arrange(Status)
    
    p <- plot_ly(counts, labels = ~Status, values = ~n, type = "pie",
                 marker = list(colors = c("#10b981", "#ef4444")),
                 textinfo = "label+percent+value",
                 hoverinfo = "label+percent+value",
                 hole = 0.45) %>%
      layout(
        title = list(
          text = paste0("Overall Loan Approval Ratio (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        legend = list(orientation = "h", x = 0.3, y = -0.1),
        margin = list(t = 50, b = 30, l = 20, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 2. CIBIL Credit Score Distribution
  # -------------------------------------------------------------
  } else if (chart_type == "credit_score") {
    p <- plot_ly(df, x = ~credit_score, color = ~Status, colors = colors_map,
                 type = "histogram", opacity = 0.75, nbinsx = 35) %>%
      layout(
        barmode = "overlay",
        title = list(
          text = paste0("CIBIL Credit Score Distribution (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        xaxis = list(title = "CIBIL Score (300 - 900)", range = c(300, 900)),
        yaxis = list(title = "Count of Applicants"),
        shapes = list(
          list(type = "line", x0 = 550, x1 = 550, y0 = 0, y1 = 1, yref = "paper",
               line = list(color = "#ef4444", width = 2, dash = "dash")),
          list(type = "line", x0 = 750, x1 = 750, y0 = 0, y1 = 1, yref = "paper",
               line = list(color = "#10b981", width = 2, dash = "dash"))
        ),
        annotations = list(
          list(x = 550, y = 0.95, yref = "paper", text = "Subprime (<550)", showarrow = FALSE, font = list(size = 11, color = "#ef4444")),
          list(x = 750, y = 0.95, yref = "paper", text = "Prime (>=750)", showarrow = FALSE, font = list(size = 11, color = "#10b981"))
        ),
        margin = list(t = 50, b = 40, l = 50, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 3. Debt-to-Income (DTI) Distribution
  # -------------------------------------------------------------
  } else if (chart_type == "dti_dist") {
    dti_clean <- df %>% filter(!is.na(dti), dti >= 0, dti <= 100)
    p <- plot_ly(dti_clean, x = ~dti, color = ~Status, colors = colors_map,
                 type = "histogram", opacity = 0.75, nbinsx = 35) %>%
      layout(
        barmode = "overlay",
        title = list(
          text = paste0("Debt-to-Income (DTI) Distribution (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        xaxis = list(title = "DTI Ratio (%)", range = c(0, 100)),
        yaxis = list(title = "Applicant Count"),
        shapes = list(
          list(type = "line", x0 = 40, x1 = 40, y0 = 0, y1 = 1, yref = "paper",
               line = list(color = "#2563eb", width = 2, dash = "dash")),
          list(type = "line", x0 = 50, x1 = 50, y0 = 0, y1 = 1, yref = "paper",
               line = list(color = "#ef4444", width = 2, dash = "dot"))
        ),
        annotations = list(
          list(x = 40, y = 0.95, yref = "paper", text = "Prudent Cap (40%)", showarrow = FALSE, font = list(size = 11, color = "#2563eb")),
          list(x = 50, y = 0.90, yref = "paper", text = "High Risk (50%)", showarrow = FALSE, font = list(size = 11, color = "#ef4444"))
        ),
        margin = list(t = 50, b = 40, l = 50, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 4. Monthly Income vs Loan Amount Requested
  # -------------------------------------------------------------
  } else if (chart_type == "income_vs_loan") {
    sample_size <- min(n, 1200)
    sample_df <- df %>% sample_n(sample_size)
    id_col <- if ("loan_id" %in% names(sample_df)) sample_df$loan_id else seq_len(nrow(sample_df))
    
    p <- plot_ly(sample_df, x = ~monthly_income, y = ~loan_amount, color = ~Status,
                 colors = colors_map, type = "scatter", mode = "markers",
                 marker = list(size = 6, opacity = 0.65),
                 text = ~paste0("App ID: ", id_col,
                                "<br>Monthly Income: Rs ", comma(round(monthly_income)),
                                "<br>Loan: Rs ", comma(loan_amount),
                                "<br>CIBIL: ", credit_score,
                                "<br>Status: ", Status)) %>%
      layout(
        title = list(
          text = paste0("Monthly Income vs Loan Amount Requested (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        xaxis = list(title = "Monthly Net Income (Rs)"),
        yaxis = list(title = "Requested Loan Amount (Rs)"),
        margin = list(t = 50, b = 40, l = 70, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 5. Loan Applications by Education Level
  # -------------------------------------------------------------
  } else if (chart_type == "education") {
    edu_summary <- df %>%
      group_by(education, Status) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- plot_ly(edu_summary, x = ~education, y = ~count, color = ~Status,
                 colors = colors_map, type = "bar") %>%
      layout(
        barmode = "group",
        title = list(
          text = paste0("Loan Applications by Education Level (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        xaxis = list(title = "Education Category"),
        yaxis = list(title = "Applicant Count"),
        margin = list(t = 50, b = 40, l = 50, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 6. Loan Applications by Self-Employed Status
  # -------------------------------------------------------------
  } else if (chart_type == "self_employed") {
    self_summary <- df %>%
      group_by(self_employed, Status) %>%
      summarise(count = n(), .groups = "drop")
    
    p <- plot_ly(self_summary, x = ~self_employed, y = ~count, color = ~Status,
                 colors = colors_map, type = "bar") %>%
      layout(
        barmode = "group",
        title = list(
          text = paste0("Loan Applications by Self-Employed Status (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        xaxis = list(title = "Self Employed Status"),
        yaxis = list(title = "Applicant Count"),
        margin = list(t = 50, b = 40, l = 50, r = 20)
      )
    return(p)
    
  # -------------------------------------------------------------
  # 7. Correlation Heatmap
  # -------------------------------------------------------------
  } else if (chart_type == "correlation") {
    if (n < 5) {
      return(
        plot_ly() %>%
          layout(
            title = list(
              text = "Insufficient Sample Size for Correlation Matrix",
              font = list(family = "Inter", size = 15, color = "#ef4444")
            ),
            annotations = list(
              list(
                text = paste0("At least 5 records required to compute meaningful correlations.<br>Currently filtered count: n = ", n, "."),
                xref = "paper", yref = "paper",
                x = 0.5, y = 0.5,
                showarrow = FALSE,
                font = list(family = "Inter", size = 13, color = "#64748b")
              )
            )
          )
      )
    }
    
    num_vars <- c("credit_score", "dti", "ltv", "income_annum", "loan_amount", "loan_tenure_years", "total_assets", "loan_approved")
    cor_df <- df[, intersect(num_vars, names(df)), drop = FALSE]
    # Remove zero-variance columns if any
    cor_df <- cor_df[, sapply(cor_df, function(x) sd(x, na.rm = TRUE) > 0), drop = FALSE]
    
    cor_mat <- round(cor(cor_df, use = "pairwise.complete.obs"), 2)
    p <- plot_ly(x = colnames(cor_mat), y = rownames(cor_mat), z = cor_mat,
                 type = "heatmap", colorscale = "RdYlGn", zmin = -1, zmax = 1) %>%
      layout(
        title = list(
          text = paste0("Feature Correlation Matrix (n = ", comma(n), " / ", comma(total_n), "<br><sup>", flabel, "</sup>)"),
          font = list(family = "Inter", size = 14)
        ),
        margin = list(t = 50, b = 60, l = 100, r = 20)
      )
    return(p)
  }
  
  # Default fallback
  plot_ly()
}

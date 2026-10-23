# tests/check_assets.R
source(file.path("R", "load_data.R"))
df <- load_raw_data(file.path("data", "train.csv"), verbose = FALSE)

for (col in c("residential_assets_value", "commercial_assets_value", "luxury_assets_value", "bank_asset_value")) {
  vals <- as.numeric(df[[col]])
  cat(col, "-> Min:", min(vals), "Max:", max(vals), "\n")
}

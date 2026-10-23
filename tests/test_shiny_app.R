# tests/test_shiny_app.R
# Test that app.R parses and constructs the Shiny application object properly

cat("Testing app.R parsing and initialization...\n")

app_obj <- tryCatch({
  source("app.R", local = new.env())
}, error = function(e) {
  cat("ERROR loading app.R:\n", conditionMessage(e), "\n")
  NULL
})

if (!is.null(app_obj)) {
  cat("SUCCESS: app.R parsed and constructed successfully without any errors!\n")
} else {
  stop("app.R failed to load!")
}

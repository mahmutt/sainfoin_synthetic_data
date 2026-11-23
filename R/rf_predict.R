# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

library(randomForest)

# 1) Load the saved RF model
rf_model <- readRDS("ml_models/random_forest_model_y.rds")   # saved by R/rf_training.R

# 2) Read the field samples
new_data <- read.csv("data/field_samples.csv", fileEncoding = "UTF-8")

# 3) Select the feature columns (NDF, ADF, CP, CT)
X_new <- new_data[, c("NDF", "ADF", "CP", "CT")]

# 4) Predict
predictions <- predict(rf_model, newdata = X_new)

# 5) Add the results to the table
new_data$Predicted_Class <- predictions

# 6) Show the relevant columns
print(new_data[, c("sample_id", "Predicted_Class", "field", "date")])

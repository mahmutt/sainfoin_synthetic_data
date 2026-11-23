# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

library(e1071)
library(caret)

# 1) Load the saved SVM model
svm_model <- readRDS("ml_models/svm_model_y.rds")

# Load the preProcess object created and saved during training
preproc <- readRDS("ml_models/svm_preproc_y.rds")   # saved by R/svm_training.R

# 2) Read the field samples
new_data <- read.csv("data/field_samples.csv", fileEncoding = "UTF-8")

# 3) Select the feature columns
X_new <- new_data[, c("NDF", "ADF", "CP", "CT")]

# 4) Normalise the new data with the same scaler
X_new_scaled <- predict(preproc, X_new)

# 5) Predict
predictions <- predict(svm_model, newdata = X_new_scaled)

# 6) Add the predictions to the table
new_data$Predicted_Class <- predictions

# 7) Show the results
print(new_data[, c("sample_id", "Predicted_Class", "field", "date")])

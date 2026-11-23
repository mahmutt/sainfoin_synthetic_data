# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

library(xgboost)
library(caret)

# 1) Load the saved model
xgb_model <- xgb.load("ml_models/xgboost_model_y.model")

# 2) Load the preProcess object used for scaling
preproc <- readRDS("ml_models/xgboost_model_y.rds")

# 3) Read the field samples
new_data <- read.csv("data/field_samples.csv", fileEncoding = "UTF-8")

# 4) Select the feature columns
X_new <- new_data[, c("NDF", "ADF", "CP", "CT")]

# 5) Normalise with the scaler fitted during training
X_new_scaled <- predict(preproc, X_new)

# 6) Convert to DMatrix format
dnew <- xgb.DMatrix(data = as.matrix(X_new_scaled))

# 7) Predict
predictions <- predict(xgb_model, dnew)

# 8) Convert predictions to factors (with class names)
label_levels <- c("early", "late", "mature")   # same (alphabetical) order as in training
predicted_class <- factor(predictions, levels = 0:(length(label_levels)-1), labels = label_levels)

# 9) Add the results to the table
new_data$Predicted_Class <- predicted_class

# 10) Show the relevant columns
print(new_data[, c("sample_id", "Predicted_Class", "field", "date")])

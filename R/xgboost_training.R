# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

# Required packages
if (!require(xgboost)) install.packages("xgboost", dependencies = TRUE)
if (!require(caret)) install.packages("caret", dependencies = TRUE)
if (!require(ggplot2)) install.packages("ggplot2", dependencies = TRUE)
if (!require(reshape2)) install.packages("reshape2", dependencies = TRUE)

library(xgboost)
library(caret)
library(ggplot2)
library(reshape2)

# Read the dataset
df <- read.csv("data/synthetic_data.csv", sep = ",", header = TRUE)

# Target variable
target_col <- "Harvest_time"

# Convert categorical columns (other than the target) to factors
categorical_cols <- names(df)[sapply(df, is.character)]
categorical_cols <- setdiff(categorical_cols, target_col)

for (col in categorical_cols) {
  df[[col]] <- as.factor(df[[col]])
}

# Convert the target variable from factor to numeric (required by XGBoost)
df[[target_col]] <- as.factor(df[[target_col]])
label_levels <- levels(df[[target_col]])
df$label <- as.numeric(df[[target_col]]) - 1   # classes start at 0

# Training / test split
set.seed(42)
train_index <- createDataPartition(df$label, p = 0.8, list = FALSE)
train_data <- df[train_index, ]
test_data  <- df[-train_index, ]

# Scaling (fitted on the training data)
preproc <- preProcess(train_data[, c("NDF","ADF","CP","CT")], method = c("center","scale"))
train_scaled <- predict(preproc, train_data[, c("NDF","ADF","CP","CT")])
test_scaled  <- predict(preproc, test_data[, c("NDF","ADF","CP","CT")])

# XGBoost DMatrix
dtrain <- xgb.DMatrix(data = as.matrix(train_scaled), label = train_data$label)
dtest  <- xgb.DMatrix(data = as.matrix(test_scaled),  label = test_data$label)

# XGBoost model (multi-class)
num_class <- length(unique(df$label))

xgb_model <- xgboost(
  data = dtrain,
  objective = "multi:softmax",  # class prediction
  num_class = num_class,
  nrounds = 100,
  max_depth = 6,
  eta = 0.3,
  gamma = 0,
  subsample = 1,
  colsample_bytree = 1,
  verbose = 0
)

# Prediction
y_pred <- predict(xgb_model, dtest)

# Convert predictions back to factors
y_pred_factor <- factor(y_pred, levels = 0:(num_class-1), labels = label_levels)
y_true_factor <- factor(test_data$label, levels = 0:(num_class-1), labels = label_levels)

# Confusion matrix
cm <- confusionMatrix(y_pred_factor, y_true_factor)
print(cm)

# Confusion matrix plot
cm_table <- as.table(cm$table)
cm_df <- as.data.frame(cm_table)

ggplot(cm_df, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), color = "black", size = 8) +
  scale_fill_gradient(low = "#efedf5", high = "#746ab0") +
  theme_minimal() +
  labs(title = NULL,
       x = "True class", y = "Predicted class")+theme(
         axis.title.x = element_text(size = 18),  # axis titles
         axis.title.y = element_text(size = 18),
         axis.text.x  = element_text(size = 18),  # class names (x axis)
         axis.text.y  = element_text(size = 18)   # class names (y axis)
       )

# Additional metrics
acc <- cm$overall["Accuracy"]
precisions <- cm$byClass[,"Precision"]
recalls    <- cm$byClass[,"Recall"]
f1s        <- cm$byClass[,"F1"]

metrics <- data.frame(
  Metric = c("Accuracy", "F1-score (avg)", "Precision (avg)", "Recall (avg)"),
  Value  = c(
    round(acc, 3),
    round(mean(f1s, na.rm=TRUE), 3),
    round(mean(precisions, na.rm=TRUE), 3),
    round(mean(recalls, na.rm=TRUE), 3)
  )
)

print(metrics)

# Save the model
xgb.save(xgb_model, "ml_models/xgboost_model_y.model")
saveRDS(preproc, "ml_models/xgboost_model_y.rds")  # scaling parameters

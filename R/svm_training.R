# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

library(e1071)
library(caret)
library(ggplot2)
library(reshape2)

# Read the dataset
df <- read.csv("data/synthetic_data.csv", sep = ",", header = TRUE)

# Target variable
target_col <- "Harvest_time"

# Convert categorical variables other than Harvest_time to factors
categorical_cols <- names(df)[sapply(df, is.character)]
categorical_cols <- setdiff(categorical_cols, target_col)

for (col in categorical_cols) {
  df[[col]] <- as.factor(df[[col]])
}

# Convert the target variable to a factor
df[[target_col]] <- as.factor(df[[target_col]])

# Training / test split
set.seed(42)
train_index <- createDataPartition(df[[target_col]], p = 0.8, list = FALSE)
train_data <- df[train_index, ]
test_data  <- df[-train_index, ]

# Scaling (fitted on the training data)
preproc <- preProcess(train_data[, setdiff(names(train_data), target_col)], method = c("center", "scale"))
train_scaled <- train_data
train_scaled[, setdiff(names(train_data), target_col)] <- predict(preproc, train_data[, setdiff(names(train_data), target_col)])
test_scaled <- test_data
test_scaled[, setdiff(names(test_data), target_col)] <- predict(preproc, test_data[, setdiff(names(test_data), target_col)])

# SVM model (RBF kernel)


svm_model <- svm(
  Harvest_time ~ .,
  data = train_scaled,
  kernel = "radial",   # rbf in Python
  cost = 1,            # C=1.0 in Python
  probability = TRUE
)

# Prediction
y_pred <- predict(svm_model, newdata = test_scaled)

# Confusion matrix
cm <- confusionMatrix(y_pred, test_scaled[[target_col]])
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

saveRDS(svm_model, "ml_models/svm_model_y.rds")
saveRDS(preproc, "ml_models/svm_preproc_y.rds")  # scaling parameters

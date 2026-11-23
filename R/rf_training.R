# Run from the repository root (e.g. open sainfoin_synthetic_data.Rproj in RStudio).

# Required packages
if (!require(randomForest)) install.packages("randomForest", dependencies = TRUE)
if (!require(caret)) install.packages("caret", dependencies = TRUE)
if (!require(e1071)) install.packages("e1071", dependencies = TRUE) # required by caret
if (!require(ggplot2)) install.packages("ggplot2", dependencies = TRUE)
if (!require(reshape2)) install.packages("reshape2", dependencies = TRUE)

library(randomForest)
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

# Training / test split (80% training, 20% test)
set.seed(42)
train_index <- createDataPartition(df[[target_col]], p = 0.8, list = FALSE)
train_data <- df[train_index, ]
test_data  <- df[-train_index, ]

# Random Forest model
rf_model <- randomForest(Harvest_time ~ ., data = train_data, ntree = 100, importance = TRUE)

# Prediction
y_pred <- predict(rf_model, newdata = test_data)

# Confusion matrix
cm <- confusionMatrix(y_pred, test_data[[target_col]])
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
saveRDS(rf_model, "ml_models/random_forest_model_y.rds")
cat("Random Forest model saved: ml_models/random_forest_model_y.rds\n")

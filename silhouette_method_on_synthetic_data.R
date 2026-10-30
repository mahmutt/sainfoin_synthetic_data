# Load required packages
library(factoextra)
library(cluster)
library(readr)

# Read the dataset
df <- read.csv("synthetic_data.csv", sep = ",", header = TRUE)
mf <- df

# Select the columns to be used
selected_columns <- c("ADF", "NDF", "CP", "CT")
df <- df[, selected_columns]

# Standardize the data
df_scaled <- scale(df, center = TRUE, scale = TRUE)
df_scaled <- as.data.frame(df_scaled)  # Convert the standardized data into a data frame

# Calculate WCSS values
wcss <- function(k) {
  kmeans_result <- kmeans(df_scaled, centers = k, nstart = 25)
  return(kmeans_result$tot.withinss)
}

# Calculate WCSS values for different numbers of clusters
k_values <- 1:10
wcss_values <- sapply(k_values, wcss)

# Silhouette method
sm <- fviz_nbclust(df_scaled, kmeans, method = "silhouette") +
  labs(subtitle = "", x = "Number of clusters (k)",
       y = "Average Silhouette Width",
       title = NULL,
  ) +
  theme_grey() # Apply the plot theme

# Save the plot at 300 dpi
ggsave("silhouette_method_on_synthetic_data.png", plot = sm, width = 5, height = 5, dpi = 300)

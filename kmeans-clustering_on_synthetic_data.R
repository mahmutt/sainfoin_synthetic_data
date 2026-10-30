# Load required packages
library(readr)
library(factoextra)
library(ggplot2)

# Read the dataset
df <- read.csv("synthetic_data.csv", sep = ",", header = TRUE)

# Select the columns to be used
selected_columns <- c("ADF", "NDF", "CP", "CT")
df <- df[, selected_columns]

# Standardize the data
df_scaled <- scale(df)

# Perform K-Means clustering (3 clusters)
set.seed(123)  # Ensure reproducibility
km_model <- kmeans(df_scaled, centers = 3, nstart = 25)
kumeler <- km_model$cluster

# Extract cluster centers
km_centers <- km_model$centers

# Sort clusters according to CP values (high CP = early, medium CP = mature, low CP = late)
order_idx <- order(km_centers[, "CP"], decreasing = TRUE)

# Rename cluster labels as 1, 2, and 3
kumeler_reordered <- factor(kumeler, 
                            levels = order_idx, 
                            labels = c("1", "2", "3"))

# Generate the fviz_cluster plot
cluster_plot <- fviz_cluster(list(data = df_scaled, cluster = kumeler_reordered),
                             palette = c("#ac853a", "#feaecf", "#c5feae"), # Fixed colors
                             # ggtheme = theme_classic(),
                             geom = "point",
                             show.clust.cent = TRUE) +
  guides(fill = "none")

# Convert to a ggplot object and customize point symbols
final_plot <- cluster_plot + 
  geom_point(aes(shape = kumeler_reordered, color = kumeler_reordered),
             size = 3) +
  scale_shape_manual(
    values = c(16, 17, 15),   # 1 = triangle, 2 = square, 3 = circle
    labels = c("1", "2", "3")
  ) +
  scale_color_manual(
    values = c("1" = "#9d6236", "2" = "#ef5c79", "3" = "#42af85"),
    labels = c("1", "2", "3")
  ) +
  labs(shape = "Cluster", color = "Cluster", title = NULL) +
  theme(
    axis.title.x = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    axis.text.x  = element_text(size = 13),
    axis.text.y  = element_text(size = 13),
    legend.title = element_text(size = 13),
    legend.text  = element_text(size = 13)
  )

print(final_plot)

# Save the plot as a PNG file at 300 dpi
ggsave("kmeans-clustering_on_synthetic_data.png", plot = final_plot, dpi = 300,
       width = 8, height = 6, units = "in")

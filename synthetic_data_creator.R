# Install the required packages if they are not already installed
if (!require("MASS")) install.packages("MASS")
if (!require("dplyr")) install.packages("dplyr")
if (!require("tidyr")) install.packages("tidyr")
if (!require("Matrix")) install.packages("Matrix")
if (!require("psych")) install.packages("psych") # For visualizing correlations

library(MASS)
library(dplyr)
library(tidyr)
library(Matrix)
library(psych)

# Set the random seed for reproducibility
set.seed(123)

# Define the maturity stages
maturity_stages <- c("early", "mature", "late")

# Define the mean values for each maturity stage
means <- list(
  early = c(NDF = 46.14, ADF = 33.40, CP = 19.50, CT = 10.51),
  mature = c(NDF = 49.27, ADF = 37.21, CP = 14.50, CT = 6.96),
  late = c(NDF = 55.71, ADF = 40.15, CP = 13.05, CT = 4.26)
)

# Define the SEM values
sem_values <- c(NDF = 0.448, ADF = 0.626, CP = 0.193, CT = 0.138)
n_original <- 182
sd_values <- sem_values * sqrt(n_original)

cor_matrix <- matrix(c(
  1.00,  0.589, -0.683, -0.76,  # NDF
  0.589, 1.00,  -0.801, -0.75,  # ADF
  -0.683, -0.801, 1.00,   0.70,  # CP
  -0.76, -0.75,  0.70,    1.00   # CT
), nrow = 4, byrow = TRUE)


# Assign variable names to the correlation matrix
colnames(cor_matrix) <- rownames(cor_matrix) <- names(sd_values)

# Ensure that the correlation matrix is positive definite
cor_matrix <- as.matrix(nearPD(cor_matrix, corr = TRUE, maxit = 500)$mat)

# Display the adjusted correlation matrix
print("Adjusted Correlation Matrix:")
print(cor_matrix)

# Calculate the covariance matrix
cov_matrix <- diag(sd_values) %*% cor_matrix %*% diag(sd_values)

# Generate synthetic data for each maturity stage
synthetic_data <- data.frame()

for (stage in maturity_stages) {
  # Sample from a multivariate normal distribution
  sim_values <- mvrnorm(n = 100, mu = means[[stage]], Sigma = cov_matrix)
  
  # Convert the simulated values into a data frame
  sim_df <- as.data.frame(sim_values)
  sim_df$Harvest_time <- stage
  
  synthetic_data <- bind_rows(synthetic_data, sim_df)
}

# Arrange the data by placing the target variable in the first column
synthetic_data <- synthetic_data %>%
  dplyr::select(Harvest_time, dplyr::everything())

# Display the first few rows of the dataset
head(synthetic_data)

# Check and visualize the correlations
correlation_check <- synthetic_data %>%
  dplyr::group_by(Harvest_time) %>%
  dplyr::summarize(
    Corr_NDF_ADF = cor(NDF, ADF),
    Corr_NDF_CP = cor(NDF, CP),
    Corr_NDF_CT = cor(NDF, CT),
    Corr_ADF_CP = cor(ADF, CP),
    Corr_ADF_CT = cor(ADF, CT),
    Corr_CP_CT = cor(CP, CT)
  )

print("Correlations in the Generated Data:")
print(correlation_check)

# Calculate the correlation matrix for the entire dataset
correlation_matrix <- synthetic_data %>%
  dplyr::select(NDF, ADF, CP, CT) %>%
  cor()

print("Correlation Matrix for the Entire Dataset:")
print(correlation_matrix)

# Visualize the correlation matrix
if (require(corrplot)) {
  corrplot(correlation_matrix, method = "color", type = "upper",
           order = "hclust", tl.col = "black", tl.srt = 45)
}

# Export the synthetic dataset to a CSV file
write.csv(synthetic_data, file = "synthetic_data.csv", row.names = FALSE)

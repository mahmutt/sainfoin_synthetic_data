setwd("C:/Users/mahmu/OneDrive/Desktop/core/DOKTORA-TEZ/tez-teslim/SON/R-kodlar")
getwd()
# Gerekli k??t??phaneleri y??kle
if (!require("MASS")) install.packages("MASS")
if (!require("dplyr")) install.packages("dplyr")
if (!require("tidyr")) install.packages("tidyr")
if (!require("Matrix")) install.packages("Matrix")
if (!require("psych")) install.packages("psych") # Korelasyonlar?? g??rselle??tirmek i??in

library(MASS)
library(dplyr)
library(tidyr)
library(Matrix)
library(psych)

# Set seed for reproducibility
set.seed(123)

# Verileri haz??rla
maturity_stages <- c("erken", "olgun", "gec")

# Ortalama de??erler (her evre i??in vekt??r olarak)
means <- list(
  erken = c(NDF = 46.14, ADF = 33.40, CP = 19.50, CT = 10.51),
  olgun = c(NDF = 49.27, ADF = 37.21, CP = 14.50, CT = 6.96),
  gec = c(NDF = 55.71, ADF = 40.15, CP = 13.05, CT = 4.26)
)

# SEM de??erleri
sem_values <- c(NDF = 0.448, ADF = 0.626, CP = 0.193, CT = 0.138)
n_original <- 182
sd_values <- sem_values * sqrt(n_original)

# ??stedi??iniz korelasyon de??erlerine daha yak??n bir matris olu??tural??m
#cor_matrix <- matrix(c(
  #1.00, 0.928, -0.763, -0.60,  # NDF
  #0.928, 1.00, -0.771, -0.55,  # ADF
  #-0.763, -0.771, 1.00, 0.68,  # CP
  #-0.60, -0.55, 0.68, 1.00   # CT
#), nrow = 4, byrow = TRUE)


cor_matrix <- matrix(c(
  1.00, 0.589, -0.683, -0.76,  # NDF
  0.589, 1.00, -0.801, -0.75,  # ADF
  -0.683, -0.801, 1.00, 0.70,  # CP
  -0.76, -0.75, 0.70, 1.00   # CT
), nrow = 4, byrow = TRUE)

#korelasyon de??erlerini vermeden CT'nin korelasyon tahmini de??erleri
#CT->NDF=-0.66
#CT->ADF=-0.45
#CT->CP=0.74

#LAb data CT'nin korelasyon de??erleri
#CT->NDF=-0.83
#CT->ADF=-0.79
#CT->CP=0.62

#ORTALAMA ALDIM
#CT->NDF=-0.66
#CT->ADF=-0.45
#CT->CP=0.68

# ??simleri ata
colnames(cor_matrix) <- rownames(cor_matrix) <- names(sd_values)

# Korelasyon matrisinin pozitif tan??ml?? oldu??undan emin ol
cor_matrix <- as.matrix(nearPD(cor_matrix, corr = TRUE, maxit = 500)$mat)

# D??zeltilmi?? korelasyon matrisini g??ster
print("D??zeltilmi?? Korelasyon Matrisi:")
print(cor_matrix)

# Kovaryans matrisini hesapla
cov_matrix <- diag(sd_values) %*% cor_matrix %*% diag(sd_values)

# Her b??y??me evresi i??in sentetik veri ??ret
synthetic_data <- data.frame()

for (stage in maturity_stages) {
  # ??ok de??i??kenli normal da????l??mdan ??rneklem al
  sim_values <- mvrnorm(n = 100, mu = means[[stage]], Sigma = cov_matrix)
  
  # Veriyi data frame'e d??n????t??r
  sim_df <- as.data.frame(sim_values)
  sim_df$Harvest_time <- stage
  
  
  synthetic_data <- bind_rows(synthetic_data, sim_df)
}

# Veriyi d??zenle
synthetic_data <- synthetic_data %>%
  dplyr::select(Harvest_time, dplyr::everything())

# ??lk birka?? sat??r?? g??ster
head(synthetic_data)

# Korelasyonlar?? kontrol et ve g??rselle??tir
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

print("??retilen Verideki Korelasyonlar:")
print(correlation_check)

# Korelasyon matrisini g??rselle??tirme
correlation_matrix <- synthetic_data %>%
  dplyr::select(NDF, ADF, CP, CT) %>%
  cor()

print("T??m Veri ????in Korelasyon Matrisi:")
print(correlation_matrix)

# Korelasyon matrisini g??rselle??tir
if (require(corrplot)) {
  corrplot(correlation_matrix, method = "color", type = "upper", 
           order = "hclust", tl.col = "black", tl.srt = 45)
}

# CSV'ye yazma
write.csv(synthetic_data, file = "sentetik_veri_n_X_cor.csv", row.names = FALSE)
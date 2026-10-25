setwd("C:/Users/mahmu/OneDrive/Desktop/core/DOKTORA-TEZ/tez-teslim/SON/R-kodlar")
getwd()

# Kütüphane yükleme
library(factoextra)
library(cluster)
library(readr)

# Verinin okunması
df <- read.csv("sentetik_veri_n_X_cor.csv", sep = ",", header = TRUE)
mf<-df

# Kullan??lacak s??tunlar?? se??
selected_columns <- c("ADF", "NDF", "CP", "CT")
df <- df[, selected_columns]

# Standartla??t??rma
df_scaled <- scale(df, center=TRUE, scale=TRUE)
df_scaled <- as.data.frame(df_scaled)  # Standartla??t??r??lan veriyi veri ??er??evesine d??n????t??rme

# WCSS değerlerini hesaplamak
wcss <- function(k) {
  kmeans_result <- kmeans(df_scaled, centers = k, nstart = 25)
  return(kmeans_result$tot.withinss)
}

# Farklı küme sayıları için WCSS değerleri
k_values <- 1:10
wcss_values <- sapply(k_values, wcss)

wcss_values
  
# Elbow method
em <- fviz_nbclust(df_scaled, kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2, 
             color = "#4682b4", 
             #linewidth = 0.63,
             )+
  labs(subtitle = "", x = "K\u00FCme sayısı (k)",
       y = "Toplam K\u00FCme İ\u00E7i Kareler Toplamı (wss)",
       title = NULL,
       )+
  theme_grey() # 👈 burada tema eklendi

# Grafiği 300 dpi olarak kaydet
ggsave("elbow_method_on_dummy.png", plot = em, width = 5, height = 5, dpi = 300)



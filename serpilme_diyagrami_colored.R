setwd("C:/Users/mahmu/OneDrive/Desktop/core/DOKTORA-TEZ/tez-teslim/SON/R-kodlar")
getwd()
# Gerekli k??t??phanelerin y??klenmesi
library(readr)
library(caret)
library(class)

# Verinin okunmas??
modelData <- read.csv("sentetik_veri_n_X_cor.csv", sep = ",", header = TRUE)
#View(modelData)

#b??t??n de??i??kenlerin t??rlerini g??stermek i??in str(modelData)
str(modelData)
data(modelData)

# Paketleri y??kle
library(ggplot2)

# ??rnek 3.54: GGally paketiyle serpilme grafi??i matrisi
suppressPackageStartupMessages(installed <- require(GGally))
if (!installed) {
  install.packages("GGally", repos="https://cloud.r-project.org")  
  suppressPackageStartupMessages(require(GGally))
}

my_colors <- c("erken" = "#c5feae",  # turkuaz
               "olgun" = "#feaecf",  # yeşil
               "gec"   = "#ac853a")  # mor-pembe

# Grafi??i olu??tur
p <- ggpairs(
  modelData, 
  columns = 5:1, 
  aes(color = Harvest_time)
) + 
  scale_color_manual(values = my_colors) + 
  scale_fill_manual(values = my_colors) + 
  theme_bw()


print(p)

# 300 dpi kayıt
ggsave("ser_n_182_cor_300dpi_colored.png", plot = p, dpi = 300,
       width = 10, height = 8, units = "in")





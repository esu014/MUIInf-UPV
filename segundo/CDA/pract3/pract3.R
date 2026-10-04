# ========================================================
# Practical 3: Visualisation using qplot()
# ========================================================
library(ggplot2)

# Cargar el dataset asegurando nombres sintácticamente válidos
queratocono <- read.csv("dataset/Queratocono.csv", header = TRUE, sep = ",", check.names = TRUE)

# Verificamos estructura
str(queratocono)
head(queratocono)

# ========================================================
# Exercise 1: Relation between K1 and K2 with smoother
# ========================================================

# 1.a) Smoother por defecto (LOESS)
p1_loess <- qplot(K1, K2, data = queratocono, geom = c("point", "smooth"))
p1_loess

pdf("outputs/fig1_k1_k2_loess.pdf", width = 6, height = 5)
print(p1_loess)
dev.off()

# 1.b) Smoother con regresión lineal (method = "lm")
p1_lm <- qplot(K1, K2, data = queratocono, geom = c("point", "smooth"), method = "lm")
p1_lm

pdf("outputs/fig1_k1_k2_lm.pdf", width = 6, height = 5)
print(p1_lm)
dev.off()

# ========================================================
# Exercise 2: Relation between K1 and K2 by factor(na) with linear fit
# ========================================================
p2 <- qplot(K1, K2, 
            data = queratocono, 
            colour = factor(na), 
            geom = c("point", "smooth"), 
            method = "lm", 
            main = "Relation between K1 and K2")
p2

pdf("outputs/fig2_relation_k1_k2_by_na.pdf", width = 6, height = 5)
print(p2)
dev.off()

# ========================================================
# Exercise 3: Scatter plot of K1 vs K1.salida
# ========================================================
p3 <- qplot(K1, K1.salida, 
            data = queratocono, 
            geom = "point")
p3

pdf("outputs/fig3_relation_k1_k1salida.pdf", width = 6, height = 5)
print(p3)
dev.off()

# ========================================================
# Exercise 4: Bar chart/histogram of factor(grosor) filled by factor(na)
# ========================================================
p4 <- qplot(factor(grosor), 
            data = queratocono, 
            geom = "bar", 
            fill = factor(na))
p4

pdf("outputs/fig4_hist_grosor_by_na.pdf", width = 6, height = 5)
print(p4)
dev.off()

# ========================================================
# Exercise 5: Scatter plot K1 vs K2 faceted by diam and na with alpha = 1/3
# ========================================================
p5 <- qplot(K1, K2, 
            data = queratocono, 
            facets = diam ~ na, 
            colour = factor(grosor), 
            alpha = I(1/3))
p5

pdf("outputs/fig5_scatter_facets_diam_na.pdf", width = 7, height = 6)
print(p5)
dev.off()

# ========================================================
# Exercise 6: Boxplots of K1 and K2 vs factor(grosor)
# ========================================================

# 6.a) Boxplot de K1 vs grosor
p6_k1 <- qplot(factor(grosor), K1, 
               data = queratocono, 
               geom = "boxplot")
p6_k1

pdf("outputs/fig6_boxplot_k1_grosor.pdf", width = 6, height = 5)
print(p6_k1)
dev.off()

# 6.b) Boxplot de K2 vs grosor
p6_k2 <- qplot(factor(grosor), K2, 
               data = queratocono, 
               geom = "boxplot")
p6_k2

pdf("outputs/fig6_boxplot_k2_grosor.pdf", width = 6, height = 5)
print(p6_k2)
dev.off()
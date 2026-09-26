# ==========================================
# Exercise 1: Inspection of data
# ==========================================

# 1. Load titanic.csv (assuming it is in your working directory)
titanic <- read.csv("titanic.csv", header = TRUE, sep = ",")

# Show initial column names
names(titanic)

# 2. Remove redundant column 'X'
titanic <- subset(titanic, select = -X)

# 3. Inspection commands
titanic
head(titanic)
summary(titanic)
str(titanic)    # Extremely useful to see types (quantitative vs categorical)
plot(titanic)

# ==========================================
# Exercise 2: Working with basic graphics
# ==========================================

# Cargar el dataset cars.csv
cars <- read.csv("cars.csv", header = TRUE, sep = ",")
head(cars)

# 2.1 Plot distance against speed using $ syntax
plot(cars$speed, cars$dist)

# 2.2 Histogram of distance
hist(cars$dist)

# 2.3 Histogram of speed
hist(cars$speed)

# 2.4 Modified plots with titles, axis labels and colors, saved as PDF files

# Graphic 1: Scatter plot
pdf("plot_cars_scatter.pdf")
plot(cars$speed, cars$dist,
     main = "Stopping Distance vs Speed",
     xlab = "Speed (mph)",
     ylab = "Stopping Distance (ft)",
     col = "darkblue",
     pch = 19)
dev.off()

# Graphic 2: Distance histogram
pdf("plot_cars_hist_dist.pdf")
hist(cars$dist,
     main = "Distribution of Stopping Distance",
     xlab = "Stopping Distance (ft)",
     ylab = "Frequency",
     col = "steelblue",
     border = "white")
dev.off()

# Graphic 3: Speed histogram
pdf("plot_cars_hist_speed.pdf")
hist(cars$speed,
     main = "Distribution of Speed",
     xlab = "Speed (mph)",
     ylab = "Frequency",
     col = "coral",
     border = "white")
dev.off()

# ========================================================
# Exercise 3: Transformations of variables and datasets
# ========================================================

# Aseguramos eliminar la primera columna redundante si no se hizo antes
# (verificamos si existe la columna X o eliminamos por posición [, -1])
if ("X" %in% colnames(cars)) {
  cars <- subset(cars, select = -X)
}
head(cars)

# 3.1 Construct a new data frame with the two new cars
new_cars <- data.frame(
  speed = c(21, 34),
  dist  = c(47, 87)
)
new_cars

# 3.2 Add the constructed data frame to the cars data frame
cars_extended <- rbind(cars, new_cars)
tail(cars_extended)  # Comprobar que se han añadido al final

# 3.3 Sort the data by column speed (ascending)

# Method 1: Using order() command directly
cars_sorted1 <- cars_extended[order(cars_extended$speed), ]

# Method 2: Combining with() and order() commands
cars_sorted2 <- cars_extended[with(cars_extended, order(speed)), ]

# Verificamos que ambos dan el mismo resultado
identical(cars_sorted1, cars_sorted2)

# Mostramos los últimos registros donde se ubican las velocidades altas añadidas (21 y 34)
tail(cars_sorted1, 10)

# ========================================================
# Exercise 4: Data manipulation
# ========================================================

# Cargar el archivo airquality.csv
air <- read.csv("airquality.csv", header = TRUE, sep = ",")

# Si contiene una primera columna redundante de índices (ej. 'X'), la eliminamos
if ("X" %in% colnames(air)) {
  air <- subset(air, select = -X)
}

# 1. Extract the first 2 rows and print them to the console
head(air, 2)
# O bien mediante indexación por corchetes:
air[1:2, ]

# 2. How many observations (rows) are there in this data frame?
nrow(air)

# 3. What is the value of Ozone in the 40th row?
air[40, "Ozone"]
# O bien: air$Ozone[40]

# 4. How many missing values (NA) are there in the Ozone column?
sum(is.na(air$Ozone))

# 5. What is the mean of the Ozone column excluding missing values?
mean(air$Ozone, na.rm = TRUE)

# 6. Subset where Ozone > 31 and Temp > 90, and mean of Solar.R in this subset
subset_air <- subset(air, Ozone > 31 & Temp > 90)
subset_air

mean(subset_air$Solar.R, na.rm = TRUE)

# ========================================================
# Exercise 5: Data transformation (2)
# ========================================================

# 1. Discretise Ozone into 5 bins of equal width and a 6th bin for NA
# cut() with 'breaks = 5' partitions the range into 5 intervals of equal width
ozone_cut <- cut(air$Ozone, breaks = 5, labels = paste0("bin", 1:5), include.lowest = TRUE)

# Convert to character, replace NA with 'binNA', and convert back to factor
air$Ozone_bin <- as.character(ozone_cut)
air$Ozone_bin[is.na(air$Ozone_bin)] <- "binNA"
air$Ozone_bin <- factor(air$Ozone_bin, levels = c(paste0("bin", 1:5), "binNA"))

# Check distribution of the bins
table(air$Ozone_bin)


# 2. Discretise Solar (Solar.R) into 4 bins of equal size and a 5th bin for NA
# "Equal size" refers to equal frequency (quantiles: 0%, 25%, 50%, 75%, 100%)
q_solar <- quantile(air$Solar.R, probs = seq(0, 1, 0.25), na.rm = TRUE)
solar_cut <- cut(air$Solar.R, breaks = q_solar, labels = paste0("bin", 1:4), include.lowest = TRUE)

air$Solar_bin <- as.character(solar_cut)
air$Solar_bin[is.na(air$Solar_bin)] <- "binNA"
air$Solar_bin <- factor(air$Solar_bin, levels = c(paste0("bin", 1:4), "binNA"))

# Check distribution of the bins
table(air$Solar_bin)


# 3. Create column AbsDay: number of days passed from Month=5 and Day=1
# Using as.Date() with arbitrary non-leap year (e.g. 1973, when the data was collected)
current_dates <- as.Date(paste(1973, air$Month, air$Day, sep = "-"))
start_date    <- as.Date("1973-05-01")

# Days passed: on 1973-05-01 it is 0 days passed (or +1 if considered as 1-indexed day number)
air$AbsDay <- as.numeric(current_dates - start_date)

# Preview first and last rows
head(air[, c("Month", "Day", "AbsDay", "Ozone_bin", "Solar_bin")])
tail(air[, c("Month", "Day", "AbsDay", "Ozone_bin", "Solar_bin")])

# ========================================================
# Exercise 6: Data transformation (3)
# ========================================================

# Aseguramos tener el dataset cargado y sin la columna redundante 'X'
if (!exists("titanic")) {
  titanic <- read.csv("titanic.csv", header = TRUE, sep = ",")
  if ("X" %in% colnames(titanic)) {
    titanic <- subset(titanic, select = -X)
  }
}

# 6.1 Numerise the class column: Crew = 4, 1st = 3, 2nd = 2, 3rd = 1
# Podemos mapear los valores con factor() asignando levels y labels numéricos,
# o mediante un vector con nombres:
class_mapping <- c("3rd" = 1, "2nd" = 2, "1st" = 3, "Crew" = 4)
titanic$Class_num <- class_mapping[as.character(titanic$Class)]

# Comprobamos la correspondencia
table(titanic$Class, titanic$Class_num)


# 6.2 Transform titanic into titanic2 (individual passengers using Freq)
# Replicamos cada fila tantas veces como indique su valor en 'Freq'
# Las filas con Freq == 0 no se replicarán (repite 0 veces)
titanic2 <- titanic[rep(seq_len(nrow(titanic)), titanic$Freq), ]

# Eliminamos la columna Freq ya que cada fila ahora representa a 1 único pasajero
titanic2 <- subset(titanic2, select = -Freq)

# Comprobamos el número total de pasajeros individuales (debe sumar 2201)
nrow(titanic2)
head(titanic2)


# 6.3 Compare plots of the original titanic data frame vs the new one (titanic2)
# Generamos y guardamos ambos gráficos para ver la diferencia

# Gráfico 1: Dataset agregado original
# png("results/plot_titanic_original.png")
pdf("results/plot_titanic_original.pdf")
plot(titanic, main = "Original Titanic (Aggregated Frequencies)")
dev.off()

# Gráfico 2: Dataset individual descompactado
# png("results/plot_titanic2_individual.png")
pdf("results/plot_titanic2_individual.pdf")
# Convertimos las columnas a factor si no lo están para que plot() muestre mosaicos/barras
titanic2_factors <- as.data.frame(unclass(titanic2), stringsAsFactors = TRUE)
plot(titanic2_factors, main = "De-aggregated Titanic (Individual Passengers)")
dev.off()

# ========================================================
# Exercise 7: Data selection
# ========================================================

# Aseguramos tener los datasets limpios (solo columnas numéricas base)
# Para air: usamos las columnas numéricas originales
air_num <- air[, c("Ozone", "Solar.R", "Wind", "Temp", "Month", "Day")]

# Para cars: speed y dist
cars_clean <- cars[, c("speed", "dist")]


# 7.1 Correlation matrix for 'air' dataset
# Usamos use = "complete.obs" para omitir los valores NA presentes en Ozone y Solar.R
cor_air <- cor(air_num, use = "complete.obs")
round(cor_air, 3)

# 7.2 Correlation matrix for 'cars' dataset
cor_cars <- cor(cars_clean)
round(cor_cars, 3)


# 7.3 Simple random sampling of 50 examples from 'air'
set.seed(123) # Fijamos semilla para reproducibilidad
idx_simple <- sample(1:nrow(air), size = 50, replace = FALSE)
sample_simple <- air[idx_simple, ]

nrow(sample_simple)
head(sample_simple)


# 7.4 Stratified random sampling of 5 examples of each month from 'air'
# El dataset contiene observaciones de los meses 5, 6, 7, 8 y 9
set.seed(123)

# Método usando split() y lapply():
stratified_indices <- unlist(lapply(split(1:nrow(air), air$Month), function(idx) {
  sample(idx, size = 5, replace = FALSE)
}))

sample_stratified <- air[stratified_indices, ]

# Verificamos que hay exactamente 5 ejemplos por mes y 25 filas en total
table(sample_stratified$Month)
nrow(sample_stratified)

# ========================================================
# Exercise 8: Data aggregation
# ========================================================

# Cargar sales (o sales-1.txt)
sales <- read.table("sales-1.txt", header = TRUE, stringsAsFactors = FALSE)
head(sales)
colnames(sales)

# 8.1 Calculate total sales per store using aggregate()
total_sales_store <- aggregate(sales_amount ~ store, data = sales, FUN = sum)
print(total_sales_store)

# 8.2 Find the average sales amount for each product category
avg_sales_cat <- aggregate(sales_amount ~ product_category, data = sales, FUN = mean)
print(avg_sales_cat)

# 8.3 Group by store and product category, calculate total sales for each combination
total_store_cat <- aggregate(sales_amount ~ store + product_category, data = sales, FUN = sum)
print(total_store_cat)

# 8.4 Plot total sales per store in a bar chart (labeled axes and title)
# 8.5 Save the bar chart as a PDF
pdf("plot_sales_per_store.pdf", width = 7, height = 5)
barplot(total_sales_store$sales_amount,
        names.arg = total_sales_store$store,
        col = "steelblue",
        main = "Total Sales per Store",
        xlab = "Store",
        ylab = "Total Sales Amount",
        border = "black")
dev.off()

# ========================================================
# Exercise 9: Merging Datasets
# ========================================================

# 9.1 Load both datasets into R
customers <- read.table("customers.txt", header = TRUE, stringsAsFactors = FALSE)
orders    <- read.table("orders.txt", header = TRUE, stringsAsFactors = FALSE)

# Preview initial structure
head(customers)
head(orders)

# 9.2 Merge datasets by customer_id using inner join
# In R, merge() performs an inner join by default (all = FALSE)
customer_orders <- merge(customers, orders, by = "customer_id", all = FALSE)
head(customer_orders)
nrow(customer_orders)

# 9.3 How many unique customers are there in the merged dataset?
unique_customers <- length(unique(customer_orders$customer_id))
unique_customers

# 9.4 Find the total number of orders placed by each customer
orders_per_customer <- table(customer_orders$customer_id)
orders_per_customer

# 9.5 Save the merged dataset as customer_orders.csv
write.csv(customer_orders, file = "customer_orders.csv", row.names = FALSE)
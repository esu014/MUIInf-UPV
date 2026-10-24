###################################################################
# Exercise 1: Load and inspect the dataset
###################################################################

raw_database <- read.csv(
  "dataset/HousePricesData-Address-City-Features_fromZillow.csv",
  header = TRUE,
  sep = ";",
  check.names = TRUE
)

database <- subset(raw_database, select = -street)

str(database)
summary(database)

###################################################################
# Exercise 2: Explore relationships with house prices
###################################################################

library(lattice)

attach(database)
forplot <- make.groups(
  bath = data.frame(value = bath, zipcode, city, state, price),
  year = data.frame(value = year, zipcode, city, state, price),
  bed = data.frame(value = bed, zipcode, city, state, price),
  rooms = data.frame(value = rooms, zipcode, city, state, price),
  SqFt = data.frame(value = SqFt, zipcode, city, state, price)
)
detach(database)

price_plot <- xyplot(
  price ~ value | which,
  data = forplot,
  scales = list(relation = "free"),
  xlab = "Predictor value",
  ylab = "House price",
  main = "House price versus numerical features"
)

dir.create("outputs", showWarnings = FALSE)
pdf("outputs/price_relationships.pdf")
print(price_plot)
invisible(dev.off()) # Cierra el PDF sin mostrar ese resultado

###################################################################
# Exercise 3: Random train/test split
###################################################################

set.seed(123)

train_indices <- sample(
  seq_len(nrow(database)),
  size = floor(0.75 * nrow(database)),
  replace = FALSE
)

data_train <- database[train_indices, ]
data_test <- database[-train_indices, ]

split_summary <- data.frame(
  Set = c("Training", "Test"),
  Observations = c(nrow(data_train), nrow(data_test)),
  Percentage = round(
    100 * c(nrow(data_train), nrow(data_test)) / nrow(database),
    2
  )
)

cat("\n--- Train/test split ---\n")
print(split_summary, row.names = FALSE)

###################################################################
# Exercise 4: Train regression models
###################################################################

library(rpart)
library(nnet)

model_formula <- price ~ year + bath + bed + rooms + SqFt

model_lm <- lm(
  model_formula,
  data = data_train
)

set.seed(123)

model_tree <- rpart(
  model_formula,
  data = data_train,
  method = "anova"
)

predictors <- c("year", "bath", "bed", "rooms", "SqFt")

predictor_means <- sapply(data_train[predictors], mean)
predictor_sds <- sapply(data_train[predictors], sd)

price_mean <- mean(data_train$price)
price_sd <- sd(data_train$price)

train_scaled <- data_train[c(predictors, "price")]

train_scaled[predictors] <- scale(
  data_train[predictors],
  center = predictor_means,
  scale = predictor_sds
)

train_scaled$price <- (
  data_train$price - price_mean
) / price_sd

set.seed(123)

model_nn <- nnet(
  model_formula,
  data = train_scaled,
  size = 12,
  skip = TRUE,
  linout = TRUE,
  maxit = 1000,
  trace = FALSE
)

cat("\n--- Model training ---\n")
cat("Linear model and regression tree fitted.\n")
cat("Neural network convergence code:", model_nn$convergence, "\n")

###################################################################
# Exercise 5: Inspect and visualise the models
###################################################################

cat("\n--- Linear model summary ---\n")
print(summary(model_lm))

cat("\n--- Regression tree summary ---\n")
print(summary(model_tree))

cat("\n--- Neural network summary ---\n")
print(summary(model_nn))

pdf("outputs/regression_tree.pdf")

plot(
  model_tree,
  uniform = TRUE,
  margin = 0.1,
  main = "Regression tree for house prices"
)

text(
  model_tree,
  use.n = TRUE,
  all = FALSE,
  cex = 0.8
)

invisible(dev.off())

###################################################################
# Exercise 6: Prune the regression tree
###################################################################

cat("\n--- Tree complexity table ---\n")
printcp(model_tree)

cp_table <- model_tree$cptable

best_row <- which.min(cp_table[, "xerror"])

error_limit <- cp_table[best_row, "xerror"] +
  cp_table[best_row, "xstd"]

# Choose the simplest tree within one standard error of the minimum.
eligible_rows <- which(cp_table[, "xerror"] <= error_limit)

selected_row <- eligible_rows[
  which.min(cp_table[eligible_rows, "nsplit"])
]

selected_cp <- cp_table[selected_row, "CP"]

model_pruned <- prune(model_tree, cp = selected_cp)

cat("\n--- Selected pruning configuration ---\n")
print(cp_table[selected_row, , drop = FALSE])

cat("\n--- Pruned tree ---\n")
print(model_pruned)

###################################################################
# Export model figures for the report
###################################################################

pdf("outputs/model_figures.pdf", width = 11, height = 7)

par(mar = c(2, 2, 3, 2))

plot(
  model_tree,
  uniform = TRUE,
  margin = 0.12,
  main = "Original regression tree"
)
text(model_tree, use.n = TRUE, all = FALSE, cex = 0.65)

par(mar = c(5, 5, 4, 2) + 0.1)

plotcp(
  model_tree,
  main = "Cross-validation and tree complexity"
)

par(mar = c(2, 2, 3, 2))

plot(
  model_pruned,
  uniform = TRUE,
  margin = 0.12,
  main = "Pruned regression tree"
)
text(model_pruned, use.n = TRUE, all = FALSE, cex = 0.85)

invisible(dev.off())

###################################################################
# Exercise 7: Evaluate regression models
###################################################################

# Apply the training transformation to the test predictors.
test_scaled <- as.data.frame(
  scale(
    data_test[predictors],
    center = predictor_means,
    scale = predictor_sds
  )
)

predictions_train <- list(
  Linear = predict(model_lm, newdata = data_train),
  Tree = predict(model_tree, newdata = data_train),
  Pruned_tree = predict(model_pruned, newdata = data_train),
  Neural_network = as.numeric(
    predict(model_nn, newdata = train_scaled)
  ) * price_sd + price_mean
)

predictions_test <- list(
  Linear = predict(model_lm, newdata = data_test),
  Tree = predict(model_tree, newdata = data_test),
  Pruned_tree = predict(model_pruned, newdata = data_test),
  Neural_network = as.numeric(
    predict(model_nn, newdata = test_scaled)
  ) * price_sd + price_mean
)

calculate_metrics <- function(actual, predicted) {
  errors <- actual - predicted

  c(
    RMSE = sqrt(mean(errors^2)),
    MAE = mean(abs(errors))
  )
}

train_metrics <- t(
  sapply(
    predictions_train,
    function(predicted) {
      calculate_metrics(data_train$price, predicted)
    }
  )
)

test_metrics <- t(
  sapply(
    predictions_test,
    function(predicted) {
      calculate_metrics(data_test$price, predicted)
    }
  )
)

performance <- data.frame(
  Model = names(predictions_train),
  Train_RMSE = train_metrics[, "RMSE"],
  Train_MAE = train_metrics[, "MAE"],
  Test_RMSE = test_metrics[, "RMSE"],
  Test_MAE = test_metrics[, "MAE"],
  row.names = NULL
)

cat("\n--- Model performance ---\n")
print(performance, digits = 7, row.names = FALSE)


###################################################################
# Exercise 8: Tune the neural network using cross-validation
###################################################################

parameter_grid <- expand.grid(
  size = c(3, 6, 12),
  decay = c(0.01, 0.1, 1)
)

set.seed(456)

fold_id <- sample(
  rep(1:5, length.out = nrow(data_train))
)

tuning_results <- parameter_grid

for (i in seq_len(nrow(parameter_grid))) {
  cv_predictions <- numeric(nrow(data_train))
  nonconverged <- 0L

  for (fold in 1:5) {
    fold_train <- data_train[fold_id != fold, ]
    fold_valid <- data_train[fold_id == fold, ]

    # Fit preprocessing within each fold to avoid validation leakage.
    fold_means <- sapply(fold_train[predictors], mean)
    fold_sds <- sapply(fold_train[predictors], sd)

    fold_price_mean <- mean(fold_train$price)
    fold_price_sd <- sd(fold_train$price)

    fold_train_scaled <- as.data.frame(
      scale(
        fold_train[predictors],
        center = fold_means,
        scale = fold_sds
      )
    )

    fold_train_scaled$price <- (
      fold_train$price - fold_price_mean
    ) / fold_price_sd

    fold_valid_scaled <- as.data.frame(
      scale(
        fold_valid[predictors],
        center = fold_means,
        scale = fold_sds
      )
    )

    set.seed(1000 + fold)

    fold_model <- nnet(
      model_formula,
      data = fold_train_scaled,
      size = parameter_grid$size[i],
      decay = parameter_grid$decay[i],
      skip = TRUE,
      linout = TRUE,
      maxit = 2000,
      trace = FALSE
    )

    cv_predictions[fold_id == fold] <- as.numeric(
      predict(fold_model, newdata = fold_valid_scaled)
    ) * fold_price_sd + fold_price_mean

    nonconverged <- nonconverged +
      as.integer(fold_model$convergence != 0)
  }

  fold_metrics <- calculate_metrics(
    data_train$price,
    cv_predictions
  )

  tuning_results$CV_RMSE[i] <- fold_metrics["RMSE"]
  tuning_results$CV_MAE[i] <- fold_metrics["MAE"]
  tuning_results$Nonconverged_fits[i] <- nonconverged

  cat(
    "Completed configuration", i, "of",
    nrow(parameter_grid), "\n"
  )
}

cat("\n--- Neural network tuning results ---\n")
print(tuning_results, digits = 7, row.names = FALSE)

# Require convergence in all folds before selecting a configuration.
eligible <- which(tuning_results$Nonconverged_fits == 0)

if (length(eligible) == 0) {
  stop("No configuration converged in every fold. Review optimisation.")
}

best_index <- eligible[
  order(
    tuning_results$CV_RMSE[eligible],
    tuning_results$size[eligible]
  )[1]
]

best_parameters <- tuning_results[best_index, ]

cat("\n--- Selected neural network configuration ---\n")
print(best_parameters, digits = 7, row.names = FALSE)

set.seed(123)

model_nn_tuned <- nnet(
  model_formula,
  data = train_scaled,
  size = best_parameters$size,
  decay = best_parameters$decay,
  skip = TRUE,
  linout = TRUE,
  maxit = 2000,
  trace = FALSE
)

cat(
  "\nTuned network convergence code:",
  model_nn_tuned$convergence, "\n"
)

if (model_nn_tuned$convergence != 0) {
  stop("The final network did not converge. Review optimisation.")
}

pred_tuned_train <- as.numeric(
  predict(model_nn_tuned, newdata = train_scaled)
) * price_sd + price_mean

pred_tuned_test <- as.numeric(
  predict(model_nn_tuned, newdata = test_scaled)
) * price_sd + price_mean

tuned_train_metrics <- calculate_metrics(
  data_train$price,
  pred_tuned_train
)

tuned_test_metrics <- calculate_metrics(
  data_test$price,
  pred_tuned_test
)

tuned_performance <- data.frame(
  Model = "Tuned_neural_network",
  Train_RMSE = unname(tuned_train_metrics["RMSE"]),
  Train_MAE = unname(tuned_train_metrics["MAE"]),
  Test_RMSE = unname(tuned_test_metrics["RMSE"]),
  Test_MAE = unname(tuned_test_metrics["MAE"])
)

final_comparison <- rbind(performance, tuned_performance)

cat("\n--- Final model comparison ---\n")
print(final_comparison, digits = 7, row.names = FALSE)

write.csv(
  tuning_results,
  "outputs/neural_network_tuning.csv",
  row.names = FALSE
)

write.csv(
  final_comparison,
  "outputs/model_comparison.csv",
  row.names = FALSE
)

###################################################################
# Exercise 1: Random train/test split
###################################################################

wine <- read.table("dataset/wine.data.txt", header = FALSE, sep = ",")

names(wine) <- c(
  "class", "alco", "ma", "ash", "alc", "mg", "tp",
  "flav", "noflav", "proa", "col", "hue", "od", "prol"
)

wine$class <- as.factor(wine$class)

# Fix the seed to reproduce the split; sample without replacement
# so that training and test observations cannot overlap.
set.seed(123)

train_indices <- sample(
  seq_len(nrow(wine)),
  size = floor(0.75 * nrow(wine)),
  replace = FALSE
)

wine_train <- wine[train_indices, ]
wine_test <- wine[-train_indices, ]

split_summary <- data.frame(
  Set = c("Training", "Test"),
  Observations = c(nrow(wine_train), nrow(wine_test)),
  Percentage = round(
    100 * c(nrow(wine_train), nrow(wine_test)) / nrow(wine), 2
  )
)

print(split_summary, row.names = FALSE)

class_distribution <- cbind(
  Full = table(wine$class),
  Training = table(wine_train$class),
  Test = table(wine_test$class)
)

print(class_distribution)

###################################################################
# Exercise 2: Train a classification tree
###################################################################

library(rpart)

# Use the training set only, keeping the test set for evaluation.
set.seed(123)

model_train <- rpart(
  class ~ .,
  data = wine_train,
  method = "class"
)

print(model_train)
printcp(model_train)

###################################################################
# Exercise 3: Visualise and compare the trees
###################################################################

dir.create("outputs", showWarnings = FALSE)

set.seed(123)

model_full <- rpart(
  class ~ .,
  data = wine,
  method = "class"
)

pdf("outputs/decision_trees.pdf", width = 10, height = 7)

plot(
  model_train,
  main = "Decision tree: training set",
  uniform = TRUE,
  margin = 0.1
)
text(model_train, use.n = TRUE, all = FALSE, cex = 0.8)

plot(
  model_full,
  main = "Decision tree: full dataset",
  uniform = TRUE,
  margin = 0.1
)
text(model_full, use.n = TRUE, all = FALSE, cex = 0.8)

invisible(dev.off())

cat("\n--- Tree trained on the full dataset ---\n")
print(model_full)
printcp(model_full)

tree_summary <- function(model) {
  leaves <- model$frame$var == "<leaf>"

  c(
    Observations = model$frame$n[1],
    Splits = sum(!leaves),
    Leaves = sum(leaves),
    Training_errors = sum(model$frame$dev[leaves])
  )
}

comparison <- rbind(
  Training_set = tree_summary(model_train),
  Full_dataset = tree_summary(model_full)
)

cat("\n--- Tree comparison ---\n")
print(comparison)



###################################################################
# Exercise 4: Predict probabilities and class labels
###################################################################

pred_prob <- predict(model_train, newdata = wine_test)

pred_class <- predict(
  model_train,
  newdata = wine_test,
  type = "class"
)

cat("\n--- Predicted probabilities ---\n")
print(pred_prob)

cat("\n--- Predicted class labels ---\n")
print(pred_class)

cat("\n--- Prediction output structure ---\n")
str(pred_prob)
str(pred_class)

###################################################################
# Exercise 5: Evaluate test predictions
###################################################################

confusion_matrix <- table(
  Predicted = pred_class,
  Actual = wine_test$class
)

cat("\n--- Confusion matrix ---\n")
print(confusion_matrix)

correct <- sum(diag(confusion_matrix))
total <- sum(confusion_matrix)

test_performance <- data.frame(
  Observations = total,
  Correct = correct,
  Incorrect = total - correct,
  Accuracy = correct / total,
  Error_rate = 1 - correct / total
)

cat("\n--- Test performance ---\n")
print(test_performance, row.names = FALSE)

###################################################################
# Exercise 6: Tune and prune classification trees
###################################################################

parameter_grid <- expand.grid(
  minsplit = c(10, 20, 30),
  maxdepth = c(2, 3, 5)
)

candidate_models <- vector("list", nrow(parameter_grid))
tuning_results <- parameter_grid

for (i in seq_len(nrow(parameter_grid))) {
  set.seed(123)

  candidate <- rpart(
    class ~ .,
    data = wine_train,
    method = "class",
    control = rpart.control(
      minsplit = parameter_grid$minsplit[i],
      maxdepth = parameter_grid$maxdepth[i],
      cp = 0,
      xval = 10
    )
  )

  # Select pruning complexity by cross-validation, preferring
  # fewer splits when validation errors are tied.
  cp_table <- candidate$cptable
  best_row <- order(
    cp_table[, "xerror"],
    cp_table[, "nsplit"]
  )[1]

  best_cp <- cp_table[best_row, "CP"]

  candidate_models[[i]] <- prune(candidate, cp = best_cp)

  tuning_results$CP[i] <- best_cp
  tuning_results$Splits[i] <- cp_table[best_row, "nsplit"]
  tuning_results$CV_relative_error[i] <- cp_table[best_row, "xerror"]
}

cat("\n--- Cross-validation results ---\n")
print(tuning_results, row.names = FALSE)

best_index <- order(
  tuning_results$CV_relative_error,
  tuning_results$Splits
)[1]

model_tuned <- candidate_models[[best_index]]

cat("\n--- Selected configuration ---\n")
print(tuning_results[best_index, ], row.names = FALSE)

cat("\n--- Selected tree ---\n")
print(model_tuned)

# Evaluate the selected model on test data only after tuning.
pred_tuned <- predict(
  model_tuned,
  newdata = wine_test,
  type = "class"
)

confusion_tuned <- table(
  Predicted = pred_tuned,
  Actual = wine_test$class
)

cat("\n--- Tuned model confusion matrix ---\n")
print(confusion_tuned)

model_comparison <- data.frame(
  Model = c("Default tree", "Tuned tree"),
  Correct = c(
    sum(pred_class == wine_test$class),
    sum(pred_tuned == wine_test$class)
  ),
  Incorrect = c(
    sum(pred_class != wine_test$class),
    sum(pred_tuned != wine_test$class)
  ),
  Accuracy = c(
    mean(pred_class == wine_test$class),
    mean(pred_tuned == wine_test$class)
  )
)

cat("\n--- Test performance comparison ---\n")
print(model_comparison, row.names = FALSE)

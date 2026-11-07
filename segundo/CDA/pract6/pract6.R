################################################################################
# Exercise 1
################################################################################

tic_tac_toe <- read.table("dataset/tic-tac-toe.data.txt", header = FALSE, sep = ",")
tic_tac_toe_headers <- c("A.1", "B.1", "C.1", "A.2", "B.2", "C.2", "A.3", "B.3", "C.3", "Class")
names(tic_tac_toe) <- tic_tac_toe_headers
tic_tac_toe[] <- lapply(tic_tac_toe, as.factor)

if (sum(is.na(tic_tac_toe)) > 0) {
  cat("\nThere are ", sum(is.na(tic_tac_toe)), " null values\n")
} else {
  cat("\nThere isn't any null values\n")
}

################################################################################
# Exercise 2
################################################################################

library(pbkrtest)
library(caret)
set.seed(123)

train_index <- createDataPartition(
  tic_tac_toe$Class,
  p = 0.7,
  list = FALSE,
  times = 1
)
tic_tac_toe_train <- tic_tac_toe[train_index, ]
tic_tac_toe_test <- tic_tac_toe[-train_index, ]

cat("\nClass Proportion: Original\n")
prop.table(table(tic_tac_toe$Class))
cat("\nClass Proportion: Train\n")
prop.table(table(tic_tac_toe_train$Class))
cat("\nClass Proportion: Test\n")
prop.table(table(tic_tac_toe_test$Class))

split_summary <- data.frame(
  Set = c("Train", "Test"),
  Observations = c(nrow(tic_tac_toe_train), nrow(tic_tac_toe_test)),
  Percentage = 100 * (c(nrow(tic_tac_toe_train), nrow(tic_tac_toe_test)) / nrow(tic_tac_toe))
)
print(split_summary, row.names = FALSE)

################################################################################
# Exercise 3
################################################################################

fitControl <- trainControl(
  method = "cv",
  number = 10,
  classProbs = TRUE
)

# Naive Bayes
set.seed(123)
model_bayes <- train(
  Class ~ .,
  data = tic_tac_toe_train,
  trControl = fitControl,
  method = "nb"
)

# Decision Tree
set.seed(123)
model_tree <- train(
  Class ~ .,
  data = tic_tac_toe_train,
  trControl = fitControl,
  method = "rpart"
)

# Neural Network
set.seed(123)
model_nn <- train(
  Class ~ .,
  data = tic_tac_toe_train,
  trControl = fitControl,
  method = "nnet"
)

# k-Nearest Neighbors
set.seed(123)
model_knn <- train(
  Class ~ .,
  data = tic_tac_toe_train,
  trControl = fitControl,
  method = "knn"
)

# Support Vector Machine (with a linear kernel)
set.seed(123)
model_svm <- train(
  Class ~ .,
  data = tic_tac_toe_train,
  trControl = fitControl,
  method = "svmLinear"
)

model_evaluation_summary <- data.frame(
  Model = c(
    "Naive Bayes", "Decision Tree", "Neural Network",
    "k-Nearest Neighbors", "Support Vector Machine"
  ),
  Accuracy = c(
    getTrainPerf(model_bayes)$TrainAccuracy,
    getTrainPerf(model_tree)$TrainAccuracy,
    getTrainPerf(model_nn)$TrainAccuracy,
    getTrainPerf(model_knn)$TrainAccuracy,
    getTrainPerf(model_svm)$TrainAccuracy
  ),
  Kappa = c(
    getTrainPerf(model_bayes)$TrainKappa,
    getTrainPerf(model_tree)$TrainKappa,
    getTrainPerf(model_nn)$TrainKappa,
    getTrainPerf(model_knn)$TrainKappa,
    getTrainPerf(model_svm)$TrainKappa
  )
)

print(
  model_evaluation_summary[order(model_evaluation_summary$Accuracy, decreasing = TRUE), ],
  row.names = FALSE
)

################################################################################
# Exercise 4
################################################################################

library(AUC)

# Naive Bayes
pred_bayes <- predict(
  model_bayes,
  newdata = tic_tac_toe_test,
  type = "raw"
)
prob_bayes <- predict(
  model_bayes,
  newdata = tic_tac_toe_test,
  type = "prob"
)
auc_bayes <- AUC::auc(
  AUC::roc(
    prob_bayes$positive,
    factor(as.integer(tic_tac_toe_test$Class == "positive"))
  )
)
confusionMatrix(
  data = pred_bayes,
  reference = tic_tac_toe_test$Class
)

# Decision Tree
pred_tree <- predict(
  model_tree,
  newdata = tic_tac_toe_test,
  type = "raw"
)
prob_tree <- predict(
  model_tree,
  newdata = tic_tac_toe_test,
  type = "prob"
)
auc_tree <- AUC::auc(
  AUC::roc(
    prob_tree$positive,
    factor(as.integer(tic_tac_toe_test$Class == "positive"))
  )
)
confusionMatrix(
  data = pred_tree,
  reference = tic_tac_toe_test$Class
)

# Neural Network
pred_nn <- predict(
  model_nn,
  newdata = tic_tac_toe_test,
  type = "raw"
)
prob_nn <- predict(
  model_nn,
  newdata = tic_tac_toe_test,
  type = "prob"
)
auc_nn <- AUC::auc(
  AUC::roc(
    prob_nn$positive,
    factor(as.integer(tic_tac_toe_test$Class == "positive"))
  )
)
confusionMatrix(
  data = pred_nn,
  reference = tic_tac_toe_test$Class
)

# k-Nearest Neighbors
pred_knn <- predict(
  model_knn,
  newdata = tic_tac_toe_test,
  type = "raw"
)
prob_knn <- predict(
  model_knn,
  newdata = tic_tac_toe_test,
  type = "prob"
)
auc_knn <- AUC::auc(
  AUC::roc(
    prob_knn$positive,
    factor(as.integer(tic_tac_toe_test$Class == "positive"))
  )
)
confusionMatrix(
  data = pred_knn,
  reference = tic_tac_toe_test$Class
)

# Support Vector Machine (with a linear kernel)
pred_svm <- predict(
  model_svm,
  newdata = tic_tac_toe_test,
  type = "raw"
)
prob_svm <- predict(
  model_svm,
  newdata = tic_tac_toe_test,
  type = "prob"
)
auc_svm <- AUC::auc(
  AUC::roc(
    prob_svm$positive,
    factor(as.integer(tic_tac_toe_test$Class == "positive"))
  )
)
confusionMatrix(
  data = pred_svm,
  reference = tic_tac_toe_test$Class
)

# Metrics for the summary data frame
metrics_bayes <- postResample(pred_bayes, tic_tac_toe_test$Class)
metrics_tree <- postResample(pred_tree, tic_tac_toe_test$Class)
metrics_nn <- postResample(pred_nn, tic_tac_toe_test$Class)
metrics_knn <- postResample(pred_knn, tic_tac_toe_test$Class)
metrics_svm <- postResample(pred_svm, tic_tac_toe_test$Class)

model_test_summary <- rbind(
  "Naive Bayes" = c(metrics_bayes, AUC = as.numeric(auc_bayes)),
  "Decision Tree" = c(metrics_tree, AUC = as.numeric(auc_tree)),
  "Neural Network" = c(metrics_nn, AUC = as.numeric(auc_nn)),
  "k-Nearest Neighbors" = c(metrics_knn, AUC = as.numeric(auc_knn)),
  "Support Vector Machine" = c(metrics_svm, AUC = as.numeric(auc_svm))
)

model_test_summary <- data.frame(
  Models = rownames(model_test_summary),
  model_test_summary,
  row.names = NULL
)

print(model_test_summary[order(model_test_summary$Accuracy, decreasing = TRUE), ], row.names = FALSE)

################################################################################
# Exercise 5
################################################################################

library(ROCR)

# Naive Bayes
prediction_bayes <- prediction(
  prob_bayes$positive,
  tic_tac_toe_test$Class
)
performance_bayes <- ROCR::performance(
  prediction_bayes,
  measure = "tpr",
  x.measure = "fpr"
)

# Decision Tree
prediction_tree <- prediction(
  prob_tree$positive,
  tic_tac_toe_test$Class
)
performance_tree <- ROCR::performance(
  prediction_tree,
  measure = "tpr",
  x.measure = "fpr"
)

# Neural Network
prediction_nn <- prediction(
  prob_nn$positive,
  tic_tac_toe_test$Class
)
performance_nn <- ROCR::performance(
  prediction_nn,
  measure = "tpr",
  x.measure = "fpr"
)

# k-Nearest Neighbors
prediction_knn <- prediction(
  prob_knn$positive,
  tic_tac_toe_test$Class
)
performance_knn <- ROCR::performance(
  prediction_knn,
  measure = "tpr",
  x.measure = "fpr"
)

# Support Vector Machine (with a linear kernel)
prediction_svm <- prediction(
  prob_svm$positive,
  tic_tac_toe_test$Class
)
performance_svm <- ROCR::performance(
  prediction_svm,
  measure = "tpr",
  x.measure = "fpr"
)

# Draw
perf_list <- list(performance_bayes, performance_tree, performance_nn, performance_knn, performance_svm)
size <- length(perf_list)
cols <- rainbow(size)

for (i in 1:size) {
  plot(perf_list[[i]],
    col = cols[i], lwd = 2,
    add = (i != 1),
    main = if (i == 1) "Curva ROC" else NULL
  )
}

legend(
  "bottomright",
  legend = c("Naive Bayes", "Decision Tree", "Neural Network", "k-Nearest Neighbors", "SVM Linear"),
  col = cols, lwd = 2,
  lty = 1
)

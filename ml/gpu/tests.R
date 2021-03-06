

library(xgboost)
# load data
data(agaricus.train, package = 'xgboost')
data(agaricus.test, package = 'xgboost')
train <- agaricus.train
test <- agaricus.test
# fit model
bst <- xgboost(data = train$data, label = train$label, max_depth = 5, eta = 0.001, nrounds = 100,
               nthread = 2, objective = "binary:logistic", tree_method = "gpu_hist")

# Test for multi-gpu support
#bst <- xgboost(data = train$data, label = train$label, max_depth = 5, eta = 0.001, nrounds = 10000,
#               nthread = 2, objective = "binary:logistic", tree_method = "gpu_hist", n_gpus=4)

# predict
pred <- predict(bst, test$data)



## Xgboost via H2O Test
## `h2o` provides a nice interface to `xgboost`, along with some great tools for hyper-parameter tuning. (*Note: This is not an install of `h2o4gpu` so only `h2o.xgboost` supports GPU acceleration.*)



# Init h2o
library(h2o)
h2o.init()
# Load test data
australia_path <- system.file("extdata", "australia.csv", package = "h2o")
australia <- h2o.uploadFile(path = australia_path)
independent <- c("premax", "salmax","minairtemp", "maxairtemp", "maxsst",
                 "maxsoilmoist", "Max_czcs")
dependent <- "runoffnew"
# Run xgboost without GPU
h2o.xgboost(y = dependent, x = independent, training_frame = australia,
        ntrees = 1000, backend = "cpu")
# Run xgboost with GPU
h2o.xgboost(y = dependent, x = independent, training_frame = australia,
            ntrees = 1000, backend = "gpu")

## h2o stress test
h2o.xgboost(y = dependent, x = independent, training_frame = australia,
            ntrees = 100000, backend = "gpu")

## Tensorflow:

library(keras)
mnist <- dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y
# reshape
x_train <- array_reshape(x_train, c(nrow(x_train), 784))
x_test <- array_reshape(x_test, c(nrow(x_test), 784))
# rescale
x_train <- x_train / 255
x_test <- x_test / 255
y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)
model <- keras_model_sequential()
model %>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(784)) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 10, activation = 'softmax')

  model %>% compile(
    loss = 'categorical_crossentropy',
    optimizer = optimizer_rmsprop(),
    metrics = c('accuracy')
  )
  history <- model %>% fit(
    x_train, y_train,
    epochs = 30, batch_size = 128,
    validation_split = 0.2
  )
model %>% evaluate(x_test, y_test)




#### greta

x <- iris$Petal.Length
y <- iris$Sepal.Length
library(greta)
  
int <- normal(0, 5)
coef <- normal(0, 3)
sd <- lognormal(0, 3)
  
mean <- int + coef * x
distribution(y) <- normal(mean, sd)
m <- greta::model(int, coef, sd)
draws <- greta::mcmc(m, n_samples = 1000, chains = 4)


## greta GPU test:
n <- 10000
X <- matrix(0, n, n)
B <- variable(dim = c(n, n))
res <- X %*% B
B_val <- matrix(0, n, n)
. <- calculate(res, list(B = B_val))




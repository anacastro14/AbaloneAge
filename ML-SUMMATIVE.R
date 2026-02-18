# MACHINE LEARNING SUMMATIVE
#Modeling abalone age

library(dplyr)
library(ggplot2)
library(tidyverse)
library(corrplot)
library(GGally)
library(rpart)
library(ggparty)
library(caret)
library("colorspace") 
getwd()

abalone <- read.table("abalone.data", sep = ",", header = TRUE)

###explore data set and clean:
colnames(abalone)

#move column names into the the first row:
ab <- abalone %>% 
  add_row(M = "M", X0.455 = 0.455,
          X0.365 = 0.365, X0.095=0.095,
          X0.514=0.514, X0.2245 = 0.2245,
          X0.101=0.101,X0.15=0.15 ,  X15=15 ,
          .before = 1)

#change col names to df

ab <- ab %>% 
  rename("Sex"= M, "Length"= X0.455,
         "Diameter"= X0.365 , "Height"=X0.095,
         "Whole_weight"=X0.514, "Shucked_weight" = X0.2245,
         "Viscera_weight"=X0.101, "Shell_weight"=X0.15 ,"Rings" =X15)

#check for missing values:
paste("Missing Values", sum(is.na(ab)))
#no missing values as stated in the dataset documentation

#check type of variables in data frame
sapply(ab, class)

#changing character variables into factors:

ab <- ab %>% 
  mutate(Sex = factor(Sex,levels = c("M","F","I"), labels = c("Male","Female", "Infant")))

sapply(ab, class)


## DATA EXPLORATION

summary(ab)

#check for outliers, in case there are typos

#boxplots against sex, different measures for Males, Females and Infants
ggplot(ab,aes(x=Sex, y=Length, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
which.max(ab$Length)
ab$Length[1429] 
#doesn't look like there are any typos

ggplot(ab,aes(x=Sex, y=Diameter, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
ggplot(ab,aes(x=Sex, y=Height, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
which.max(ab$Height)
ab$Height[2052]
ggplot(ab,aes(x=Sex, y=Whole_weight, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
ggplot(ab,aes(x=Sex, y=Shucked_weight, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
ggplot(ab,aes(x=Sex, y=Viscera_weight, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
ggplot(ab,aes(x=Sex, y=Shell_weight, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")
ggplot(ab,aes(x=Sex, y=Rings, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")

#remove outliers in Rings:
i_outliers <- ab %>% 
  filter(Sex == "Infant" & Rings > 13)
i_outliers

ab_clean <- ab %>% 
  filter(!(Sex == "Infant" & Rings >13),
         !(Sex == "Male" & Rings < 5 ))
ggplot(ab_clean,aes(x=Sex, y=Rings, fill=Sex))+
  geom_boxplot() +
  theme(legend.position="none") +
  scale_fill_brewer(palette="Pastel1")


paste("Missing Values", sum(is.na(ab_clean)))

#analyzing frequency of rings:
hist(ab_clean$Rings, main="Frequency of Rings",
     ylab="Frequency",
     xlab="Number of Rings",
     col="cadetblue")

barplot(prop.table(table(ab_clean$Rings)),
        main="Frequency of Rings",
        ylab= "Frequency: Proportion",
        xlab="Number of Rings",
        col="cadetblue")


#exploration
#correlation plot
ab_dummies <- ab_clean %>% 
  mutate(Sex = factor(Sex)) %>% 
  model.matrix(~ Sex - 1, data = .) %>% 
  as.data.frame()
# Combine with other numeric variables and compute correlation matrix

numeric_vars <- ab_clean %>% select_if(is.numeric)
all_vars <- cbind(numeric_vars, ab_dummies)
cor_matrix <- cor(all_vars, use = "complete.obs")
corrplot::corrplot(cor_matrix, method="number")

##Length and diameter highly correlated
# Shell_weight has the highest correlation with rings 
# followed by Diameter, Length and Height
#Length could be removed? first model with length and then try to 
#remove and check for improvements.

### ----- CART Regression Model: ------


#Predict Rings / Age of abalone, predict with Shell_weight

part_age = rpart(data=ab_clean,
            Rings ~ Shell_weight)

part_age
plot(as.party(part_age))

printcp(part_age)


#predict with Height and Diameter
HD_age = rpart(data=ab_clean,
                 Rings ~ Shell_weight+Height+Diameter)

HD_age
plot(as.party(HD_age))

printcp(HD_age)

##predict with all variables:let the algorithm decide which variables are the 
#most important

ALL_age = rpart(data=ab_clean,
               Rings ~ .)

ALL_age
plot(as.party(ALL_age))

printcp(ALL_age)
##tree only used Sex, Shell_weight and Shucked_weight

##split data to build model and prune:

set.seed(123)
trainIndex <- createDataPartition(ab_clean$Rings, p =0.7,list=FALSE)
trainData <- ab_clean[trainIndex, ]
testData <- ab_clean[-trainIndex, ]

#pruning!

#cost complexity
#now dropping the variables that the last model didn't use
#keep only Shel_weight, Sex and Shucked_weight
SSS_age = rpart(data=trainData,
                Rings ~ Sex+Shell_weight+Shucked_weight)

printcp(SSS_age)
          
cp = SSS_age$cptable %>%
  as.data.frame %>%
  slice(which.min(xerror)) %>%
  select(CP) %>%
  as.numeric

pruned_model = prune(SSS_age,cp)
plot(as.party(pruned_model))

#test model:


testData <- testData %>% 
  mutate(pred_rings = predict(pruned_model, newdata = .))

performance <- postResample(pred = testData$pred_rings, obs = testData$Rings)
print(performance)

ggplot(testData) + 
  geom_point(aes(x=Rings, y=pred_rings)) + 
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  labs(
    title = "CART Model: Actual vs. Predicted Rings",
    x = "Actual Rings",
    y = "Predicted Rings"
  ) +
  theme_bw()


#cross_validation


fitControl = trainControl(method = "cv",number = 10)
rpartFit = train(Rings ~ .,
                 data = ab_clean,
                 method = "rpart",
                 trControl = fitControl)

plot(as.party(rpartFit$finalModel))
rpartFit #check for RMSE Rsquared 
which.max(ab$Rings)
ab$Rings[481] #29 rings max value
which.min(ab$Rings)
ab$Rings[237] #1 ring min value
#RMSE = 2.2606, predictions are off by about 2.2606 rings

library(caret)
library(ggplot2)
set.seed(123)
fitControl <- trainControl(method = "cv", number = 10,
                           savePredictions=TRUE)

# Create a grid of cp values to try
cpGrid <- expand.grid(cp = seq(0.01, 0.1, length.out = 20))

set.seed(123)
# Train the CART model with tuning
rpartFit <- train(Rings ~ .,
                  data = ab_clean,
                  method = "rpart",
                  trControl = fitControl,
                  tuneGrid = cpGrid)

cv_predictions <- rpartFit$pred

plot(as.party(rpartFit$finalModel))

ggplot(cv_predictions, aes(x = obs, y = pred)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  labs(title = "CV CART: Actual vs. Predicted Rings",
       x = "Actual Rings",
       y = "Predicted Rings") +
  theme_bw()
# Visualize the tuning results
print(rpartFit)






#plot

testData <- testData %>% 
  mutate(pred_rings = predict(rpartFit, newdata = .))

performance <- postResample(pred = testData$pred_rings, obs = testData$Rings)
print(performance)

ggplot(testData) + 
  geom_point(aes(x=Rings, y=pred_rings)) + 
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  labs(
    title = "CV CART: Actual vs. Predicted Rings",
    x = "Actual Rings",
    y = "Predicted Rings"
  ) +
  theme_bw()

### ------ 

#second method:

library(rpart)
library(rpart.plot)

custom_control <- rpart.control(
  cp = 0.01,       # Complexity parameter
  minsplit = 20,   # Minimum observations needed to attempt a split
  maxdepth = 5     # Maximum depth of any node
)

# Fit the model with your custom control
pruned_tree <- rpart(
  Rings ~ .,
  data = ab_clean,
  method = "anova",      # For regression
  control = custom_control
)

# Visualize the pruned tree
rpart.plot(pruned_tree, type = 3, fallen.leaves = TRUE)
pruned_tree

testData <- testData %>% 
  mutate(pred_rings = predict(pruned_tree, newdata = .))

ggplot(testData) + 
  geom_point(aes(x=Rings, y=pred_rings)) + 
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  labs(
    title = "CV CART: Actual vs. Predicted Rings",
    x = "Actual Rings",
    y = "Predicted Rings"
  ) +
  theme_bw()

performance <- postResample(pred = testData$pred_rings, obs = testData$Rings)
print(performance)

library(caret)
library(rpart)
library(rpart.plot)

# Define 10-fold cross-validation
fitControl <- trainControl(method = "cv", number = 10)

# Create a grid of cp values to try
cpGrid <- expand.grid(cp = seq(0.01, 0.1, length.out = 20))

set.seed(123)
# Train the CART model with tuning
rpartFit <- train(Rings ~ .,
                  data = ab_clean,
                  method = "rpart",
                  trControl = fitControl,
                  tuneGrid = cpGrid)

# Visualize the tuning results
plot(rpartFit)
print(rpartFit)



# Visualize the final tree
plot(as.party(rpartFit$finalModel))

testData <- testData %>% 
  mutate(pred_rings = predict(rpartFit, newdata = .))

performance <- postResample(pred = testData$pred_rings, obs = testData$Rings)
print(performance)

ggplot(testData) + 
  geom_point(aes(x=Rings, y=pred_rings)) + 
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  labs(
    title = "CV CART: Actual vs. Predicted Rings",
    x = "Actual Rings",
    y = "Predicted Rings"
  ) +
  theme_bw()



### ----- RANDOM FOREST ------
library(randomForest)
set.seed(123)
rf = randomForest(Rings~Shell_weight, data=trainData)
rf

#mean squared of residuals = 6.23095
# % Var explained = 39.66

predRF = testData%>% 
  mutate(pred_rf = predict(rf, newdata = testData))
RMSE(predRF$pred_rf, predRF$Rings)     ### RMSE OF 2.523734
ggplot(predRF) +
  geom_point(aes(x=Rings, y=pred_rf)) +
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  theme_bw()

#tuning model

rf = randomForest(Rings ~ ., data = trainData, mtry = 3)
rf
varImpPlot(rf, main="Variable Importance Score")
pred_rf <- predict(rf, newdata = testData)
performance <- postResample(pred = pred_rf, obs = testData$Rings)
print(performance)

#WITH mtry = 5
#mean squared of residuals = 4.5902
# % Var explained = 55.11

#WITH mtry = 7
#mean squared of residuals = 4.6227
# % Var explained = 54.75


#WITH mtry = 4#mean squared of residuals = 4.5841
# % Var explained = 55.17


#WITH mtry = 3
#mean squared of residuals = 4.5474  
# % Var explained = 55.53

#WITH mtry = 2
#mean squared of residuals = 4.5095 
# % Var explained = 55.9


#plot:
predRF = testData%>% 
  mutate(pred_rf = predict(rf, newdata = testData))
RMSE(predRF$pred_rf, predRF$Rings) ## RMSE OF 2.130631
ggplot(predRF) +
  geom_point(aes(x=Rings, y=pred_rf)) +
  geom_abline(intercept = 0,slope = 1, colour = "red") +
  labs(
    title = "Random Forest: Actual vs. Predicted Rings",
    x = "Actual Rings",
    y = "Predicted Rings"
  ) +
  theme_bw()


#more tuning:
rf1 <- randomForest(Rings ~ ., data = trainData, mtry = 3, ntree = 1000)
rf1
#similar results, 500 trees is enough

#more tuning!
rf2 <- randomForest(Rings ~ ., data = trainData, mtry = 3, nodesize = 3)
rf2

#This will allow each terminal node (leaf) to have at least 3 observations 
#instead of the default 5. 
#NOTE: this model increased the mean squared residuals to 4.557
#I'll keep the orginal model.


#visualize both models: compare them

metrics <- data.frame(
  Model = c("CART: Cross-Validated", "Random Forest"),
  RMSE = c(2.525, 1.984),  
  MAE = c(1.899, 1.425),     
  Rsquared = c(0.349, 0.59)
)

ggplot(metrics, aes(x = Model, y = RMSE, fill = Model)) +
  geom_bar(stat = "identity", width = 0.6) +
  labs(title = "RMSE Comparison", y = "RMSE") +
  theme_minimal() +
  scale_fill_brewer(palette="Set2")

ggplot(metrics, aes(x = Model, y = MAE, fill = Model)) +
  geom_bar(stat = "identity", width = 0.6) +
  labs(title = "MAE Comparison", y = "MAE") +
  theme_minimal()+
  scale_fill_brewer(palette="Set2")

ggplot(metrics, aes(x = Model, y = Rsquared, fill = Model)) +
  geom_bar(stat = "identity", width = 0.6) +
  labs(title = "Rsquared Comparison", y = "Rsquared") +
  theme_minimal()+
  scale_fill_brewer(palette="Set2")










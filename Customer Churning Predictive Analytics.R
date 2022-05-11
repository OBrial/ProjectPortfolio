
# Data Wrangling --------------------------------------------------

churn<- read.csv(file.choose(),na.strings = c(""), header = TRUE)

summary(churn)
str(churn)

churn_backup<- churn
as.factor(churn$Geography)


  #encoding the variables Geography and Gender
churn$Geography<- as.factor(churn$Geography)

churn$Gender<- as.factor(churn$Gender)

str(churn)

  # factor variables
churn$NumOfProducts<- as.factor(churn$NumOfProducts)
churn$HasCrCard<- as.factor(churn$HasCrCard)
churn$IsActiveMember<- as.factor(churn$IsActiveMember)
churn$Exited<- as.factor(churn$Exited)
churn$Tenure<- as.factor(churn$Tenure)

str(churn)
  
  #missing values
churn[!complete.cases(churn),]

length(churn[!complete.cases(churn),])

#imputation for missing values using mice
library(mice)

  #md.pattern(churn)
set.seed(123)
churn_imp<- mice(churn, m=2, method = "rf")

summary(churn_imp)

  #complete data
churn_complete<- complete(churn_imp,1)

churn_complete[!complete.cases(churn_complete),]
summary(churn_complete)
str(churn_complete)


# Exploratory Data Analysis -----------------------------------------------

  #Credit Score
library(ggplot2)

  # distribution of credit score and skewness detection
ggplot(data=churn_complete, aes(x=CreditScore)) +
  geom_histogram(binwidth=25, fill="green", color="black")+
  xlab("Credit Score")+
  ylab("Total Count")
  

  # View for any outliers
boxplot(churn_complete$CreditScore, ylab="CreditScore")
  
#credit score vs exited customers

ggplot(data=churn_complete,aes(x=CreditScore, fill=Exited))+
  geom_histogram(binwidth=25,color="black")+
  xlab("Credit Score")+
  ylab("Total Count")


summary(churn_complete$CreditScore)  

#####################
#Age

# distribution of Age and skewness detection
ggplot(data=churn_complete, aes(x=Age)) +
  geom_histogram(binwidth=5, fill="green", color="black")+
  xlab("Age")+
  ylab("Total Count")


# View for outliers
boxplot(churn_complete$Age, ylab="Age")
boxplot.stats(churn_complete$Age)$out

#Age vs exited customers

ggplot(data=churn_complete,aes(x=Age, fill=Exited))+
  geom_histogram(binwidth=5,color="black")+
  xlab("Age")+
  ylab("Total Count")

summary(churn_complete$Age) 

##################

#Balance
# distribution of balance and skewness detection
ggplot(data=churn_complete, aes(x=Balance)) +
  geom_density(fill="orange")+
  xlab("Balance")+
  ylab("Total Count")

# View for outliers
boxplot(churn_complete$Balance, ylab="Balance")
boxplot.stats(churn_complete$Balance)$out

#Balance vs exited customers

ggplot(data=churn_complete,aes(x=Balance, fill=Exited))+
  geom_histogram(binwidth=2500,color="black")+
  xlab("Balance")+
  ylab("Total Count")

summary(churn_complete$Balance)

################## 

#Exited
class(churn_complete$Exited)

#distribution and proportion of exited customers

table(churn_complete$Exited)

round((prop.table(table(churn_complete$Exited))),3)

#Exited customers distribution

ggplot(data=churn_complete, aes(x=Exited))+
  geom_bar(fill="blue")+
  xlab("Exited")+
  ylab("Total Count")

#Geography
class(churn_complete$Geography)

table(churn_complete$Geography)

#proportion of location/geography

round((prop.table(table(churn_complete$Geography))),3)

#Exited customers by location
ggplot(data=churn_complete, aes(x=Geography, fill=Exited))+  
  geom_bar()+ facet_wrap(~Gender)+                            
  xlab("Location")+
  ylab("Total Count")


##################
#Gender
class(churn_complete$Gender)

table(churn_complete$Gender)

#Proportion of gender
round((prop.table(table(churn_complete$Gender))),3)

#how customer churning looks by gender
ggplot(data=churn_complete, aes(x=Gender, fill=Exited))+
  geom_bar()

##################

#Tenure
class(churn_complete$Tenure)

table(churn_complete$Tenure)
round((prop.table(table(churn_complete$Tenure))),3)


#Exited customers in each segment of tenure

ggplot(data=churn_complete, aes(x=Tenure, fill=Exited))+
  geom_bar()


##################

#HasCrCard
class(churn_complete$HasCrCard)

table(churn_complete$HasCrCard)
round((prop.table(table(churn_complete$HasCrCard))),3)

#Exited customers in each segment of tenure

churn_complete$HasCrCard<- as.factor(ifelse(churn_complete$HasCrCard==0,'No','Yes'))

ggplot(data=churn_complete, aes(x=HasCrCard, fill=Exited))+
  geom_bar()+ facet_grid(Geography~Gender)+                            
  xlab("Credit card holders")+
  ylab("Total Count")

##################

#IsActiveMember
class(churn_complete$IsActiveMember)

table(churn_complete$IsActiveMember)
round((prop.table(table(churn_complete$IsActiveMember))),3)

#Exited customers by Is Active Member
churn_complete$IsActiveMember<- as.factor(ifelse(churn_complete$IsActiveMember==0,'Not','Yes'))

ggplot(data=churn_complete, aes(x=IsActiveMember, fill=Exited))+
  geom_bar()+ facet_grid(Geography~Gender)+                            
  xlab("Is Active Member")+
  ylab("Total Count")


############## Correlations
cor(churn_complete[,c(4,7,9,13)])
pairs(churn_complete[,c(4,7,9,13)])



# Model Building ----------------------------------------------------------

str(churn_data)
churn_data$IsActiveMember<- as.factor(ifelse(churn_complete$IsActiveMember=='Not',0,1))
churn_data$HasCrCard<- as.factor(ifelse(churn_complete$HasCrCard=='No',0,1))
churn_data$Geography = factor(churn_data$Geography,
                              levels=c('France', 'Spain', 'Germany'),
                              labels =c(1,2,3)) 
churn_data$Gender = factor(churn_data$Gender,
                           levels=c('Male', 'Female'),
                           labels =c(1,2))


### Selecting the variables

churn_data<- data.frame(churn_complete[,c(-1,-2,-3)])
churn_data


#########################################################

# K-Nearest Neighbors (K-NN)
#########################################################

# install.packages('caTools')
library(caTools)
library(class)
library(caret)

set.seed(345)
## Splitting the data for training and test set

split=sample.split(churn_data$Exited,SplitRatio = 0.75)
training_set= subset(churn_data, split == T)
test_set= subset(churn_data, split == F)

                                        
##fitting knn with cross validation

set.seed(678)

ctrl= trainControl(method = "cv", number = 10)

knn_model<- train(Exited~., data=training_set, method= "knn",
                 trControl= ctrl,
                 preProcess= c("center", "scale"))     #tuneLength=50
                 
              
print(knn_model)
#plot(knn_model)

# Making predictions

knn_pred<- predict(knn_model,test_set)

# making the Confusion matrix

confusionMatrix(table(test_set[,11],knn_pred))

Knn_results<- confusionMatrix(table(test_set[,11],knn_pred))

#########################################################

# Fitting Logistic regression to the Training set
#########################################################


## Splitting the data for training and test set
set.seed(345)
split=sample.split(churn_data$Exited,SplitRatio = 0.75)
training_set= subset(churn_data, split == T)
test_set= subset(churn_data, split == F)


#fitting the model
set.seed(345)

ctrl= trainControl(method = "cv", number = 10) 

lg_modelcv<- train(Exited~., 
                   data=training_set, method= "glm", family= binomial,
                   preProcess= c("center", "scale"),
                   trControl= ctrl) #tuneLength=50
                   

print(lg_modelcv)

summary(lg_modelcv)

#Variable importance

varImp(lg_modelcv)

#Making predictions
lgcv_pred<- predict(lg_modelcv,test_set)

#Making the confusion matrix
confusionMatrix(table(test_set[,11],lgcv_pred))

logistic_results<-confusionMatrix(table(test_set[,11],lgcv_pred))


#####################################################################

All_Results<- list(Knn=Knn_results,logistic=logistic_results)

All_Results





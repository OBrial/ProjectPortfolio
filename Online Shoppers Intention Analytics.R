#####################################################################################

#Exploratory Data Analysis of Online Shoppers Intention

#####################################################################################

ecom<- read.csv(file.choose(), header=T)

head(ecom,10)
tail(ecom,10)

str(ecom)
summary(ecom)

ecom$TrafficType<- as.factor(ecom$TrafficType)
ecom$VisitorType<- as.factor(ecom$VisitorType)
ecom$Weekend<- as.factor(ecom$Weekend)
ecom$Revenue<- as.factor(ecom$Revenue)

##### Number of times Administrative page was visited, by visitor type and revenue
library(ggplot2)
summary(ecom$Administrative)
table(ecom$Administrative)

ecom$AdminGroups<- cut(ecom$Administrative, 
                       breaks = c(0,3,7,11,15,19,23,27),include.lowest = TRUE,
                       labels=c("0 to 3","4 to 7","8 to 11","12 to 15","16 to 19","20 to 23",
                                "24 to 27"))

ggplot(data=ecom, aes(x=AdminGroups, fill=Revenue))+
  geom_bar()+ facet_wrap(~VisitorType)+xlab("Pageview visit intervals") + ylab("Total_Sessions")+
  ggtitle("Administrative Pageviews")

##### Number of times Informational page was visited, by visitor type and revenue

summary(ecom$Informational)
table(ecom$Informational)

ecom$InfomationalGroups<- cut(ecom$Informational, 
                       breaks = c(0,3,7,11,15,19,24),include.lowest = TRUE,
                       labels=c("0 to 3","4 to 7","8 to 11","12 to 15","16 to 19","20 to 24"))

ggplot(data=ecom, aes(x=InfomationalGroups, fill=Revenue))+
  geom_bar()+ facet_wrap(~VisitorType)+xlab("Pageview visit intervals") + ylab("Total_Sessions")+
  ggtitle("Informational Pageviews")

##### Bounce rates by visitor type

summary(ecom$BounceRates)

ggplot(data=ecom, aes(x=BounceRates))+
  geom_histogram(binwidth = 0.01,fill="orange", colour="black")+ facet_wrap(~VisitorType)+
  ylab("Total_Sessions")+ ylim(0,8000)

##### Exit rates by visitor type

summary(ecom$ExitRates)

ggplot(data=ecom, aes(x=ExitRates))+
  geom_histogram(binwidth = 0.01,fill="orange", colour="black")+ facet_wrap(~VisitorType)+
  ylab("Total_Sessions")

##### Page Values by visitor type

summary(ecom$PageValues)

ggplot(data=ecom, aes(x=PageValues))+
  geom_histogram(binwidth = 15,fill="orange", colour="black")+ facet_wrap(~VisitorType)+
  ylab("Total_Sessions") + ylim(0,1500)

##########################################################

##### Revenue sessions distribution

table(ecom$Revenue)

library(ggplot2)
ggplot(data=ecom, aes(x=Revenue)) +
  geom_bar(fill="orange")+ ylab("Total_Sessions")

##### Weekend sessions distribution

ecom$Weekend<- ifelse(ecom$Weekend=="TRUE", "Weekend_dys","Non_Weekend_dys")
table(ecom$Weekend)

ggplot(data=ecom, aes(x=Weekend)) +
  geom_bar(fill="purple")+ ylim(0,10000)+  ylab("Total_Sessions")

##### Visitor sessions type distribution

table(ecom$VisitorType)
ggplot(data=ecom, aes(x=VisitorType)) +
  geom_bar(fill="blue")+  ylab("Total_Sessions")

### Revenue by Month

table(ecom$Month)

ecom$Month<- as.factor(ecom$Month)
ggplot(data=ecom, aes(x=Month, fill=Revenue))+
  geom_bar()+ ylab("Total_Sessions")+ ggtitle("Revenue by Month")+
  ylim(0,4000)


### Revenue by Weekends

ggplot(data=ecom, aes(x=Weekend, fill=Revenue))+
  geom_bar()+ ylab("Total_Sessions")+ ggtitle("Revenue by Weekends")
  

### Revenue by Visitor type
ggplot(data=ecom, aes(x=VisitorType, fill=Revenue))+
  geom_bar()+ ylab("Total_Sessions")+ ggtitle("Revenue by Visitor Type")


### Revenue by Month,Weekend and Visitor Type

ggplot(data=ecom, aes(x=Month, fill=Revenue))+
  geom_bar()+ facet_grid(Weekend~VisitorType)+
  ylab("Total_Sessions")+ ggtitle("Revenue by Month, Weekend and Visitor Type")

################################################################################################

####Predictive analytics

################################################################################################



library(caTools)
library(class)
library(caret)
library(randomForest)

### Splitting the data set into the Training set and Test set

ecom1<- ecom[,c(-12:-15,-19,-20)]

set.seed(123)

split=sample.split(ecom1$Revenue,SplitRatio = 0.75)
training_set= subset(ecom1, split == T)
test_set= subset(ecom1, split == F)

### Using the Random Forest

ctrl= trainControl(method = "cv", number = 10)

rf_model<- train(Revenue~., data=training_set, method= "rf",
                 trControl= ctrl, ntree=1000,
                 preProcess= c("center", "scale"))     #tuneLength=50


print(rf_model)

## Making predictions

rf_pred<- predict(rf_model,test_set)


## making the Confusion matrix

confusionMatrix(table(test_set[,14],rf_pred))

## Variable importance

varImp(rf_model)
plot(varImp(rf_model), main='Variable Importance')


#############################################################

### Using the KNN

#############################################################

set.seed(123)

ctrl= trainControl(method = "cv", number = 10)

knn_model<- train(Revenue~., data=training_set, method= "knn",
                  trControl= ctrl,
                  preProcess= c("center", "scale"))     #tuneLength=50


print(knn_model)

## Making predictions

knn_pred<- predict(knn_model,test_set)

## making the Confusion matrix

confusionMatrix(table(test_set[,14],knn_pred))

##################################################################################

##### End

##################################################################################














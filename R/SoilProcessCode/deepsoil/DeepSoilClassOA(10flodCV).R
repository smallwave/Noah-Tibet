library(sp)
library(raster)
library(maptools)
library(GSIF)
library(nnet)
library(rgdal)
library(RSAGA)
library(psych) # kappa
library(RColorBrewer)
library(C50)
library(randomForest)
library(rpart)
library(kknn)
library(e1071)
library(earth)
source("Code/deepsoil/PubFun.R")
#************************************************************************************************
# define var name
#************************************************************************************************
obsFile <- "soilEnvi/deepSoilOBSENVI.csv"
# covFile <- "soilEnvi/soilENVISELNEW.txt"

#************************************************************************************************
# read data 
#************************************************************************************************
obs_data<- read.csv(obsFile, head=TRUE,sep=",")
# groupp<-obs_data$groupID
# groupp<-as.factor(as.character(groupp))
# summary(groupp) 3128 3444
# 
# data3444<-obs_data[which(obs_data$groupID == 3444),]
# data<- getLayerDataForCV(11,data3444)
# summary(data[,1])

# ov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate

#************************************************************************************************
# count parameter define 
#************************************************************************************************
nFlod<- 10
# nLayer<-1
# i<-1
# j<-1
#just for test
#************************************************************************************************
# Calculate OA for every ENVI AND MENTHOD
#************************************************************************************************
resOA <- NULL
for(nLayer in 1:11)
{
  data<- getLayerDataForCV(nLayer,obs_data)
  data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
  #************************************************************************************************
  # 1  MLR
  #************************************************************************************************
  resOAMLRVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_MNLR <- multinom(formula, data = dataSimulation)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_MNLR, newdata = dataVerification,type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOAMLRVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOAMLRVec)
  #************************************************************************************************
  # 2  knn
  #************************************************************************************************
  resOAKNNVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_Knn <- train.kknn(formula, data = dataSimulation,kmax = 15,
                           kernel = c("triangular", "rectangular", "epanechnikov", "optimal"), distance = 1)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_Knn, newdata = dataVerification, type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOAKNNVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOAKNNVec)
  #************************************************************************************************
  # 3  naiveBayes
  #************************************************************************************************
  resOABayVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_bay <- naiveBayes(formula, data = dataSimulation)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_bay, newdata = dataVerification, type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOABayVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOABayVec)
  #************************************************************************************************
  # 4  Nnet
  #************************************************************************************************
  resOANNVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_nn <- nnet(formula, data = dataSimulation,size = 2, decay = 5e-4, maxit = 500)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_nn, newdata = dataVerification, type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOANNVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOANNVec)
  #************************************************************************************************
  # 5  svm
  #************************************************************************************************
  resOASVMVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_svm <- svm(formula, data = dataSimulation)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_svm, newdata = dataVerification, type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOASVMVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOASVMVec)
  #************************************************************************************************
  # 6  regression trees
  #************************************************************************************************
  resOAMARSVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_rt<- rpart(formula, data = dataSimulation)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_rt, newdata = dataVerification, type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOAMARSVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOAMARSVec)
  #************************************************************************************************
  # 7  C50
  #************************************************************************************************
  resOAC50Vec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_C5 <- C5.0(formula,data = dataSimulation)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_C5, newdata = dataVerification,type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOAC50Vec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOAC50Vec)
  #************************************************************************************************
  # 8  Random Forests
  #************************************************************************************************
  resOARFVec<-rep(c(0), 8)
  for(i in 1:8)
  {
    formula<-getFormula(i,data)
    nb.accuracies<-rep(c(0), nFlod)
    for (j in 1:nFlod) 
    {
      dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
      hv_RF <- randomForest(formula, data = dataSimulation, importance=TRUE,proximity=TRUE)
      
      dataVerification <-data[data$fold == j,c(1:10)]
      predictions<- predict(hv_RF, newdata = dataVerification,type = "class")
      
      numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
      nb.accuracies[j] = numcorrect / nrow(dataVerification)
    }
    resOARFVec[i]<- mean(nb.accuracies)
  }
  resOA<-rbind(resOA,resOARFVec)
}
write.csv(resOA, file = "resOACV.csv")

# #************************************************************************************************
# # 2  C50
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_C5 <- C5.0(formula,data = dataSimulation, rules = TRUE)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       predictions<- predict(hv_C5, newdata = dataVerification,type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempC50.csv")

# #************************************************************************************************
# # 3  Random Forests
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_RF <- randomForest(formula, data = dataSimulation, importance=TRUE,proximity=TRUE)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       predictions<- predict(hv_RF, newdata = dataVerification,type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempRF.csv")

# #************************************************************************************************
# # 4  Nnet
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_nn <- nnet(formula, data = dataSimulation,size = 2, decay = 5e-4, maxit = 500)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       predictions<- predict(hv_nn, newdata = dataVerification, type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempNnet.csv")

# #************************************************************************************************
# # 5  knn
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_Knn <- train.kknn(formula, data = dataSimulation,kmax = 15,
#                            kernel = c("triangular", "rectangular", "epanechnikov", "optimal"), distance = 1)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       
#       predictions<- predict(hv_Knn, newdata = dataVerification, type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempKNN.csv")

# #************************************************************************************************
# # 6  svm
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_svm <- svm(formula, data = dataSimulation)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       
#       predictions<- predict(hv_svm, newdata = dataVerification, type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempSVM.csv")

# #************************************************************************************************
# # 7  naiveBayes
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       hv_bay <- naiveBayes(formula, data = dataSimulation)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       
#       predictions<- predict(hv_bay, newdata = dataVerification, type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempBay.csv")

# #************************************************************************************************
# # 8  Multivariate Adaptive Regression Splines
# #************************************************************************************************
# resOA <- NULL
# for(nLayer in 1:11)
# {
#   resOAVec<-rep(c(0), 8)
#   for(i in 1:8)
#   {
#     data<- getLayerDataForCV(nLayer,obs_data)
#     formula<-getFormula(i,data)
#     
#     data$fold = cut(1:nrow(data), breaks=nFlod, labels=F)
#     nb.accuracies<-rep(c(0), nFlod)
#     for (j in 1:nFlod) 
#     {
#       dataSimulation <-droplevels(data[data$fold != j,c(1:10)])
#       
#       hv_mars <- earth(formula, data = dataSimulation)
#       
#       dataVerification <-data[data$fold == j,c(1:10)]
#       
#       predictions<- predict(hv_mars, newdata = dataVerification, type = "class")
#       
#       numcorrect = sum(as.vector(predictions)  == as.vector(dataVerification[,1]))
#       nb.accuracies[j] = numcorrect / nrow(dataVerification)
#     }
#     nb.accuracies
#     resOAVec[i]<- mean(nb.accuracies)
#   }
#   resOA<-rbind(resOA,resOAVec)
# }
# write.csv(resOA, file = "tempMARS.csv")



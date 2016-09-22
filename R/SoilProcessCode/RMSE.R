library(hydroGOF)
library(ggplot2)
library(soiltexture)
source("Function.R")
#************************************************************************************************
# define var name
#************************************************************************************************
inputSoilDataCvs <- "ssdSoilTextureProcess.csv"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilTextureData <- read.csv(inputSoilDataCvs, head=TRUE,sep=",")
#************************************************************************************************
# 1  read data 
#************************************************************************************************
nlayer<- 1
colClay <-c(7+nlayer,16+nlayer,25+nlayer,34+nlayer,43+nlayer,52+nlayer,61+nlayer)
clayObsData<- soilTextureData[colClay]

colClay <-c(7+nlayer+6,16+nlayer+6,25+nlayer+6,34+nlayer+6,43+nlayer+6,52+nlayer+6,61+nlayer+6)
claySimData<- soilTextureData[colClay]

rmse <-rmse(claySimData,clayObsData,na.rm=TRUE)
me<-me(claySimData,clayObsData,na.rm=TRUE)
dt<-data.frame(me,rmse)
write.csv(dt, file = "rmseme.csv")

# write.csv(rmse, file = "rmse.csv")



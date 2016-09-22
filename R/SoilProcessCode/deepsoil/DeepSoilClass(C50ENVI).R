library(sp)
library(raster)
library(maptools)
library(rgdal)
library(RSAGA)
library(C50)
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

# ov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate
#************************************************************************************************
# count parameter define 
#************************************************************************************************
nLayer<- 11

data<- getLayerDataForCV(nLayer,obs_data)
formula<-getFormula(8,data)
hv_C5 <- C5.0(formula,data = data)
sumInfo<- summary(hv_C5)
sumInfo

# write.csv(resOA, file = "resOACV.csv")



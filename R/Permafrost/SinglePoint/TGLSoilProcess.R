##########################################################################################################
# NAME
#    TGLSoilPrecess.R
# PURPOSE
#    soil parcess

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151027 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
library(aqp)
library(GSIF)
library(soiltexture)


inputCvs <- "Data/tglsoil.csv"

horizonDesign <- c(0,3,7,15,25,40,60,80)



#************************************************************************************************
# 1  mpspline
#************************************************************************************************
getSoilTextureData <- function (soilClayData,soilSiltData,soilSandData,isOmitAndNorma =TRUE) 
{
  groupData <- data.frame(
    "CLAY" = soilClayData,
    "SILT" = soilSiltData,
    "SAND" = soilSandData
  ) #
  
  groupData<-rbind(soilClayData,soilSiltData,soilSandData)
  groupData<-t(groupData)
  groupdataFrame<-as.data.frame(groupData)
  names(groupdataFrame)<-c("CLAY","SILT","SAND")
  if(isOmitAndNorma)
  {  
    groupdataFrame<-na.omit(groupdataFrame)
    groupdataFrame<-TT.normalise.sum(groupdataFrame)
  }
  return (groupdataFrame)
}

# read Data
soilData <- read.csv(inputCvs, head=TRUE, sep=",")
soilDataDf <- soilData
# Convert data 2 Profileclass
depths(soilData) <- ID ~ Top + Bottom 
## fit a spline and Commbit res
soilDataClaySps <- mpspline(soilData, var.name = "Clay",0.1,horizonDesign)
soilClayData <- soilDataClaySps$var.std
soilClayData$`soil depth`<-NULL

soilDataSiltSps <- mpspline(soilData, var.name = "Silt",0.1,horizonDesign)
soilSiltData<- soilDataSiltSps$var.std
soilSiltData$`soil depth`<-NULL

soilDataSandSps <- mpspline(soilData, var.name = "Sand",0.1,horizonDesign)
soilSandData <- soilDataSandSps$var.std
soilSandData$`soil depth`<-NULL

dataObs<-getSoilTextureData(soilClayData,soilSiltData,soilSandData)
dataObsTab<-TT.points.in.classes( tri.data = dataObs,class.sys = "USDA.TT") 
dataObsTab<-as.data.frame(dataObsTab)
names<-names(dataObsTab)

calClass<-function(row)
{
   names<-names(row)
   idx <- which(row != 0)
   return (names(idx))
}
  
apply(dataObsTab, 1, calClass)

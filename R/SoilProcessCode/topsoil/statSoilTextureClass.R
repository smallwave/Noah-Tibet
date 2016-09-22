library(soiltexture)
source("Code/SoilProcessCode/Function.R")

#************************************************************************************************
# define var name
#************************************************************************************************
inputSoilDataCvs <- "Output/ssdSoilTextureProcessGravel.csv"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilData <- read.csv(inputSoilDataCvs, head=TRUE,sep=",")

process<-function(x)
{
  if(x[4] > 50)
  {
    return(NA)
  }
  return(1)
}



nLayer<-7
obsCl <- paste("obsCL", nLayer ,sep='')
obsSl <- paste("obsSL", nLayer ,sep='')
obsSA <- paste("obsSA", nLayer ,sep='')
obsGra <- paste("obsGra", nLayer ,sep='')
names <-c(obsCl,obsSl,obsSA,obsGra)

groupData <- soilData[names]
names(groupData)<-c("CLAY","SILT","SAND","GRAVEL")
groupData<-na.omit(groupData)

row1<-nrow(groupData)
groupData$class <-apply(groupData, 1, process)
groupData<-na.omit(groupData)
row2<-nrow(groupData)

groupData<-TT.normalise.sum(groupData)
dataObsTab<-TT.points.in.classes(tri.data = groupData,class.sys = "USDA.TT") 
apply(dataObsTab,2,sum)
gravel<-row1-row2
gravel

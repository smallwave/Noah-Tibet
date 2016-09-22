library(gstat)
library(soiltexture)
library(rgdal)

source("Code/SoilProcessCode/Function.R")
#************************************************************************************************
# define var name
#************************************************************************************************
inputSoilDataCvs <- "Output/ssdSoilTextureProcessXY.csv"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilData <- read.csv(inputSoilDataCvs, head=TRUE,sep=",")
dataBase <- soilData[c("ID","x","y")]

resOA <- NULL

for (nLayer in 1:7)
{
  nPloygon<-12
  dataType <-"obs"
  
  dataObs<-soilTextureDataByLayerAndPloygon(soilData,dataType,nLayer,nPloygon,TRUE)
  
  ID <- rownames(dataObs)
  dataObs <- data.frame(ID,dataObs) 
  dataObs$ID<-as.integer(as.character(dataObs$ID))
  
  newTable <- merge(dataObs,dataBase,by.x="ID",by.y="ID",all.x=TRUE)
  coordinates(newTable) = ~x+y
  plot(newTable)
  vgm1 <-variogram(SAND~1, newTable)
  plot(vgm1)
  
  vmgFit <-vgm(60,"Sph",10000,20)
  vv<-fit.variogram(vgm1, vmgFit)
  vv
  RNE <- vv$psill[1]/(vv$psill[1]+vv$psill[2])
  resOA<-rbind(resOA,RNE)
}




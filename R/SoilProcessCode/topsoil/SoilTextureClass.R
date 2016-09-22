library(soiltexture)
library(psych)
source("Code/SoilProcessCode/Function.R")
#************************************************************************************************
# define var name
#************************************************************************************************
inputSoilDataCvs <- "Output/ssdSoilTextureProcess.csv"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilData <- read.csv(inputSoilDataCvs, head=TRUE,sep=",")
#************************************************************************************************
# 2  function
#************************************************************************************************
BulidMatrix <- function (dataObs, dataSim)
{
  corDt<-matrix(0,12,12,T)
  for(i in 1:nrow(dataObs))
  {
    idObs<-as.integer(dataObs[i,1])
    if (idObs%in%dataSim$ID)
    {
      dataObsRow<-dataObs[i,2:4]
      dataObsTab<-TT.points.in.classes( tri.data = dataObsRow,class.sys = "USDA.TT") 
      indexObs<-which(dataObsTab!= 0, arr.ind = TRUE) 

      nRowSim<-which(dataSim$ID==idObs)
      dataSimRow<-dataSim[nRowSim,2:4]
      dataSimTab<-TT.points.in.classes( tri.data = dataSimRow,class.sys = "USDA.TT") 
      indexSim<-which(dataSimTab!= 0, arr.ind = TRUE) 
      corDt[indexObs[2],indexSim[2]] = corDt[indexObs[2],indexSim[2]]+ 1
    }
  }
  return (corDt)
}
#************************************************************************************************
# 3  APPLICATON 1
#************************************************************************************************
15

dataType <-"sim"
dataSim<-soilTextureDataByLayer(soilData,dataType,nLayer,TRUE)
ID <- rownames(dataSim)
dataSim <- data.frame(ID,dataSim) 
dataSim$ID<-as.integer(as.character(dataSim$ID))

dataType <-"upd"
dataUpd<-soilTextureDataByLayer(soilData,dataType,nLayer,TRUE)
ID <- rownames(dataUpd)
dataUpd <- data.frame(ID,dataUpd) 
dataUpd$ID<-as.integer(as.character(dataUpd$ID))


build1<- BulidMatrix(dataObs,dataSim)
cohen.kappa(build1)
sum(diag(build1))
sum(build1)

build2<- BulidMatrix(dataObs,dataUpd)
cohen.kappa(build2)
sum(diag(build2))
sum(build2)



#************************************************************************************************
# 3  APPLICATON 2
#************************************************************************************************
nLayer<-7
nPloygon<-12
dataType <-"obs"
dataObs<-soilTextureDataByLayerAndPloygon(soilData,dataType,nLayer,nPloygon,TRUE)
dataObsTab<-TT.points.in.classes( tri.data = dataObs,class.sys = "USDA.TT") 
apply(dataObsTab,2,sum)

dataType <-"sim"
dataSim<-soilTextureDataByLayerAndPloygon(soilData,dataType,nLayer,nPloygon,TRUE)
dataSimTab<-TT.points.in.classes( tri.data = dataSim,class.sys = "USDA.TT") 
apply(dataSimTab,2,sum)

dataType <-"upd"
dataUpd<-soilTextureDataByLayerAndPloygon(soilData,dataType,nLayer,nPloygon,TRUE)
dataUpdTab<-TT.points.in.classes( tri.data = dataUpd,class.sys = "USDA.TT") 
apply(dataUpdTab,2,sum)


#************************************************************************************************
# 3  APPLICATON 3
#************************************************************************************************
nLayer<-4
# nPloygon<-3
dataType <-"obs"
dataObs<-soilTextureDataByLayer(soilData,dataType,nLayer,TRUE)
dataObsTab<-TT.points.in.classes( tri.data = dataObs,class.sys = "USDA.TT") 
apply(dataObsTab,2,sum)




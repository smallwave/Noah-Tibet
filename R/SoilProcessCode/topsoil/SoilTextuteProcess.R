library(gstat)
library(sp)
library(plyr)
library(soiltexture)
source("Code/Function.R")
#
#
#no   TT.normalise.sum
#
#
#************************************************************************************************
# define var name
#************************************************************************************************
inputClayCvs <- "Clay.csv"
inputSiltCvs <- "Silt.csv"
inputSandCvs <- "Sand.csv"
outVar <- "ssdSoilTextureProcess"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilClayData <- read.csv(inputClayCvs, head=TRUE,sep=",")
soilSiltData <- read.csv(inputSiltCvs, head=TRUE,sep=",")
soilSandData <- read.csv(inputSandCvs, head=TRUE,sep=",")

dataBaseInfo <- soilClayData[,c(2:5,15,24)]
dataIDGroupInfo<-soilClayData[,c(2,24)]
#************************************************************************************************
# 2  read data 
#************************************************************************************************
for(nLayer in 1:7)
{
  dataObs <- getSoilTextureDataByLayer(soilClayData,soilSiltData,soilSandData,nLayer1 = nLayer+6,isOmitAndNorma = FALSE)
  dataObs[,1] <-NULL
  obsCl <- paste("obsCL", nLayer ,sep='')
  obsSl <- paste("obsSL", nLayer ,sep='')
  obsSA <- paste("obsSA", nLayer ,sep='')
  names(dataObs)<-c(obsCl,obsSl,obsSA)
  dataMedian <- getSoilTextureDataByLayer(soilClayData,soilSiltData,soilSandData,nLayer1 = nLayer+ 24,isOmitAndNorma = FALSE)
  dataMedian[,1] <-NULL
  medCl <- paste("medCL", nLayer ,sep='')
  medSl <- paste("medSL", nLayer ,sep='')
  medSA <- paste("medSA", nLayer ,sep='')
  names(dataMedian)<-c(medCl,medSl,medSA)
  
  dataSim <- getSoilTextureDataByLayer(soilClayData,soilSiltData,soilSandData,nLayer1 = nLayer+ 15,isOmitAndNorma = FALSE)
  dataSim[,1] <-NULL
  simCl <- paste("simCL", nLayer ,sep='')
  simSl <- paste("simSL", nLayer ,sep='')
  simSA <- paste("simSA", nLayer ,sep='')
  names(dataSim)<-c(simCl,simSl,simSA)
  
  dataProcess<-data.frame(dataIDGroupInfo,dataObs,dataMedian)
  updCl <- paste("updCl", nLayer ,sep='')
  updSl <- paste("updSl", nLayer ,sep='')
  updSA <- paste("updSA", nLayer ,sep='')
  medianGroup <- ddply(dataProcess, .(groupID),
                       .fun = function(xx, obsCl,obsSl,obsSA,medCl,medSl,medSA) 
                       {
                          xx<-na.omit(xx)
                          ssdVec<-(xx[obsCl]-xx[medCl])^2+(xx[obsSl]-xx[medSl])^2+(xx[obsSA]-xx[medSA])^2
                          idssdMin<-which(ssdVec== min(ssdVec), arr.ind = TRUE) 
                          c(updCl = xx[idssdMin[1],3],updSl = xx[idssdMin[1],4],updSA = xx[idssdMin[1],5])
                       },obsCl,obsSl,obsSA,medCl,medSl,medSA)
  names(medianGroup)<-c("groupID",updCl,updSl,updSA)
  dataObs<- data.frame(dataIDGroupInfo,dataObs,dataSim)
  newLayer<- merge(dataObs,medianGroup,by.x="groupID",by.y="groupID",all.x=TRUE)
  newLayer[["groupID"]]<-NULL
  dataBaseInfo<- merge(dataBaseInfo,newLayer,by.x="ID",by.y="ID",all.x=TRUE)
}
#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste(outVar, ".csv",sep='')
write.csv(dataBaseInfo, file = outPutName)














##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160921 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
library(sp)
library(plyr) # need for dataset ozone
library(raster)
library(rgdal) # for spTransform
library(psych) # kappa

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapCompara.csv"
rasterFileMap <- "F:/worktemp/Permafrost(Change)/Data/QTPMap/Tif/2006map.tif"


#use over
# read Data
permafrostMap <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)

#use over
# read Data
permafrostMapCor <-permafrostMap
coordinates(permafrostMapCor) <- c("x","y")

rasterData <- raster(rasterFileMap)
demExtract <- extract(rasterData,permafrostMapCor,sp =TRUE)
demExtractDf <-demExtract@data
subDemExtractDf<-demExtractDf[c("ID","X2006map")]
comparaPermafrostMap <- merge(permafrostMap,subDemExtractDf,by.x="ID",by.y="ID")


BulidMatrix <- function (dataObs, dataSim)
{
  dataObsTmp<-as.integer(as.character(dataObs))
  dataSimTmp<-as.integer(as.character(dataSim))
  corDt<-matrix(0,2,2,T)
  for(i in 1:length(dataObsTmp))
  {

    dataObsR<-dataObsTmp[i]
    dataSimR<-dataSimTmp[i]
    
    if(is.na(dataObsR) || is.na(dataSimR))
    {
      next
    }
    else if(dataObsR == 3 || dataSimR ==3)
    {
      next
    }
    else
    {
      corDt[dataObsR,dataSimR] = corDt[dataObsR,dataSimR]+ 1
    }
  }
  return (corDt)
}


conf.Mat <- BulidMatrix(comparaPermafrostMap$X2005, comparaPermafrostMap$X2006map)

kappa<-cohen.kappa(conf.Mat)
kappaVal<-as.double(kappa[[1]])
kappaVal


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapCompara.csv",sep='')
write.csv(basePermafrostMap, file = outPutName)

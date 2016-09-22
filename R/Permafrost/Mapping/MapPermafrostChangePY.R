
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


library(raster)
library(rgdal) # for spTransform


#************************************************************************************************
# define var name
#************************************************************************************************
rasterFileSim <- "F:/worktemp/Permafrost(Change)/Data/QTPMap/Tif/2006mapSim.tif"
rasterFileObs <- "F:/worktemp/Permafrost(Change)/Data/QTPMap/Tif/2006map.tif"

#************************************************************************************************
# 2  extract VALUE from raster 
#************************************************************************************************
#read Raster
rasterDataSim <- raster(rasterFileSim)
rasterFileObs <- raster(rasterFileObs)
lat <- init(rasterDataSim, 'y')
nrows <- rasterDataSim@nrows
resOA <- NULL
resYOA<-rep(c(0), 2)
for (i in 1:nrows) 
{
  #lat
  latRow<- getValues(lat,i)
  resYOA[1]<-latRow[1]
  #oa
  valueRowSim <- getValues(rasterDataSim,i)
  valueRowObs <- getValues(rasterFileObs,i)
  valueRow<-na.omit(valueRowSim == valueRowObs)
  idxTrue <- which(valueRow == TRUE, arr.ind = TRUE)
  lenIdxTrue <- length(idxTrue)
  lenRow <- length(valueRow)
  if(lenRow <=0 )
  {
    resYOA[2] = 0
  }
  else
  {
    resYOA[2] <- lenIdxTrue/lenRow
  }
  resOA<-rbind(resOA,resYOA)
}
#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/OA.csv",sep='')
write.csv(resOA, file = outPutName)

#
library(sp)
library(plyr) # need for dataset ozone


inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChange.CSV"

#use over
# read Data
permafrostMap    <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)


# for 
calpermafrostMapYear<-function(x)
{ 
  nLen<-length(x)
  idx<-which(x == 1, arr.ind = FALSE)
  nLen<-length(idx)
  strName<-names(x)[idx[nLen]]
  permafrostMapYear<-as.integer(strName)
  if(nLen <=0 )
  {
    permafrostMapYear<-NA
  }
  return(permafrostMapYear)
}

permafrostMap$PY <- apply(permafrostMap,1,calpermafrostMapYear)


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChangePY.csv",sep='')
write.csv(permafrostMap, file = outPutName)

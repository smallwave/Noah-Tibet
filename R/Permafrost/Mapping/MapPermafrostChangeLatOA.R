
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
rasterFile <- "F:/worktemp/Permafrost(Change)/Work/Res/PermafrostChangePY.tif"


#************************************************************************************************
# 2  extract VALUE from raster 
#************************************************************************************************
#read Raster
rasterData <- raster(rasterFile)
lat <- init(rasterData, 'y')
nrows <- rasterData@nrows

resOA <- NULL
resYOA<-rep(c(0), 2)
for (i in 1:nrows) 
{
  #lat
  latRow<- getValues(lat,i)
  resYOA[1]<-latRow[1]
  #oa
  valueRow <- getValues(rasterData,i)
  valueRow<-na.omit(valueRow)
  lenRowOmitNa = length(valueRow)
  if(lenRowOmitNa <=0 )
  {
    resYOA[2] = 0
  }
  else
  {
    idx <- which(valueRow != 1, arr.ind = TRUE)
    lenIdx <- length(idx)
    resYOA[2] <- lenIdx/lenRowOmitNa
  }
  
  resOA<-rbind(resOA,resYOA)
 
}


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/OA.csv",sep='')
write.csv(resOA, file = outPutName)


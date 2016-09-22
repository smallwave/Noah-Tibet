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


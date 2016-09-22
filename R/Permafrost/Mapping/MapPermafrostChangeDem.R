
##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160922 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################


library(sp)
library(plyr) # need for dataset ozone
library(raster)
library(rgdal) # for spTransform

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChangePY.csv"
rasterFile <- "E:/workspace/Write Paper/SoilTextureProduce/Data/DataSource/DEM/dem_tibet.tif"


#use over
# read Data
permafrostMap    <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)
permafrostMapCor <-permafrostMap

coordinates(permafrostMapCor) <- c("x","y")

rasterData <- raster(rasterFile)
demExtract <- extract(rasterData,permafrostMapCor,sp =TRUE)
demExtractDf <-demExtract@data
subDemExtractDf<-demExtractDf[c("ID","dem_tibet")]
permafrostMapDem <- merge(permafrostMap,subDemExtractDf,by.x="ID",by.y="ID")
permafrostMapDem <-permafrostMapDem[c("ID","x","y","dem_tibet","PY")]
# processs
resOA <- NULL

demCls <-seq(from = 0 , to = 8000 ,by = 200) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 4)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- first
  resYOA[2]<-end
  dfSel <- subset(permafrostMapDem, dem_tibet > first & dem_tibet < end)
  lendfSel <-nrow(dfSel)
  resYOA[3] <-lendfSel
  #oa
  valueCol<-na.omit(dfSel)
  lenRowOmitNa = nrow(valueCol)
  if(lenRowOmitNa <=0 )
  {
    resYOA[4] = 0
  }
  else
  {
    dfSel <- subset(valueCol, PY != 2012 )
    lendfSel <-nrow(dfSel)
    resYOA[4] <- lendfSel/lenRowOmitNa
  }
  
  resOA<-rbind(resOA,resYOA)
  
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostChangeDem.csv",sep='')
write.csv(resOA, file = outPutName)

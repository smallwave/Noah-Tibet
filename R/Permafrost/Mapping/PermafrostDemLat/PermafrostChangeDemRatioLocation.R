
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

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapChangeType.csv"
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

# processs
resOA <- NULL
demCls <-seq(from = 2000 , to = 8000 ,by = 100) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(permafrostMapDem, dem_tibet > first & dem_tibet < end,select = c(ID, X1983Map,Type))
  resYOA[2] <-sum(dfSel$Type ==2)
  #oa
  if(sum(dfSel$X1983Map ==1) == 0)
  {
    resYOA[3] = 0
  }
  else
  {
    resYOA[3] <- sum(dfSel$Type ==2)/sum(dfSel$X1983Map ==1)
  }
  resOA<-rbind(resOA,resYOA)
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostDegradationDemLocation.csv",sep='')
write.csv(resOA, file = outPutName)

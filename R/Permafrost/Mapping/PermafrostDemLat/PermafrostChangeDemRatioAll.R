
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
permafrostDegradation<- subset(permafrostMap, Type ==2, select = c(x, y,Type))
permafrostDegradation$ID<-seq.int(nrow(permafrostDegradation))
permafrostMapCor <-permafrostDegradation

coordinates(permafrostMapCor) <- c("x","y")

rasterData <- raster(rasterFile)
demExtract <- extract(rasterData,permafrostMapCor,sp =TRUE)
demExtractDf <-demExtract@data
subDemExtractDf<-demExtractDf[c("ID","dem_tibet")]
permafrostDegradationDem <- merge(permafrostDegradation,subDemExtractDf,by.x="ID",by.y="ID")
lenPermafrostDegradation <-nrow(permafrostDegradationDem)

# processs
resOA <- NULL
demCls <-seq(from = 0 , to = 9000 ,by = 500) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(permafrostDegradationDem, dem_tibet > first & dem_tibet < end)
  lendfSel <-nrow(dfSel)
  resYOA[2] <-lendfSel
  #oa
  resYOA[3] <- lendfSel/lenPermafrostDegradation
  resOA<-rbind(resOA,resYOA)
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostDegradationDem.csv",sep='')
write.csv(resOA, file = outPutName)

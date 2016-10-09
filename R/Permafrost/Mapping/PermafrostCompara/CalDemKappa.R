
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
rasterFileMap <- "F:/worktemp/Permafrost(Change)/Data/QTPMap/Tif/2005map.tif"                                  #1
rasterFileDem <- "E:/workspace/Write Paper/SoilTextureProduce/Data/DataSource/DEM/dem_tibet.tif"

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
subDemExtractDf<-demExtractDf[c("ID","X2005map")]                                                              #2
comparaPermafrostMap <- merge(permafrostMap,subDemExtractDf,by.x="ID",by.y="ID")

rasterData <- raster(rasterFileDem)
demExtract <- extract(rasterData,permafrostMapCor,sp =TRUE)
demExtractDf <-demExtract@data
subDemExtractDf<-demExtractDf[c("ID","dem_tibet")]
comparaPermafrostMapDem <- merge(comparaPermafrostMap,subDemExtractDf,by.x="ID",by.y="ID")


# processs
resOA <- NULL
demCls <-seq(from = 2000 , to = 6000 ,by = 100) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(comparaPermafrostMapDem, dem_tibet > first & dem_tibet < end) 
  dfSel <- na.omit(dfSel)
  resYOA[2] <- nrow(dfSel)
  if(nrow(dfSel) < 1)
  {
    resYOA[3] = 0
  }
  else
  {
    dfSelCom <- subset(dfSel, X2005 == X2005map)                                                              #3                                
    resYOA[3] <- nrow(dfSelCom)/nrow(dfSel)
  }
  resOA<-rbind(resOA,resYOA)
}


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapComparaDem.csv",sep='')
write.csv(resOA, file = outPutName)

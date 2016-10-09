
##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160926 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
library(sp)
library(plyr) # need for dataset ozone
library(raster)
library(rgdal) # for spTransform

#************************************************************************************************
# define var name
#************************************************************************************************

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapChangeType.csv"
rasterFileTemp <- "F:/worktemp/Permafrost(Change)/Work/Res/PermafrostChangeTemp.tif"


#use over
# read Data
permafrostMap    <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)
permafrostMapCor <-permafrostMap
coordinates(permafrostMapCor) <- c("x","y")

rasterData <- raster(rasterFileTemp)
demExtract <- extract(rasterData,permafrostMapCor,sp =TRUE)
demExtractDf <-demExtract@data
subDemExtractDf<-demExtractDf[c("ID","PermafrostChangeTemp")]
permafrostMapDemTemp <- merge(permafrostMap,subDemExtractDf,by.x="ID",by.y="ID")

#************************************************************************************************
# 2  extract VALUE from raster 
#************************************************************************************************
#use over
# processs
resOA <- NULL
demCls <-seq(from = 25 , to = 45 ,by = 0.2) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(permafrostMapDemTemp, y > first & y < end & X1983Map == 1,select = c(ID, X1983Map,Type,PermafrostChangeTemp))
  lendfSel <-nrow(dfSel)
  resYOA[2] <-lendfSel
  #oa
  resYOA[3] <- mean(dfSel$PermafrostChangeTemp)
  resOA<-rbind(resOA,resYOA)
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/TempLat.csv",sep='')
write.csv(resOA, file = outPutName)

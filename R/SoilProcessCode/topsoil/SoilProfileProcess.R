library(aqp)
library(plyr)
library(sp)
library(raster)
library(rgdal) # for spTransform
library(GSIF)
#
library(maptools)
library(sp)

#************************************************************************************************
# define var name
#************************************************************************************************
var <- "Gravel"
inputCvs <- "Input/AllTexture.csv"
rasterFile <- "Raster/GRAV_Clip"
shapeFile <- "Shp/selPloygon.shp"


#************************************************************************************************
# 1  mpspline
#************************************************************************************************
# read Data
soilData <- read.csv(inputCvs, head=TRUE,sep=",")
soilDataDF <- soilData
# Convert data 2 Profileclass
depths(soilData) <- ID ~ Top + Bottom 
# apply to each profile in a collection, and save as site-level attribute
soilData$depth <- profileApply(soilData, estimateSoilDepth, name='Horizon', top='Top', bottom='Bottom')
## fit a spline and Commbit res
soilDataSps <- mpspline(soilData, var.name = var,0.1,c(0,4.5,9.1,16.6,28.9,49.3,82.9,138.3,229.6))
soilDataSpsSTD <- soilDataSps$var.std
soilDataSpsID <- as.data.frame(soilDataSps$idcol)
soilDataSpsRes <- data.frame(soilDataSpsID,soilDataSpsSTD)
## Combit Res
soilDataRow <- soilDataDF[c("ID","Lon","Lat","Ali")]
soilDataRowUni <- unique(soilDataRow)
soilDataRes <- merge(soilDataRowUni,soilDataSpsRes,by.x="ID",by.y="soilDataSps.idcol",all.y=TRUE)

#************************************************************************************************
# 2  extract VALUE from raster 
#************************************************************************************************
coordinates(soilDataRes) <- c("Lon","Lat")
#read Raster
rasterData <- stack(rasterFile)
soilExtract <- extract(rasterData,soilDataRes,sp =TRUE)
soilExtractDf <-soilExtract@data
soilDataSpineRes <- merge(soilDataRowUni,soilExtractDf,by.x="ID",by.y="ID")

#************************************************************************************************
#  3 group point 
#************************************************************************************************
#library(maptools)
#library(sp)
#Read shapefile
shapefile <- readShapeSpatial("Shp/selPloygon.shp")
#use over
spatialPoint<- SpatialPoints(soilDataSpineRes[c("Lon","Lat")])
groupID <- over(spatialPoint,shapefile)
dtGroupID <- data.frame(ID=c(1:nrow(groupID)),groID=groupID[c("ID")])
names(dtGroupID)<-c('ID','groupID')
soilDataSpineGroupRes <- merge(soilDataSpineRes,dtGroupID,by.x="ID",by.y="ID",all.y=TRUE)

ncol<-ncol(soilDataSpineGroupRes)
for (i in 1:ncol) 
{
  soilDataSpineGroupRes[which(soilDataSpineGroupRes[,i]==-999, arr.ind=TRUE),i] <- NA
}

#************************************************************************************************
#  4 group median
#************************************************************************************************
sourceDataSample <- soilDataSpineGroupRes[6:13]
names<- names(sourceDataSample)
for(name in names)
{
  medianGroup <- ddply(soilDataSpineGroupRes, .(groupID),
                       .fun = function(xx, col) 
                       {
                         c(median = median(xx[[col]],na.rm=TRUE)
                         )
                       },
                       name)
  
  groupID <- soilDataSpineGroupRes[c("ID","groupID")]
  newCol<- merge(groupID,medianGroup,by.x="groupID",by.y="groupID",all.x=TRUE)
  newCol["groupID"]<-NULL
  
  newRes<- merge(soilDataSpineGroupRes,newCol,by.x="ID",by.y="ID",all.x=TRUE)
  newColName<-paste(name, "_Median",sep='')
  names(newRes)[names(newRes)=="median"] = newColName
  soilDataSpineGroupRes<-newRes
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste(var, ".csv",sep='')
write.csv(soilDataSpineGroupRes, file = outPutName)


library(soiltexture)
library(sp)
library(maptools)
library(miscTools)
library(RColorBrewer)
library(rgdal)
library(plotrix)
source("Code/Function.R")


#************************************************************************************************
# define var name
#************************************************************************************************
inputSoilDataPath <- "soilTextureClass/TEXT/TOP1.txt"
shapeFilePath<-"Shp/SOTERPOLY(TIBET).shp"
inputSoilDataCvs <- "Output/ssdSoilTextureProcess.csv"
outResPath <-"soilTextureClass/TOPSOIL/"

nLayer<-8

#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilData <- read.table(inputSoilDataPath, head=TRUE,sep=",")
replaceData <- read.csv(inputSoilDataCvs, head=TRUE,sep=",")
#************************************************************************************************
# 2  process
#************************************************************************************************
soilData[,1:2]<-list(NULL)
names(soilData)<-c("x","y","CLAY","SILT","SAND")

soilData$CLAY[soilData$CLAY == -999]<-NA
soilData$SILT[soilData$SILT == -999]<-NA
soilData$SAND[soilData$SAND == -999]<-NA

#************************************************************************************************
# 3  groupID
#************************************************************************************************
shapefile <- readShapeSpatial(shapeFilePath)  # eg "Shp/Ploygon.shp"
#use over
spatialPoint<- SpatialPoints(soilData[c("x","y")])
groupID <- over(spatialPoint,shapefile)
maxPolyID<-max(na.omit(groupID$GroupID))
groupID$GroupID[is.na(groupID$GroupID)]<-maxPolyID+1

soilData<-data.frame(soilData,groupID$GroupID)
names(soilData)<-c("x","y","CLAY","SILT","SAND","GroupID")

#************************************************************************************************
# 3  replaceData 
#************************************************************************************************

dataType <-"upd"
dataUpd<-soilTextureXYDataByLayer(replaceData,dataType,nLayer)

spatialPoint<- SpatialPoints(dataUpd[c("x","y")])
groupID <- over(spatialPoint,shapefile)

maxPolyID<-max(na.omit(groupID$GroupID))
groupID$GroupID[is.na(groupID$GroupID)]<-maxPolyID+1

dataUpd<-data.frame(dataUpd,groupID$GroupID)
names(dataUpd)<-c("x","y","CLAY","SILT","SAND","GroupID")
dataUpd<-dataUpd[!duplicated(dataUpd[,c('GroupID')]),]

#************************************************************************************************
# 4  replace
#************************************************************************************************
dataGroupIDs<-dataUpd$GroupID
nLen<-length(dataGroupIDs)
for(i in 1:nLen)
{
  equGroupID<-dataGroupIDs[i]
  soilData[soilData$GroupID == equGroupID,c("CLAY","SILT","SAND")]<- dataUpd[dataUpd$GroupID == equGroupID,c("CLAY","SILT","SAND")]
}

#************************************************************************************************
# 4  class
#************************************************************************************************
classData<-soilData[,c("CLAY","SILT","SAND")]
classData<-na.omit(classData)
classData<-TT.normalise.sum(classData)
soilDataUpd<-TT.points.in.classes( tri.data = classData,class.sys = "USDA.TT") 
calClass<-function(x)
{ 
  idx<-which(x != 0)
  return (idx[1])
}
soilClassIdx<-apply(soilDataUpd,1,calClass)
class(soilClassIdx)
tmpCls<-as.factor(as.character(soilClassIdx))
summary(tmpCls)

#************************************************************************************************
# 5 merge
#************************************************************************************************
soilClassRes<-data.frame(rownames(classData),soilClassIdx)
names(soilClassRes)<-c("ID","class")
soilClassRes$ID<-as.integer(as.character(soilClassRes$ID))
soilData<-data.frame(rownames(soilData),soilData)
names(soilData)<-c("ID","x","y","CLAY","SILT","SAND","GroupID")
soilData$ID<-as.integer(as.character(soilData$ID))

mapRes<- merge(soilData,soilClassRes,by.x="ID",by.y="ID",all.x=TRUE)
map.Polygon <- data.frame(mapRes[, c("x", "y","class")])

#************************************************************************************************
# 6 output
#************************************************************************************************
coordinates(map.Polygon) <- ~x + y
gridded(map.Polygon) <- TRUE

fname<-paste(outResPath,"Layer",nLayer,".tiff",sep='')
writeGDAL(map.Polygon,fname,drivername="GTiff", type="Int32", options=NULL)



library(sp)
library(raster)
library(maptools)
library(nnet)
library(rgdal)
library(psych) # kappa
library(RColorBrewer)
library(C50)
library(randomForest)
library(rpart)
library(kknn)
library(e1071)
source("Code/deepsoil/PubFun.R")
#************************************************************************************************
# define var name
#************************************************************************************************
obsFile <- "soilEnvi/deepSoilOBSENVI.csv"
covFile <- "soilEnvi/mutilSoil.txt"
outResPath <-"soilTextureClass/DEEPSOIL(RES)/"
#************************************************************************************************
# 2  read data 
#************************************************************************************************
ov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate

#************************************************************************************************
# 3  Function 
#************************************************************************************************
addUpLayer<-function(data,uplayerPath)
{
  data[,c("uplayer")] =NULL
  ovXY<-data[,c("x","y")]
  coordinates(ovXY) = c("x","y")
  rasterData <- stack(uplayerPath)
  uplayerExtract <- extract(rasterData,ovXY,sp =TRUE)
  uplayerExtractDf <-uplayerExtract@data
  uplayer<-as.data.frame(uplayerExtractDf[,ncol(uplayerExtractDf)])
  names(uplayer)<-c("uplayer")
  data<-data.frame(data,uplayer)
  return(data)
}

#************************************************************************************************
# 6  
#************************************************************************************************
obs_data<- read.csv(obsFile, head=TRUE,sep=",")
nLayer<-11
enviType<-8
isUplayer<-TRUE
if(isUplayer)
{
  uplayerPath<-"soilTextureClass/DEEPSOIL(RES)/DeepLayer_NOT_10_8_C50.tiff"
  ov_data<-addUpLayer(ov_data,uplayerPath)
  obs_data<-addUpLayer(obs_data,uplayerPath)
}
data<- getLayerDataForClass(nLayer,obs_data,isUplayer)
modelName<-"C50"
#*******************
# c50
#*******************
formula<-getFormula(enviType,data)
hv_C5 <- C5.0(formula,data = data)
map.RF <- predict(hv_C5, newdata = ov_data, type = "class")
summary(map.RF)

# #*********************
# # rpart
# #*********************
# formula<-getFormula(enviType,data)
# hv_RT <- rpart(formula,data=data)
# map.RF <- predict(hv_RT, newdata = ov_data, type = "class")
# summary(map.RF)
# 
# #*******************
# # Random Forests 
# #*******************
# formula<-getFormula(enviType,data)
# hv_RF <- randomForest(formula, data = data, importance=TRUE,proximity=TRUE)
# map.RF <- predict(hv_RF, newdata = ov_data, type = "class")
# summary(map.RF)
# 
# #*******************
# # MLR
# #*******************
# formula<-getFormula(enviType,data)
# hv_MNLR <- multinom(formula, data = data)
# map.RF <- predict(hv_MNLR, newdata = ov_data, type = "class")
# summary(map.RF)



#*******************
# Model Function
#*******************
map.PolygonNot <- data.frame(ov_data[, c("x", "y")],map.RF)
map.PolygonNot$map.RF<-as.numeric(as.character(map.PolygonNot$map.RF))
coordinates(map.PolygonNot) <- ~x + y
gridded(map.PolygonNot) <- TRUE
fname<-paste(outResPath,"DeepLayer_NOT_",nLayer,"_",enviType,"_",modelName,".tiff",sep='')
writeGDAL(map.PolygonNot,fname,drivername="GTiff", type="Int32", options=NULL)
#*************************************************
# table group
#*************************************************
map.RF <- cbind(data.frame(ov_data[, c("x", "y","groupID")]), map.RF)
map.RF$groupID<-as.factor(as.character(map.RF$groupID))
listRes<-tapply(map.RF$map.RF,map.RF$groupID,table)
listResDt<-as.data.frame(listRes)
listResDt<-data.frame(rownames(listResDt),listResDt)
names(listResDt)<-c("groupID","listNum")
listResDt<-data.frame(t(sapply(listResDt[,2], `[`)))
#*************************************************
# cal max number as class
#*************************************************
calClass<-function(x)
{ 
  nLen<-length(x)
  x<-x[1:nLen-1]
  idx<-which(x == max(x))
  strName<-names(x)[idx[1]]
  classNumber<-as.integer(substr(strName,2,nchar(strName)))
  return(classNumber)
}
listResDt$sum<-apply(listResDt,1,sum)
listResDt$class<-apply(listResDt,1,calClass)

listResDt<-data.frame(rownames(listResDt),listResDt)
names(listResDt)[1]<-c("groupID")
listResDt[,"groupID"]<-as.integer(as.character(listResDt[,"groupID"]))
#*************************************************
# merge
#*************************************************
map.RF$groupID<-as.integer(as.character(map.RF$groupID))
mapRes<- merge(map.RF,listResDt,by.x="groupID",by.y="groupID",all.x=TRUE)

#*************************************************
# output
#*************************************************
map.RFPolygon <- data.frame(mapRes[, c("x", "y","class")])
map.RFPolygon$class<-as.numeric(as.character(map.RFPolygon$class))

coordinates(map.RFPolygon) <- ~x + y
gridded(map.RFPolygon) <- TRUE

# area_colors <- brewer.pal(9, "Set1")
# spplot(map.RFPolygon, col.regions = area_colors, 
#        main = "Deep 9.7~ 10.2m Soil Texture of RF", key.space = "right", scales = list(draw = TRUE))

fname<-paste(outResPath,"DeepLayer",nLayer,"_",enviType,"_",modelName,".tiff",sep='')
writeGDAL(map.RFPolygon,fname,drivername="GTiff", type="Int32", options=NULL)









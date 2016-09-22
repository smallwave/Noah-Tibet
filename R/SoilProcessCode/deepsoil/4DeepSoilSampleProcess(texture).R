library(soiltexture)
library(sp)
library(raster)
#

#************************************************************************************************
# define var name
#************************************************************************************************
inputClayCvs <- "Output/deepClay.csv"
inputSiltCvs <- "Output/deepSilt.csv"
inputSandCvs <- "Output/deepSand.csv"
inputGravelCvs <- "Output/deepGravel.csv"

outVar <- "topSample2DeepSoil"

#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilClayData <- read.csv(inputClayCvs, head=TRUE,sep=",")
soilSiltData <- read.csv(inputSiltCvs, head=TRUE,sep=",")
soilSandData <- read.csv(inputSandCvs, head=TRUE,sep=",")
soilGravelData <- read.csv(inputGravelCvs, head=TRUE,sep=",")

dataBaseInfo <- soilClayData[,c(1:4,9)]

#************************************************************************************************
# 2  preocess
#************************************************************************************************
#   i<-6   # 6,7,8,9,10,11,12
for(i in 5:8)
{
  soilClayLayer<- soilClayData[,i]
  soilSiltLayer<- soilSiltData[,i]
  soilSandLayer<- soilSandData[,i]
  soilGravelLayer<- soilGravelData[,i]
  
  soilTextureLayer<-data.frame(soilClayLayer,soilSiltLayer,soilSandLayer,soilGravelLayer)
  soilTextureLayer<-na.omit(soilTextureLayer)
  soilTextureLayer <-  data.frame(rownames(soilTextureLayer),soilTextureLayer) 
  names(soilTextureLayer)<-c("ID","CLAY","SILT","SAND","GRAVEL")
  soilTextureLayer$ID<-as.integer(as.character(soilTextureLayer$ID))
  resTexture<-data.frame(soilTextureLayer$ID,NA)
  nameTe <- paste("H~",i,sep='')
  names(resTexture)<-c("ID",nameTe)
  for(j in 1:nrow(soilTextureLayer))
  {
    row<- soilTextureLayer[j,]
    if(row[5] > 50)
    {
      resTexture[j,2] = 13
    }
    else
    {
      stRow<-row[2:4]
      stRow<-TT.normalise.sum(stRow)
      textureCls<-TT.points.in.classes( tri.data = stRow,class.sys = "USDA.TT") 
      indexObs<-which(textureCls!= 0, arr.ind = TRUE) 
      resTexture[j,2]<-indexObs[2]
    }
  }
  dataBaseInfo<- merge(dataBaseInfo,resTexture,by.x="ID",by.y="ID",all.x=TRUE)
}

dataBaseInfo["Ali"]<-NULL
dataBaseInfo["H~5"]<-NULL

names(dataBaseInfo) <- c("DrillNo","x","y","Depths","1.38~2.296","2.296~3.2","3.2~4.2")
dataBaseInfo[,1]<-dataBaseInfo[,1]+1000
dataSample<-cbind(dataBaseInfo[,1:4],dataBaseInfo[,5:ncol(dataBaseInfo)])
dataSample<-cbind(dataSample[,1:ncol(dataSample)],NA,NA,NA,NA,NA,NA,NA,NA)
dataSample$Depths<- dataSample$Depths/100.0
#************************************************************************************************
# define var name
#************************************************************************************************
obsdeepSoilDataStandardPath<-"Output/deepSoilDataStandard.csv"
obsdeepSoilDataStandardData<- read.csv(obsdeepSoilDataStandardPath, head=TRUE,sep=",")
name<-names(obsdeepSoilDataStandardData)
names(dataSample)<-name

outPutName <- paste(outVar, ".csv",sep='')
write.csv(dataSample, file = outPutName)





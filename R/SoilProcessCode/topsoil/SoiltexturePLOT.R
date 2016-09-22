library(soiltexture)
library(Cairo)
source("Function.R")
#************************************************************************************************
# define var name
#************************************************************************************************
inputClayCvs <- "Clay.csv"
inputSiltCvs <- "Silt.csv"
inputSandCvs <- "Sand.csv"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
soilClayData <- read.csv(inputClayCvs, head=TRUE,sep=",")
soilSiltData <- read.csv(inputSiltCvs, head=TRUE,sep=",")
soilSandData <- read.csv(inputSandCvs, head=TRUE,sep=",")
********************************************************************************************
#2
#************************************************************************************************
nlayer <-7
outPutName <- paste("Image/Cairo",nlayer, ".png",sep='')
CairoPNG(file=outPutName,width=640,height=640)

data1<-getSoilTextureDataByLayerAndPloygon(soilClayData,soilSiltData,soilSandData,nlayer,3)
TT.plot( class.sys = "USDA.TT",grid.show=FALSE,arrows.show = FALSE,col=1,cex=1.5,tri.data =data1,pch=16,main = "")

data2<-getSoilTextureDataByLayerAndPloygon(soilClayData,soilSiltData,soilSandData,nlayer,9)
TT.points(tri.data =data2,geo=TT.geo.get(),col=2,cex=1.2,pch=16)

data3<-getSoilTextureDataByLayerAndPloygon(soilClayData,soilSiltData,soilSandData,nlayer,11)
TT.points(tri.data =data3,geo=TT.geo.get(),col=3,cex=0.8,pch=16)

data4<-getSoilTextureDataByLayerAndPloygon(soilClayData,soilSiltData,soilSandData,nlayer,12)
TT.points(tri.data =data4,geo=TT.geo.get(),col=4,cex=0.6,pch=16)

dev.off()






library(sp)
library(raster)
library(maptools)
library(rgdal) # for spTransform
#************************************************************************************************
# define var name
#************************************************************************************************
covFile <- "soilEnvi/deepSoilOBSENVI.csv"
rasterFile <- "soilEnvi/singal Envi(NEW)/CLIMATE"

#************************************************************************************************
# 2  read data 
#************************************************************************************************
ov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate

tmp<-ov_data[,2:3]
coordinates(tmp) <- c("x","y")

rasterData <- stack(rasterFile)
soilExtract <- extract(rasterData,tmp,sp =TRUE)
soilExtractDf <-soilExtract@data
names(soilExtractDf)<-c("climate")
ov_data["climate"]<-soilExtractDf["climate"]

write.csv(ov_data, file = "TEST.csv", row.names =FALSE)

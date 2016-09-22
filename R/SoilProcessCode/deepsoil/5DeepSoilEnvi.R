library(sp)
library(raster)
library(maptools)

#************************************************************************************************
# define var name
#************************************************************************************************

deepSoilDataStandardPath <- "Output/deepSoilDataStandard.csv"

topSample2DeepSoilPath <- "Output/topSample2DeepSoil.csv"

bnuSanplePath <- "Output/bunSample.csv"

outFile <- "soilEnvi/deepSoilOBSENVI.csv"

#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
deepSoilDataStandard <- read.csv(deepSoilDataStandardPath, head=TRUE,sep=",")
topSample2DeepSoil <- read.csv(topSample2DeepSoilPath, head=TRUE,sep=",")
bunSample<-read.csv(bnuSanplePath, head=TRUE,sep=",")
#************************************************************************************************
# 3  rbind deepdata
#************************************************************************************************
obs_dataNew<-rbind(deepSoilDataStandard,topSample2DeepSoil,bunSample)

#************************************************************************************************
# 4  uplayer value
#************************************************************************************************
obs_dataNew<-data.frame(obs_dataNew[,1:4],NA,obs_dataNew[,5:ncol(obs_dataNew)])
names(obs_dataNew)[5]<-c("X0.829~1.383")
ovXY<-obs_dataNew[,c("x","y")]
coordinates(ovXY) = c("x","y")
uplayerPath<-"soilTextureClass/TOPSOIL/Layer7.tiff"
rasterData <- stack(uplayerPath)
uplayerExtract <- extract(rasterData,ovXY,sp =TRUE)
uplayerExtractDf <-uplayerExtract@data
uplayer<-as.data.frame(uplayerExtractDf[,ncol(uplayerExtractDf)])
obs_dataNew[,5]<-uplayer

#************************************************************************************************
# 5  add ENVI
#************************************************************************************************
# covFile <- "soilEnvi/mutilSoil.txt"
# cov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate
# cov_data[,1]<-NULL
# write.table(cov_data, file = "mutilSoil.txt",sep = ",")

covFile <- "soilEnvi/mutilSoil.txt"
cov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate
coordinates(cov_data) = ~x+y
gridded(cov_data) = TRUE

exture <- over(ovXY,cov_data)
obs_dataNewRow<-cbind(obs_dataNew,exture)

write.csv(obs_dataNewRow, file = outFile,row.names = FALSE)

library(psych)

#************************************************************************************************
# define var name
#************************************************************************************************
obsFile <- "soilEnvi/deepSoilOBSENVI.csv"
rasterFile <- "../../Result(SoiltextureMap)/SOILTEXTURE(QTP)"
#************************************************************************************************
# 1  read data 
#************************************************************************************************
# read Data
obs_data<- read.csv(obsFile, head=TRUE,sep=",")
#************************************************************************************************
# 2  function
#************************************************************************************************
BulidMatrix <- function (dataObs, dataSim)
{
  corDt<-matrix(0,14,14,T)
  for(i in 1:length(dataObs))
  {
      dataObsRow<-dataObs[i]
      dataSimRow<-dataSim[i]
      corDt[dataObsRow,dataSimRow] = corDt[dataObsRow,dataSimRow]+ 1
  }
  return (corDt)
}

# 2015.11.21
GetLayerData <- function (soilExtractDf,layerNumber)
{
   obsCol <- layerNumber+3
   simCol <- layerNumber+30
   data   <-soilExtractDf[,c(obsCol,simCol)]
   dataNEW<- na.omit(data)
   dataObs <-dataNEW[,1]
   dataSim <-dataNEW[,2]
   dataList<-list(dataObs,dataSim)
   return (dataList)
}
  
  
  

#************************************************************************************************
# 2  extract VALUE from raster 
#************************************************************************************************
coordinates(obs_data) <- c("x","y")
#read Raster
rasterData <- stack(rasterFile)
soilExtract <- extract(rasterData,obs_data,sp =TRUE)
soilExtractDf <-soilExtract@data


layerNumber<-11
dataList <- GetLayerData(soilExtractDf,layerNumber)
dataObs<-dataList[[1]]
dataSim<-dataList[[2]]
build1<- BulidMatrix(dataObs,dataSim)
cohen.kappa(build1)
sum(diag(build1))/sum(build1)


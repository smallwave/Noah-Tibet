
# for obs 7 is 1
# for sim 16 is 1
# for medina 25 is 1

#************************************************************************************************
# define getSoilTextureDataByLayerAndPloygon
#************************************************************************************************
getSoilTextureDataByLayerAndPloygon <- function (soilClayData,soilSiltData,soilSandData,nLayer,nPloygon,isOmitAndNorma =TRUE) 
{
  groupClay <-soilClayData[which(soilClayData[,24]==nPloygon, arr.ind=TRUE),1:length(soilClayData)]
  groupSilt <-soilSiltData[which(soilSiltData[,24]==nPloygon, arr.ind=TRUE),1:length(soilSiltData)]
  groupSand <-soilSandData[which(soilSandData[,24]==nPloygon, arr.ind=TRUE),1:length(soilSandData)]
  
  groupData <- data.frame(
    "CLAY" = groupClay[nLayer],
    "SILT" = groupSilt[nLayer],
    "SAND" = groupSand[nLayer]
  ) #
  names(groupData)<-c("CLAY","SILT","SAND")
  #   for(i in 1:nrow(groupData))
  #   {
  #     scale <- 100.0/sum(groupData[i,])
  #     groupData[i,]<- groupData[i,]*scale
  #   }
  if(isOmitAndNorma)
  {  
     groupData<-na.omit(groupData)
     groupData<-TT.normalise.sum(groupData)
  }
  return (groupData)
}
#************************************************************************************************
# define SoilTextureDataByLayerAndPloygon
#************************************************************************************************
soilTextureDataByLayerAndPloygon <- function (soilData,dataType,nLayer,nPloygon,isOmitAndNorma =TRUE) 
{
  groupSoilTexture<-soilData[which(soilData["groupID"]==nPloygon),1:length(soilData)]
  names <-c("","","")
  if("obs"==dataType)
  {
    obsCl <- paste("obsCL", nLayer ,sep='')
    obsSl <- paste("obsSL", nLayer ,sep='')
    obsSA <- paste("obsSA", nLayer ,sep='')
    names <-c(obsCl,obsSl,obsSA)
  }
  if("sim"==dataType)
  {
    simCl <- paste("simCL", nLayer ,sep='')
    simSl <- paste("simSL", nLayer ,sep='')
    simSA <- paste("simSA", nLayer ,sep='')
    names <-c(simCl,simSl,simSA)
  }
  if ("upd"==dataType)
  {
    updCl <- paste("updCl", nLayer ,sep='')
    updSl <- paste("updSl", nLayer ,sep='')
    updSA <- paste("updSA", nLayer ,sep='')
    names <-c(updCl,updSl,updSA)
  }
  groupData <- groupSoilTexture[names]
  names(groupData)<-c("CLAY","SILT","SAND")
  if(isOmitAndNorma)
  {  
    groupData<-na.omit(groupData)
    groupData<-TT.normalise.sum(groupData)
  }
  return (groupData)
}


#************************************************************************************************
# 2  read data 
#************************************************************************************************
getSoilTextureDataByLayer <- function (soilClayData,soilSiltData,soilSandData,nLayer1,isOmitAndNorma =TRUE) 
{
  groupClayObs <-soilClayData[,nLayer1]
  groupSiltObs <-soilSiltData[,nLayer1]
  groupSandObs <-soilSandData[,nLayer1]
  groupDataObs <- data.frame(
    "ID" = soilClayData[,2],
    "CLAY" = groupClayObs,
    "SILT" = groupSiltObs,
    "SAND" = groupSandObs
  ) #
  
  if(isOmitAndNorma)
  {
    groupDataObs<-na.omit(groupDataObs)
    groupDataObs<-TT.normalise.sum(groupDataObs)
    rowName <- rownames(groupDataObs)
    groupDataObs <- data.frame("ID"=rowName,groupDataObs) 
  }
  return (groupDataObs)
}

#************************************************************************************************
# define getSoilTextureData
#************************************************************************************************
soilTextureDataByLayer <- function (soilData,dataType,nLayer,isOmitAndNorma =TRUE) 
{
  names <-c("","","")
  if("obs"==dataType)
  {
    obsCl <- paste("obsCL", nLayer ,sep='')
    obsSl <- paste("obsSL", nLayer ,sep='')
    obsSA <- paste("obsSA", nLayer ,sep='')
    names <-c(obsCl,obsSl,obsSA)
  }
  if("sim"==dataType)
  {
    simCl <- paste("simCL", nLayer ,sep='')
    simSl <- paste("simSL", nLayer ,sep='')
    simSA <- paste("simSA", nLayer ,sep='')
    names <-c(simCl,simSl,simSA)
  }
  if ("upd"==dataType)
  {
    updCl <- paste("updCl", nLayer ,sep='')
    updSl <- paste("updSl", nLayer ,sep='')
    updSA <- paste("updSA", nLayer ,sep='')
    names <-c(updCl,updSl,updSA)
  }
  groupData <- soilData[names]
  names(groupData)<-c("CLAY","SILT","SAND")
  if(isOmitAndNorma)
  {  
    groupData<-na.omit(groupData)
    groupData<-TT.normalise.sum(groupData)
  }
  return (groupData)
}


#************************************************************************************************
# define soilTextureXYDataByLayer
#************************************************************************************************
soilTextureXYDataByLayer <- function (soilData,dataType,nLayer) 
{
  names <-c("","","","","")
  if("obs"==dataType)
  {
    obsCl <- paste("obsCL", nLayer ,sep='')
    obsSl <- paste("obsSL", nLayer ,sep='')
    obsSA <- paste("obsSA", nLayer ,sep='')
    names <-c("Lon","Lat",obsCl,obsSl,obsSA)
  }
  if("sim"==dataType)
  {
    simCl <- paste("simCL", nLayer ,sep='')
    simSl <- paste("simSL", nLayer ,sep='')
    simSA <- paste("simSA", nLayer ,sep='')
    names <-c("Lon","Lat",simCl,simSl,simSA)
  }
  if ("upd"==dataType)
  {
    updCl <- paste("updCl", nLayer ,sep='')
    updSl <- paste("updSl", nLayer ,sep='')
    updSA <- paste("updSA", nLayer ,sep='')
    names <-c("Lon","Lat",updCl,updSl,updSA)
  }
  groupData <- soilData[names]
  names(groupData)<-c("x","y","CLAY","SILT","SAND")
  return (groupData)
}






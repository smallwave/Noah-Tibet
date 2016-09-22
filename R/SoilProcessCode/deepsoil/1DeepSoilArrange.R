

#************************************************************************************************
# define var name
#************************************************************************************************
deepSoilProfile <- "DeepSoil/deepSoilProfile.csv"
drill <- "DeepSoil/drill.csv"
outVar <- "deepSoilData"

#************************************************************************************************
# 2  read data 
#************************************************************************************************
drillData <- read.csv(drill, head=TRUE,sep=",")
deepSoilProfileData <- read.csv(deepSoilProfile, head=TRUE,sep=",")

#************************************************************************************************
# 3  Function 
#************************************************************************************************
# Top 
Top<-seq(0.2,15.7,0.5)
Botoom<-seq(Top[2],max(Top)+0.5,0.5)
# clay
clay<-c(1,19,47,48,49)
#siltyClay<-c(17,24,29,39,43,45,46,50)
loam<-c(2,16,17,20,24,28,29,33,35,39,40,42,43,45,46,50,54)
sandyLoam<-c(22,23,32,34,36,44,52,53)
silt<-c(6,37,38,41)
sand<-c(5,9,25,27,30,31,51)
Gravel<-c(7,15,18,26,27)
rock<-c(3,8,10,11,12,13,14)
#reArrangeSoilAttr
reArrangeSoilAttr<-function(x)
{
     if(x %in% clay)
     {
       x =  1
     }
     else if(x %in% loam)
     {
       x =  7
     }
     else if(x %in% sandyLoam)
     {
       x =  9
     }
     else if(x %in% silt)
     {
       x =  10
     }
     else if(x %in% sand)
     {
       x =  12
     }
     else if(x %in% Gravel)
     {
       x =  13
     }
     else if(x%in% rock)
     {
       x =  14
     }
}
# Function
deepSoilProfileProcess <- function (selDrill,selProfile) 
{
  seldepth<-selProfile[c("depthfrom","depthto")]
  maxsoilDepth<-max(seldepth[c("depthto")])
  soilAttr<-selProfile[c("soilattr")]
  meanSelDepth<-as.vector(apply(seldepth[],1, mean))
  
  selDrill<-selDrill[c("DrillNo","Altitude","Longitude","Latitude","DFrom")]
  selDrill["Depths"]<-maxsoilDepth
  for(i in 1:length(Top))
  {
    layerName <- paste("H",Top[i],"~",Botoom[i],sep='')
    selDrill[layerName]<- NA
    midPos<-(Botoom[i]-Top[i])/2+Top[i]
    if(midPos < maxsoilDepth)
    {
      sdDepth<-abs(meanSelDepth-midPos)
      idsdDepth<-which(sdDepth==min(sdDepth))
      
      soilAttrsel<-soilAttr[idsdDepth[1],]
      if(is.na(soilAttrsel))
      {
        soilAttrupdate<- NA
      }
      else
      {
        soilAttrupdate<- reArrangeSoilAttr(soilAttr[idsdDepth[1],])
      }
      selDrill[layerName]<- soilAttrupdate
    }
  }
  return (selDrill)
}

#************************************************************************************************
# 4  ProcessData
#************************************************************************************************
soilData = NULL
for(i in 1:nrow(drillData))
{
  selDrill<- drillData[i,]
  drillno <-as.integer(selDrill[1])
  selProfile <-deepSoilProfileData[which(deepSoilProfileData[c("drillno")]==drillno),]
  if(nrow(selProfile) > 0)
  {
    dt<-deepSoilProfileProcess(selDrill,selProfile)
    soilData <- rbind(soilData,dt)
  }
}

outPutName <- paste(outVar, ".csv",sep='')
write.csv(soilData, file = outPutName,row.names = FALSE)















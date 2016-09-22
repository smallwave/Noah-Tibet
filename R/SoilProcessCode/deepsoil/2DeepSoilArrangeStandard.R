

#************************************************************************************************
# define var name
#************************************************************************************************
deepSoilPath <- "Output/deepSoilData.csv"
outVar <- "deepSoilDataStandard"

#************************************************************************************************
# 2  read data 
#************************************************************************************************
deepSoilData <- read.csv(deepSoilPath, head=TRUE,sep=",")
nameLayers<-c("1.38~2.296","2.296~3.2","3.2~4.2","4.2~5.2","5.2~6.2","6.2~7.2","7.2~8.2","8.2~9.2","9.2~11.2","11.2~13.2","13.2~15.2")
listLayers<-list(c(8,9,10,11),c(10,11,12,13),c(12,13,14,15),c(14,15,16,17),c(16,17,18,19),c(18,19,20,21),c(20,21,22,23),
                 c(22,23,24,25),c(24,25,26,27,28,29),c(28,29,30,31,32,33),c(32,33,34,35,36,37))

#************************************************************************************************
# 3 reclass
#************************************************************************************************
calClass<-function(x)
{ 
  nLen<-length(x)
  if(nLen == 4)
  {
     xVal<-c(x[2],x[3])
     xVal<-na.omit(xVal)
     xVal<-unique(xVal)
     nLenVal<-length(xVal)
     if(nLenVal == 2)
     {
        xV<-c(t(x)) 
        tabX<-table(xV)
        tabXmax<-which(tabX == max(tabX))[1]
        return(as.integer(names(tabXmax)))
     }
     else if(nLenVal == 1)
     {
        return(xVal)
     }
     else if(nLenVal == 0)
     {
        return(NA)
     }
  }
  else if(nLen == 6)
  {
    xVal<-c(x[2],x[3],x[4],x[5])
    xVal<-na.omit(xVal)
    xVal<-unique(xVal)
    nLenVal<-length(xVal)
    if(nLenVal > 1)
    {
        xV<-c(t(x)) 
        tabX<-table(xV)
        tabXmax<-which(tabX == max(tabX))[1]
        return(as.integer(names(tabXmax)))
    }
    else if(nLenVal == 1)
    {
      return(xVal)
    }
    else if(nLenVal == 0)
    {
      return(NA)
    }
  }
}
#************************************************************************************************
# 4  process
#************************************************************************************************
soilDataStandard<-data.frame(deepSoilData[,1:6])
nameInfo<-names(soilDataStandard)
for(i in 1:length(nameLayers))
{
  listLayer<-listLayers[i]
  listLayerVec = do.call(c, listLayer)  
  deepSoillLayer<-deepSoilData[,listLayerVec]
  deepSoilStandardLayer<-apply(deepSoillLayer,1,calClass)
  soilDataStandard<-data.frame(soilDataStandard,deepSoilStandardLayer)
}
namesRes<-c(nameInfo,nameLayers)
names(soilDataStandard)<-namesRes
#************************************************************************************************
# 5 calMaxDepth
#************************************************************************************************
calMaxDepth<-function(x)
{ 
   vecLog<-is.na(x)
   if(!vecLog[17])
   {
     return (15.2)
   }
   else if(!vecLog[16])
   {
     return (13.2)
   }
   else if(!vecLog[15])
   {
     return (11.2)
   }
   else if(!vecLog[14])
   {
     return (9.2)
   }
   else if(!vecLog[13])
   {
     return (8.2)
   }
   else if(!vecLog[12])
   {
     return (7.2)
   }
   else if(!vecLog[11])
   {
     return (6.2)
   }
   else if(!vecLog[10])
   {
     return (5.2)
   }
   else if(!vecLog[9])
   {
     return (4.2)
   }
   else if(!vecLog[8])
   {
     return (3.2)
   }
   else if(!vecLog[7])
   {
     return (2.296)
   }
}
soilDataStandard$Depths<-apply(soilDataStandard,1,calMaxDepth)
#************************************************************************************************
# 6  output
#************************************************************************************************
soilDataStandard[c("Altitude")]<-NULL
soilDataStandard[c("DFrom")]<-NULL
names(soilDataStandard)<-c("DrillNo","x","y","Depths",
                           "X1.38~2.296","X2.296~3.2","X3.2~4.2","X4.2~5.2","X5.2~6.2",
                           "X6.2~7.2","X7.2~8.2","X8.2~9.2","X9.2~11.2","X11.2~13.2","X13.2~15.2")

outPutName <- paste(outVar, ".csv",sep='')
write.csv(soilDataStandard, file = outPutName,row.names = FALSE)

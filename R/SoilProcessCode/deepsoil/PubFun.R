#  Funcion 

#
getFormula <- function (enviType,data) 
{
  nameData<-names(data)
  if(enviType == 1)
  {
    formulaTmp<-paste(nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 2)
  {
    formulaTmp<-paste(nameData[2],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 3)
  {
    formulaTmp<-paste(nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 4)
  {
    formulaTmp<-paste(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 5)
  {
    formulaTmp<-paste(nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 6)
  {
    formulaTmp<-paste(nameData[2],nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 7)
  {
    formulaTmp<-paste(nameData[3],nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 8)
  {
    formulaTmp<-paste(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],nameData[10],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  return(formula)
}
#
getString <- function (enviType,data) 
{
  nameData<-names(data)
  if(enviType == 1)
  {
    formula<-c(nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 2)
  {
    formula<-c(nameData[2],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 3)
  {
    formula<-c(nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 4)
  {
    formula<-c(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 5)
  {
    formula<-c(nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 6)
  {
    formula<-c(nameData[2],nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 7)
  {
    formula<-c(nameData[3],nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 8)
  {
    formula<-c(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],nameData[10])
  }
  return(formula)
}
#
getLayerDataForCV <- function (iLayer,dataObs) {
  obsnames<-names(dataObs)
  NeighborColName<-obsnames[4+iLayer]
  colName<-obsnames[5+iLayer]
  xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi",NeighborColName)]
  xy<-na.omit(xy)
  xy[,1]<-as.factor(xy[,1])
  return(xy)
}
#
getLayerDataForClass <- function (iLayer,dataObs,isUplayer = FALSE) 
{
  obsnames<-names(dataObs)
  colName<-obsnames[5+iLayer]
  if(isUplayer)
  {
    xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi","uplayer")]
  }
  else
  {
    xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi")]
  }
  xy<-na.omit(xy)
  xy[,1]<-as.factor(xy[,1])
  return(xy)
}

#
getLayerDataForMARS <- function (iLayer,dataObs,isUplayer = FALSE) 
{
  obsnames<-names(dataObs)
  colName<-obsnames[5+iLayer]
  if(isUplayer)
  {
    xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi","uplayer")]
  }
  else
  {
    xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi")]
  }
  xy<-na.omit(xy)
  return(xy)
}

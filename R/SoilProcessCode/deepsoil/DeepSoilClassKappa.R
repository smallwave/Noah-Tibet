library(sp)
library(raster)
library(maptools)
library(GSIF)
library(nnet)
library(rgdal)
library(RSAGA)
library(psych) # kappa
library(RColorBrewer)
library(C50)
library(randomForest)
library(rpart)
#************************************************************************************************
# define var name
#************************************************************************************************
obsFile <- "soilEnvi/soilOBSENVI(SAMPLE).csv"
# covFile <- "soilEnvi/soilENVISELNEW.txt"


#************************************************************************************************
# 2  read data 
#************************************************************************************************
obs_data<- read.csv(obsFile, head=TRUE,sep=",")
# ov_data<- read.table(covFile, header = TRUE, sep = ",") # the covariate


#************************************************************************************************
# 3  Function 
#************************************************************************************************
getLayerData <- function (iLayer,dataObs) {
  obsnames<-names(dataObs)
  NeighborColName<-obsnames[5+iLayer]
  colName<-obsnames[6+iLayer]
  xy<-dataObs[,c(colName,"climate","quad","alititude","slope","aspect","plan","profile","twi",NeighborColName)]
  xy<-na.omit(xy)
  xy[,1]<-as.factor(xy[,1])
  return(xy)
}

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
    formulaTmp<-paste(nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
    formula<-as.formula(paste(nameData[1], " ~ ",formulaTmp,sep='')) 
  }
  else if(enviType == 5)
  {
    formulaTmp<-paste(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9],sep='+')
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
    formula<-c(nameData[10],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
  }
  else if(enviType == 5)
  {
    formula<-c(nameData[2],nameData[3],nameData[4],nameData[5],nameData[6],nameData[7],nameData[8],nameData[9])
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
changeValue<-function(val)
{
  if(val == 5)
  {
    val = 3
  } 
  else if(val == 9)
  {
    val = 4
  }
  else if(val == 11)
  {
    val = 5
  }
  else if(val == 12)
  {
    val = 6
  }
  else if(val == 13)
  {
    val = 7
  }
  else if(val == 14)
  {
    val = 8
  }
  return(val)
}

BulidMatrix <- function (dataObs, dataSim)
{
  dataObs<-cal.dat[,1]
  dataSim<-cal.dat$pred
  dataObsTmp<-as.integer(as.character(dataObs))
  dataSimTmp<-as.integer(as.character(dataSim))
  corDt<-matrix(0,8,8,T)
  for(i in 1:length(dataObsTmp))
  {
     dataObsR<-dataObsTmp[i]
     dataSimR<-dataSimTmp[i]
     corDt[changeValue(dataObsR),changeValue(dataSimR)] = corDt[changeValue(dataObsR),changeValue(dataSimR)]+ 1
  }
  return (corDt)
}

#************************************************************************************************
# 3  MLR
#************************************************************************************************
reskappaVec<-rep(c(0), 8)
nLayer<-17
for(i in 1:8)
{
  data<- getLayerData(nLayer,obs_data)
  formula<-getFormula(i,data)

  
  hv_MNLR <- multinom(formula, data = data)

  cal.dat <- as.data.frame(data)
  cal.dat$pred <- predict(hv_MNLR,newdata = data)
  
  conf.Mat <- BulidMatrix(cal.dat[,1], cal.dat$pred)
  kappa<-cohen.kappa(conf.Mat)
  kappaVal<-as.double(kappa[[1]])
  reskappaVec[i]<-kappaVal
}
reskappaVec

#************************************************************************************************
# 4  C50
#************************************************************************************************
reskappaVec<-rep(c(0), 8)
nLayer<-18
for(i in 1:8)
{
  data<- getLayerData(nLayer,obs_data)
  colStr<-getString(i,data)

  hv_C5 <- C5.0(x = data[,colStr], 
                y = data[,1],
                control = C5.0Control(CF = 0.95, minCases = 2, earlyStopping = FALSE))
  
  cal.dat <- as.data.frame(data)
  cal.dat$pred <- predict(hv_C5, newdata = data)
  
  conf.Mat <- BulidMatrix(cal.dat[,1], cal.dat$pred)
  kappa<-cohen.kappa(conf.Mat)
  kappaVal<-as.double(kappa[[1]])
  reskappaVec[i]<-kappaVal
}
reskappaVec

#************************************************************************************************
# 6  Random Forests
#************************************************************************************************
reskappaVec<-rep(c(0), 8)
nLayer<-17
for(i in 1:8)
{
  data<- getLayerData(nLayer,obs_data)
  formula<-getFormula(i,data)
  
  hv_RF <- randomForest(formula, data = data, importance=TRUE,
                        proximity=TRUE)
  
  cal.dat <- as.data.frame(data)
  cal.dat$pred <- predict(hv_RF, newdata = data)
  
  conf.Mat <- BulidMatrix(cal.dat[,1], cal.dat$pred)
  kappa<-cohen.kappa(conf.Mat)
  kappaVal<-as.double(kappa[[1]])
  reskappaVec[i]<-kappaVal
}
reskappaVec 
  

#************************************************************************************************
# 5  Regression Trees
#************************************************************************************************
xy<-obs_data[,c("H9.7.10.2","climate","quad","alititude","slope","aspect","plan","profile","twi")]
xy<-na.omit(xy)
xy <- as.data.frame(xy)
xy$H9.7.10.2<-as.factor(xy$H9.7.10.2)
edge.RT.Exp <- rpart(H9.7.10.2 ~ climate + quad + alititude + slope +
                       aspect + plan + profile + twi, data = xy, method = "class",
                       control = rpart.control(minsplit = 5))

summary(edge.RT.Exp)

printcp(edge.RT.Exp)
plot(edge.RT.Exp)
text(edge.RT.Exp)

plotcp(edge.RT.Exp)

RT.pred.V <- predict(edge.RT.Exp, xy)


map.RT <- predict(edge.RT.Exp, newdata = cov_data, type = "class")
summary(map.RT)
map.RT <- cbind(data.frame(cov_data[, c("x", "y")]), map.RT)
coordinates(map.RT) <- ~x + y
gridded(map.RT) <- TRUE
spplot(map.RT, col.regions = area_colors, 
       main = "Deep 9.7~ 10.2m Soil Texture of RT", key.space = "right", scales = list(draw = TRUE))






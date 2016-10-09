
##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160921 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
#
library(sp)
library(plyr) # need for dataset ozone

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostChangePY.csv"
startYear<-1983
EndYear<-2012
#use over
# read Data
permafrostMap <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)


startCol<- startYear - 1979
startRange <- c(startCol-1,startCol,startCol+1)
if(startYear == 1983)
{
  startRange <-c(4:6)
}
endCol<- EndYear - 1979
endRange <- c(endCol-1,endCol,endCol+1)

startSel<-permafrostMap[,startRange]
endSel<-permafrostMap[,endRange]


# calpermafrostType
calpermafrostType<-function(x)
{ 
  counts <- table(x)
  return (as.integer(names(counts)[which.max(counts)]))
}

firstMap <- apply(startSel,1,calpermafrostType)
endMap <- apply(endSel,1,calpermafrostType)
totalMap<- data.frame(firstMap,endMap)

# increase 
calpermafrostUnchange <-function(x)
{
  if(x[1] == 1 && x[2] == 1)
  {
    return (1)   #unchange
  }
  else if(x[1] == 1)
  {
    return (2)   #decrease
  }
  else if(x[2] == 1)
  {
    return (3)   #increase
  }
  else
  {
    return (4)   #other
  }
}
totalMap$unChange<-apply(totalMap,1,calpermafrostUnchange)
table(totalMap$unChange)

names(totalMap)<-c("1983Map","2012Map","Type")


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChangeType.csv",sep='')
write.csv(outPm, file = outPutName)


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

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapChange.csv"
startYear<-c(1988,1996,2005)

setBeforeYear <-5
#use over
# read Data
permafrostMap <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)


endCol<- startYear - 1979
startCol<- endCol -setBeforeYear + 1

lens <- length(endCol)

# calpermafrostType
calpermafrostType<-function(x)
{ 
  counts <- table(x)
  return (as.integer(names(counts)[which.max(counts)]))
}

basePermafrostMap <- permafrostMap[,c("x","y")]

for (i in 1:lens) 
{
  startRange <-seq(from = startCol[i], to = endCol[i] ,by = 1) 
  permafrostMapSel<-permafrostMap[,startRange]
  permafrostMapType <- apply(permafrostMapSel,1,calpermafrostType)
  basePermafrostMap$updateName <-permafrostMapType
  names(basePermafrostMap)[names(basePermafrostMap) == 'updateName'] <- as.character(startYear[i])
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapCompara.csv",sep='')
write.csv(basePermafrostMap, file = outPutName)


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


inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChange.CSV"

#use over
# read Data
permafrostMap    <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)


# for 
calpermafrostMapYear<-function(x)
{ 
  nLen<-length(x)
  idx<-which(x == 1, arr.ind = FALSE)
  nLen<-length(idx)
  strName<-names(x)[idx[nLen]]
  permafrostMapYear<-as.integer(strName)
  if(nLen <=0 )
  {
    permafrostMapYear<-NA
  }
  return(permafrostMapYear)
}

permafrostMap$PY <- apply(permafrostMap,1,calpermafrostMapYear)


#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostMapChangePY.csv",sep='')
write.csv(permafrostMap, file = outPutName)

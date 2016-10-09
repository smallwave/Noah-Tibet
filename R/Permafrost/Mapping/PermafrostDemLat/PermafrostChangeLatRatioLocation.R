
##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160926 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################


library(sp)
library(plyr) # need for dataset ozone
library(raster)
library(rgdal) # for spTransform

inputCvs <- "F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostMapChangeType.csv"

#use over
# read Data
permafrostMap    <- read.csv(inputCvs, head=TRUE,sep=",",check.names=FALSE)

# processs
# processs
resOA <- NULL
demCls <-seq(from = 25 , to = 45 ,by = 0.2) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(permafrostMap, y > first & y < end,select = c(ID, X1983Map,Type))
  resYOA[2] <-sum(dfSel$Type ==2)
  #oa
  if(sum(dfSel$X1983Map ==1) == 0)
  {
    resYOA[3] = 0
  }
  else
  {
    resYOA[3] <- sum(dfSel$Type ==2)/sum(dfSel$X1983Map ==1)
  }
  resOA<-rbind(resOA,resYOA)
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostDegradationLatLocation.csv",sep='')
write.csv(resOA, file = outPutName)

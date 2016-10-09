
##########################################################################################################
# NAME
#    
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160922 -- Initial version created and posted online
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
permafrostDegradation<- subset(permafrostMap, Type ==2, select = c(x, y,Type))
lenPermafrostDegradation <-nrow(permafrostDegradationDem)

# processs
resOA <- NULL
demCls <-seq(from = 26 , to = 44 ,by = 2) 
lenDemCls<-length(demCls) -1
for (i in 1:lenDemCls) 
{
  resYOA<-rep(c(0), 3)
  first <-demCls[i]
  end <-demCls[i+1]
  resYOA[1]<- end
  dfSel <- subset(permafrostDegradationDem, y > first & y < end)
  lendfSel <-nrow(dfSel)
  resYOA[2] <-lendfSel
  #oa
  resYOA[3] <- lendfSel/lenPermafrostDegradation
  resOA<-rbind(resOA,resYOA)
}

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("F:/worktemp/Permafrost(Change)/Work/Res/CVS/PermafrostDegradationDem.csv",sep='')
write.csv(resOA, file = outPutName)

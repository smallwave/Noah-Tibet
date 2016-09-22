library(GSIF)
library(aqp)
#************************************************************************************************
# define var name
#************************************************************************************************
var <- "Clay"
inputCvs <- "Input/AllTexture.csv"

#************************************************************************************************
# 1  mpspline
#************************************************************************************************
# read Data
soilData <- read.csv(inputCvs, head=TRUE,sep=",")
soilDataDF <- soilData
# Convert data 2 Profileclass
depths(soilData) <- ID ~ Top + Bottom 
# apply to each profile in a collection, and save as site-level attribute
soilData$depth <- profileApply(soilData, estimateSoilDepth, name='Horizon', top='Top', bottom='Bottom')
## fit a spline and Commbit res
soilDataSps <- mpspline(soilData, var.name = var,0.1,c(0,138.3,229.6,320,420))
soilDataSpsSTD <- soilDataSps$var.std
soilDataSpsID <- as.data.frame(soilDataSps$idcol)
soilDataSpsRes <- data.frame(soilDataSpsID,soilDataSpsSTD)
## Combit Res
soilDataRow <- soilDataDF[c("ID","Lon","Lat","Ali")]
soilDataRowUni <- unique(soilDataRow)
soilDataRes <- merge(soilDataRowUni,soilDataSpsRes,by.x="ID",by.y="soilDataSps.idcol",all.y=TRUE)

#************************************************************************************************
# 5  write 
#************************************************************************************************
## Write res
outPutName <- paste("deep",var, ".csv",sep='')
write.csv(soilDataRes, file = outPutName)







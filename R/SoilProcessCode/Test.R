library(sp)
library(rgdal)

# Extraction of metadata via `GDALinfo`    
filename <- "D:\\In\\MOD07_L2.A2012001.0310.006.2015055130244.hdf"
gdalinfo <- GDALinfo(filename, returnScaleOffset = FALSE)
metadata <- attr(gdalinfo, "subdsmdata")

# Extraction of SDS string for parameter 'Skin_Temperature' (formerly 'Surface_Temperature')    
sds <- metadata[grep("Skin_Temperature", metadata)[1]]
sds <- sapply(strsplit(sds, "="), "[[", 2)

# Raster import via `readGDAL`   
sds.rg <- readGDAL(sds)

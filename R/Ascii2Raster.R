##########################################################################################################
# NAME
#    Ascii2Raster.R
# PURPOSE
#     1 Ascii to  raster
#     2 Clip  by  shapefile
# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151109 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
library(sp)
library(rgdal)
library(raster)
library(stringr)
library(plyr)


#asciiPath
inputAscii  <-  "D:/Temp/Input/"
#outputPath
inputRaster <-  "D:/Temp/Output/"
#clipMask
inputShp    <-  "E:/wsp/shp/heihe.shp"


#get files
asciifiles <- list.files(inputAscii,full.names = TRUE)
shapefile  <- readShapeSpatial(inputShp)

#batch process
for(asciifilepath in asciifiles)
{
  # 1
  #get output filename
  filename   = basename(asciifilepath)
  filename   = substr(filename,0,nchar(filename)-4)
  rsfilePath = paste(inputRaster, filename,".tif",sep="")
  
  # 2
  #read data
  grid <- readAsciiGrid(asciifilepath,proj4string = CRS(proj4string(shp)))
  #change to raster
  newRaster<-raster(grid)
  #subset raster
  newRaster_sub <- crop(newRaster, extent(shapefile))
  #mask raster
  newRaster_msk <- mask(newRaster_sub,shapefile)
  
  # 3
  #write result
  writeRaster(newRaster_msk, filename=rsfilePath, format="GTiff", overwrite=TRUE)
}


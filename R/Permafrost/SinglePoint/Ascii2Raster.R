##########################################################################################################
# NAME
#    Ascii2Raster.R
# PURPOSE
#     1 Ascii to  raster
#     2 Clip  by  shapefile
# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    2015.11.09  -- Initial version created and posted online
#    2015.11.25  -- Add output ascii
#
# REFERENCES
##########################################################################################################
library(sp)
library(rgdal)
library(raster)
library(maptools)

#asciiPath
inputAscii  <-  "D:/Temp/Input/"
#outputPath
outputPath  <-  "D:/Temp/Output/"
#clipMask
inputShp    <-  "E:/WANGLIN/CFMD/shp/1200.shp"
#if or not output
isOutputTif <- FALSE

##########################################################################################################

#get files
asciifiles <- list.files(inputAscii,full.names = FALSE)

dsn="E:/WANGLIN/CFMD/shp"
ogrInfo(dsn=dsn, layer="1200")
shapefile <- readOGR(dsn=dsn, layer="1100",encoding = "SHAPE_ENCODING")
print(proj4string(shapefile))

# shapefile  <- readShapePoly(inputShp)
map_wgs84  <- spTransform(shapefile, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

##########################################################################################################
#batch process
for(asciifilepath in asciifiles)
{
  # 1
  #get output filename
  filename      = basename(asciifilepath)
  filename      = substr(filename,0,nchar(filename)-4)
  asciifilePath = paste(outputPath, filename,".txt",sep="")
  
  # 2
  #read data
  grid <- readAsciiGrid(asciifilepath,proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

  #change to raster
  newRaster<-raster(grid)
  #subset raster
  newRaster_sub <- crop(newRaster, extent(shapefile))
  
  #mask raster
  newRaster_msk <- mask(newRaster_sub,shapefile)
  
  # 3
  #write result
  if(isOutputTif)
  {
    rsfilePath = paste(outputPath, filename,".tif",sep="")
    writeRaster(newRaster_sub, filename=rsfilePath, format="GTiff", overwrite=TRUE)
  }
  asciinewRaster_msk <- as(newRaster_msk, "SpatialGridDataFrame")
  writeAsciiGrid(asciinewRaster_msk, asciifilePath)
}


##########################################################################################################
# NAME
#    Ascii2Raster.R
# PURPOSE
#     1 Ascii to  raster
#     2 Clip  by  shapefile
# PROGRAMMER(S)
#   wuxb

".txt"
# REVISION HISTORY
#    2015.11.09  -- Initial version created and posted online
#    2015.11.25  -- Add output ascii
#    2015.12.3  -- Add shp batch process
# REFERENCES
##########################################################################################################
library(sp)
library(rgdal)
library(raster)
library(maptools)
#asciiPath
inputAscii  <-  "D:/Temp/Input/"
#shppath
inputShp  <-  "E:/WANGLIN/CFMD/shp/"
outputPath  <- "D:/Temp/Output/"
#if or not output
isOutputTif <- FALSE
#get files
Shpfiles <- list.files(inputShp,full.names = TRUE,pattern="\\.shp$")
asciifiles <- list.files(inputAscii,full.names = TRUE)

#shp batch process
for(Shpfilepath in Shpfiles)
{
  # 1
  #get output filename
  shpfilename      = basename(Shpfilepath)
  shpfilename      = substr(shpfilename,0,nchar(shpfilename)-4)
  #the path of input shpfile to mask ASCII dataset
  shpfilePath = paste(inputShp, shpfilename,".shp",sep="")
  shapefile <- readShapeSpatial(shpfilePath)
  
  #create folders named shpfilename,shpfilename is a variable
  #setwd is the function to set the current directory
  setwd("F:/download_dataset/grid_clip_byshp/clip_dataset/Output/grid_pre_dataset_0.5")
  dir.create(shpfilename)
  #change the outputpath 
  outputPath  <- paste("F:/download_dataset/grid_clip_byshp/clip_dataset/Output/grid_pre_dataset_0.5/",shpfilename,sep="")
  #asciifilePath = paste(outputPath,shpfilename,filename,".txt",sep="")
   #ASCII batch process
  for(asciifilepath in asciifiles)
  {
    #1
    #get output filename
    filename      = basename(asciifilepath)
    filename      = substr(filename,0,nchar(filename)-4)
    asciifilePath = paste(outputPath,shpfilename,filename,".txt",sep="")
    
    # 2
    #read data
    grid <- readAsciiGrid(asciifilepath,proj4string = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
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
      writeRaster(newRaster_msk, filename=rsfilePath, format="GTiff", overwrite=TRUE)
    }
    asciinewRaster_msk <- as(newRaster_msk, "SpatialGridDataFrame")
    writeAsciiGrid(asciinewRaster_msk, asciifilePath)
  }

}
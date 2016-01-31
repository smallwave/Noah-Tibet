##########################################################################################################
# NAME
#    UpdateForceTxt.py
# PURPOSE
#   UpdateForceTxt
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151231 -- Initial version created and posted online
# REFERENCES
##########################################################################################################
import os
import linecache
import datetime 
from osgeo import gdal,ogr
import struct

class cForceTxtUpdate(object):
    """description of class"""
    def __init__(self,strtxtFilePathIn):
        self.strtxtFilePath    =  strtxtFilePathIn;
    # replace txtfile
    def replace_outputPath(self,output_dir):
        newLine   = ' output_dir            = "{}"\n'.format(output_dir)
        return newLine
    # update txtfile        
    def updateOutput(self,strOutputDir):
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... updateOutputDirLine
            updateLine            =  5   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            newLine               =  self.replace_outputPath(strOutputDir)
            lines[updateLine -1]  = newLine
            #... deepSoilTemperature
            updateLine            =  20   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            lineTxts              =  lineTxt.split('=')
            lineTxtTemp           =  float(lineTxts[1]) + 273.15
            newLine               =  ' Deep_Soil_Temperature = {}\n'.format(lineTxtTemp) 
            lines[updateLine -1]  =  newLine

            txtFile.seek(0)
            txtFile.writelines(lines)
    # update Skin temperature
    def updateSkinTemp(self,skintemp): 
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... deepSoilTemperature
            updateLine            =  16   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            newLine               =  ' Skin_Temperature      = {}\n'.format(skintemp) 
            lines[updateLine -1]  =  newLine

            txtFile.seek(0)
            txtFile.writelines(lines)  
    #update end time  2016.1.26
    def updateEndTime(self,enddate):
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... deepSoilTemperature
            updateLine            =  3   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            newLine               = ' enddate               = "{}"\n'.format(enddate.strftime("%Y%m%d%H%M"))
            lines[updateLine -1]  =  newLine
            txtFile.seek(0)
            txtFile.writelines(lines)  
    #update sfcdif_option by vegtable 2015.1.26
    def updateSfcdif_Option(self):
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... deepSoilTemperature
            updateLine            =  23   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            lineTxts              =  lineTxt.split('=')
            lineTxtTemp           =  int(lineTxts[1])
            if lineTxtTemp < 19 :
               updateLine            = 34
               newLine               =' sfcdif_option         = {}\n'.format(1)
               lines[updateLine -1]  =  newLine
               txtFile.seek(0)
               txtFile.writelines(lines)
    #update sfcdif_option by vegtable 2015.1.26            
    def updateSfcdif_OptionByNDVI(self):
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... GET NDVI
            src_filename = 'E:/worktemp/Permafrost(MAPPING)/Data/NDVI/QTPNDVI10.tif'
            src_ds=gdal.Open(src_filename) 
            gt=src_ds.GetGeoTransform()
            rb=src_ds.GetRasterBand(1)
             
            InputFileDir,InputFile   = os.path.split(self.strtxtFilePath)
            filename, file_extension = os.path.splitext(InputFile)
            FileNameS                = filename.split("_")  
            #Convert from map to pixel coordinates.
            #Only works for geotransforms with no rotation.
            mx = float(FileNameS[0])
            my = float(FileNameS[1])
            px = int((mx - gt[0]) / gt[1]) #x pixel
            py = int((my - gt[3]) / gt[5]) #y pixel

            structval=rb.ReadRaster(px,py,1,1,buf_type=gdal.GDT_UInt16) #Assumes 16 bit int aka 'short'
            intval = struct.unpack('h' , structval) #use the 'short' format code (2 bytes) not int (4 bytes)
            Sfcdif_Option = 1
            if intval[0] < 70:                 #intval is a tuple, length=1 as we only asked for 1 pixel value
                Sfcdif_Option = 2
            updateLine            = 34
            newLine               =' sfcdif_option         = {}\n'.format(Sfcdif_Option)
            lines[updateLine -1]  =  newLine
            txtFile.seek(0)
            txtFile.writelines(lines)  
    
﻿##########################################################################################################
# NAME
#    PointForceData2Txt.py
# PURPOSE
#   force date to txt for Noah LSM
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20150915 -- Initial version created and posted online
#    20150916 -- update UPDateCFMDData(class)
#    20151029 -- update scale factor and add qair2rh
# REFERENCES

##########################################################################################################from datetime import *  
import os
import glob 
import datetime 
import time 
import numpy as np
import math
from netCDF4 import Dataset 
from netCDF4 import num2date
###################################################################################
# Class write struct 
###################################################################################
class sPointForceData(object):
    startdate                =  datetime.datetime(2004,1,1)
    enddate                  =  datetime.datetime(2011,1,1)
    loop_for_a_while         =  10
    output_dir               =  "."
    Latitude                 =  33.072      # lat  
    Longitude                =  91.939      # lon  
    Forcing_Timestep         =  10800
    Noahlsm_Timestep         =  10800
    Sea_ice_point            =  False
    Soil_layer_thickness     =  [0.04,0.06,0.04,0.16,0.24,0.36,0.04,0.26,0.44,0.26,0.44,0.26,0.44,1.16,0.64,1.36,0.64,1.36,0.64,1.36,1.64,2.36,1.64]
    Soil_Temperature         =  [277.8238,278.419,279.163,279.657,276.335,274.047,272.954,272.244,271.682,271.359,271.111,270.981,270.927,270.796,270.826,270.946,271.132,271.407,271.649,271.853,272.037,272.125,272.172]
    Soil_Moisture            =  [0.151,0.111,0.04,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    Soil_Liquid              =  [0.151,0.111,0.04,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    Soil_htype               =  [3,3,3,17,17,17,17,14,14,14,16,16,16,14,14,14,14,14,14,14,14,14,14]
    Skin_Temperature         =  263.6909
    Canopy_water             =  3.9353027E-04   #Canopy moisture content (kg m-2)
    Snow_depth               =  1.0600531E-03   #Water equivalent accumulated snow depth (m)
    Snow_equivalent          =  2.0956997E-04
    Deep_Soil_Temperature    =  288
    Landuse_dataset          =  "USGS"
    Soil_type_index          =  3
    Vegetation_type_index    =  7
    Urban_veg_category       =  1
    glacial_veg_category     =  24
    Slope_type_index         =  1               #Slope category
    Max_snow_albedo          =  0.75
    Air_temperature_level    =  3.0
    Wind_level               =  6.0 
    Green_Vegetation_Min     =  0.01
    Green_Vegetation_Max     =  0.36
    Usemonalb                =  False
    Rdlai2d                  =  False
    sfcdif_option            =  2
    iz0tlnd                  =  0
    Albedo_monthly           =  [0.18,0.17,0.16,0.15,0.15,0.15,0.15,0.16,0.16,0.17,0.17,0.18]
    Shdfac_monthly           =  [0.01,0.02,0.07,0.17,0.27,0.58,0.93,0.96,0.65,0.24,0.11,0.02]
    lai_monthly              =  [4.00,4.00,4.00,4.00,4.00,4.00,4.00,4.00,4.00,4.00,4.00,4.00]
    Z0brd_monthly            =  [0.020,0.020,0.025,0.030,0.035,0.036,0.035,0.030,0.027,0.025,0.020,0.020]
    #
    CFMDData                 =  []

###################################################################################
# Class update struct txtinfo
###################################################################################
class upDateTxtInfo(object):
     def __init__(self):
         print "UPDateTxtInfo"

###################################################################################
# Class update CFMD txtinfo
###################################################################################
class upDateCFMDData(object):
    sForceTxt           = 0 
    strncDataPath       = ""  
    strFileNameList     = ""   
    LongitudeIdx        = -1      # array x 
    LatitudeIdx         = -1      # array y
    vartimeDate         = [] 
    scale_factor        = 0       #2015.10.30
    add_offset          = 0       #2015.10.30
    ###################################################################################
    # Function initForceTxt
    ###################################################################################
    def __init__(self,strncFilePathIn,
                 structForceTxtIn,
                 strFileNameListIn):
       self.strncDataPath    =  strncFilePathIn;
       self.sForceTxt        =  structForceTxtIn;
       self.strFileNameList  =  strFileNameListIn;
    ###################################################################################
    # Function writeForceTxt
    ################################################################################### 
    '''
     ' Convert specific humidity to relative humidity 
     ' converting specific humidity into relative humidity 
     ' NCEP surface flux data does not have RH 
     ' from Bolton 1980 Teh computation of Equivalent Potential Temperature  
     ' \url{http://www.eol.ucar.edu/projects/ceop/dm/documents/refdata_report/eqns.html} 
     ' @title qair2rh 
     ' @param qair specific humidity, dimensionless (e.g. kg/kg) ratio of water mass / total air mass 
     ' @param temp degrees K 
     ' @param press pressure in hPa(mb) 
     ' @return rh relative humidity, ratio of actual water mixing ratio to saturation mixing ratio 
    ''' 
    def __shum2rh(self,shum,tempK,press):
        temp  = tempK - 273.15
        es    = 6.112 * math.exp((17.67 * temp)/(temp + 243.5))
        e     = shum * press / (0.378 * shum + 0.622)
        rh    = e / es * 100
        return rh
    ###################################################################################
    # Function writeForceTxt
    ###################################################################################
    def getCFMDData(self):
        print "# search filepathlist           ################################"
        ncAllFilePathlist =  self.__searchAllFile()
        print "# Fetching data from path list  ################################"
        PointData        =   self.__getAllPointData(ncAllFilePathlist)
        return PointData
    ###################################################################################
    # Function searchFile
    ###################################################################################
    #search file
    #NOW SUPORT year data
    def __searchSingnalFile(self,datafinallyPath):
        if not os.path.exists(datafinallyPath):
            print "There have no Path: " + datafinallyPath
            os.system("pause")
            exit(0)
        ncSingnalFilePathlist  = []
        del ncSingnalFilePathlist[:]
        startYear  =  self.sForceTxt.startdate.year
        endYear    =  self.sForceTxt.enddate.year
        while (startYear < endYear):
            strStartYear        =  str(startYear)
            strMatchSuffix      =  "*"+ strStartYear +"*.nc"
            for filename in glob.glob(datafinallyPath+"\\"+ strMatchSuffix):
                ncSingnalFilePathlist.append(filename)
            startYear+=1
        return ncSingnalFilePathlist

    #search all file
    def __searchAllFile(self):
        ncAllFilePathlist   =   []
        del ncAllFilePathlist[:]
        for subDirectory in self.strFileNameList:
            datafinallyJoinPath =   os.path.join(self.strncDataPath,subDirectory)
            if not os.path.exists(datafinallyJoinPath):
                print "There have no Path: " + datafinallyJoinPath
                os.system("pause")
                exit(0)
            else:
                print subDirectory + " data have been Find From " + str(self.sForceTxt.startdate.year) +" to "  \
                                   + str(self.sForceTxt.enddate.year)
            ncAllFilePathlist.append(self.__searchSingnalFile(datafinallyJoinPath))
        return ncAllFilePathlist
    ###################################################################################
    # Function getData
    ###################################################################################
    #getData
    def __getPointData(self,ncFilePathlist):
        varPointData = []
        del varPointData[:]
        varName               = ""
        __bExtractTime        = True
        if (len(self.vartimeDate) > 0):
            __bExtractTime = False
        for file_name in ncFilePathlist:
            ncInput    =  Dataset(file_name,'r', Format='NETCDF3_CLASSIC')
            if(__bExtractTime):
                varTimeData     = ncInput.variables["time"][:]
                units           = ncInput.variables['time'].units
                vardates        = num2date(varTimeData[:],units=units)
                self.vartimeDate.extend(list(vardates))
            if (self.LatitudeIdx == -1 or self.LongitudeIdx == -1 ) :
               lats                 = ncInput.variables['lat'][:]  # extract/copy the data
               lons                 = ncInput.variables['lon'][:]
               self.LatitudeIdx     = np.abs(lats - self.sForceTxt.Latitude).argmin()
               self.LongitudeIdx    = np.abs(lons - self.sForceTxt.Longitude).argmin()
            if(len(varName) == 0):
                varList    = ncInput.variables.keys()
                varList.remove("lon")
                varList.remove("lat")
                varList.remove("time")
                if(len(varList) == 1):
                    varName      = str(varList[0])
                    print "Current Fetching: " + varName + "'s Value"
                else:
                    print "There have no varName: " + varName
                    os.system("pause")
                    exit(0)
            #scale_factor  = ncInput.variables[varName].getncattr("scale_factor")
            #add_offset    = ncInput.variables[varName].getncattr("add_offset")
            varData        = ncInput.variables[varName][:]
            pointData      = list(varData[:,self.LatitudeIdx, self.LongitudeIdx].data)
            #if(scale_factor != 0):        #2015.10.30  scale
            #    pointData     = map(lambda x:x*scale_factor + add_offset,pointData)
            if(cmp(varName,"pres") == 0): #2015.10.29  pa->hpa
                pointData     = map(lambda x:x/100.0,pointData)
            if(cmp(varName,"prec") == 0): #2015.10.29  mm h{-1} -> kg m{-2} s{-1}
                pointData     = map(lambda x:x/1000.0,pointData)
            #if(cmp(varName,"srad") == 0): #2015.10.30  mean -> 3hour
            #    pointData     = map(lambda x:x* 3.0,pointData)
            #if(cmp(varName,"lrad") == 0): #2015.10.30  mean -> 3hour
            #    pointData     = map(lambda x:x* 3.0,pointData)
            varPointData.extend(pointData)
            ncInput.close
        return list(varPointData)

    #get all data
    def __getAllPointData(self,ncAllFilePathlist):
        varPointAllData = []
        for ncFilePathlist in ncAllFilePathlist:
            if(len(ncFilePathlist) == 0):
                print "There have no PathList: "
                os.system("pause")
                exit(0)
            varPointData = self.__getPointData(ncFilePathlist)
            varPointAllData.append(varPointData)

        #update Rh value 2015.10.29
        values = map(self.__shum2rh,varPointAllData[2],varPointAllData[1],varPointAllData[3])
        varPointAllData[2] = values
        #add time
        if (len(self.vartimeDate) > 0):
            varPointAllData.insert(0,self.vartimeDate)
        return zip(*varPointAllData)
###################################################################################
# Class write forcedata to txt
###################################################################################
class PointForceData2Txt(object):
      strtxtDataPath      = ""  
        
      def __init__(self,strtxtDataPathIn):
           self.strtxtDataPath   =  strtxtDataPathIn;

      def writePointData2Txt(self,sForceTxt):
           outputTxtPathName     =  self.strtxtDataPath + str(sForceTxt.Longitude) + \
                                    "_" + str(sForceTxt.Latitude) + ".txt"
           with open(outputTxtPathName, "w") as text_file:
               text_file.write("&METADATA_NAMELIST\n")
               text_file.write(' startdate             = "{}"\n'.format(sForceTxt.startdate.strftime("%Y%m%d%H%M")))
               text_file.write(' enddate               = "{}"\n'.format(sForceTxt.enddate.strftime("%Y%m%d%H%M")))
               text_file.write(' loop_for_a_while      = {}\n'.format(sForceTxt.loop_for_a_while))
               text_file.write(' output_dir            = "{}"\n'.format(sForceTxt.output_dir))
               text_file.write(' Latitude              = {}\n'.format(sForceTxt.Latitude))
               text_file.write(' Longitude             = {}\n'.format(sForceTxt.Longitude))
               text_file.write(' Forcing_Timestep      = {}\n'.format(sForceTxt.Forcing_Timestep))
               text_file.write(' Noahlsm_Timestep      = {}\n'.format(sForceTxt.Noahlsm_Timestep))
               if sForceTxt.Sea_ice_point :
                   text_file.write(' Sea_ice_point         = .{}.\n'.format("TRUE"))
               else:
                   text_file.write(' Sea_ice_point         = .{}.\n'.format("FALSE"))
               text_file.write(' Soil_layer_thickness  = {}\n'.format('  '.join(str(x) for x in sForceTxt.Soil_layer_thickness)))
               text_file.write(' Soil_Temperature      = {}\n'.format('  '.join(str(x) for x in sForceTxt.Soil_Temperature)))   
               text_file.write(' Soil_Moisture         = {}\n'.format('  '.join(str(x) for x in sForceTxt.Soil_Moisture)))  
               text_file.write(' Soil_Liquid           = {}\n'.format('  '.join(str(x) for x in sForceTxt.Soil_Liquid)))  
               text_file.write(' Soil_htype            = {}\n'.format('  '.join(str(x) for x in sForceTxt.Soil_htype)))  
               text_file.write(' Skin_Temperature      = {}\n'.format(sForceTxt.Skin_Temperature))  
               text_file.write(' Canopy_water          = {}\n'.format(sForceTxt.Canopy_water))  
               text_file.write(' Snow_depth            = {}\n'.format(sForceTxt.Snow_depth))  
               text_file.write(' Snow_equivalent       = {}\n'.format(sForceTxt.Snow_equivalent))  
               text_file.write(' Deep_Soil_Temperature = {}\n'.format(sForceTxt.Deep_Soil_Temperature))  
               text_file.write(' Landuse_dataset       = {}\n'.format(sForceTxt.Landuse_dataset))  
               text_file.write(' Soil_type_index       = {}\n'.format(sForceTxt.Soil_type_index))  
               text_file.write(' Vegetation_type_index = {}\n'.format(sForceTxt.Vegetation_type_index))  
               text_file.write(' Urban_veg_category    = {}\n'.format(sForceTxt.Urban_veg_category))  
               text_file.write(' glacial_veg_category  = {}\n'.format(sForceTxt.glacial_veg_category))  
               text_file.write(' Slope_type_index      = {}\n'.format(sForceTxt.Slope_type_index))  
               text_file.write(' Max_snow_albedo       = {}\n'.format(sForceTxt.Max_snow_albedo))  
               text_file.write(' Air_temperature_level = {}\n'.format(sForceTxt.Air_temperature_level))  
               text_file.write(' Wind_level            = {}\n'.format(sForceTxt.Wind_level))  
               text_file.write(' Green_Vegetation_Min  = {}\n'.format(sForceTxt.Green_Vegetation_Min))  
               text_file.write(' Green_Vegetation_Max  = {}\n'.format(sForceTxt.Green_Vegetation_Max))  
               if sForceTxt.Usemonalb :
                   text_file.write(' Usemonalb             = .{}.\n'.format("TRUE"))
               else:
                   text_file.write(' Usemonalb             = .{}.\n'.format("FALSE"))
               if sForceTxt.Rdlai2d :
                   text_file.write(' Rdlai2d               = .{}.\n'.format("TRUE"))
               else:
                   text_file.write(' Rdlai2d               = .{}.\n'.format("FALSE"))
               text_file.write(' sfcdif_option         = {}\n'.format(sForceTxt.sfcdif_option))  
               text_file.write(' iz0tlnd               = {}\n'.format(sForceTxt.iz0tlnd))  
               text_file.write(' Albedo_monthly        = {}\n'.format('  '.join(str(x) for x in sForceTxt.Albedo_monthly)))  
               text_file.write(' Shdfac_monthly        = {}\n'.format('  '.join(str(x) for x in sForceTxt.Shdfac_monthly)))  
               text_file.write(' lai_monthly           = {}\n'.format('  '.join(str(x) for x in sForceTxt.lai_monthly)))  
               text_file.write(' Z0brd_monthly         = {}\n'.format('  '.join(str(x) for x in sForceTxt.Z0brd_monthly)))  
               text_file.write("/\n")
               text_file.write("------------------------------------------------------------------------------------------------------------------------------------------------------------\n")
               text_file.write(" UTC date/time        windspeed       wind dir         temperature      humidity        pressure           shortwave      longwave          precipitation\n")
               text_file.write("yyyy mm dd hh mi       m s{-1}        degrees               K               %             hPa               W m{-2}        W m{-2}          kg m{-2} s{-1}\n")
               text_file.write("------------------------------------------------------------------------------------------------------------------------------------------------------------\n")
               text_file.write('<Forcing>  This tag ("<Forcing>", not case sensitive) begins the section of forcing data.  The times have been converted from CST to UTC\n')
               if (len(sForceTxt.CFMDData) > 0):
                   for strRow in sForceTxt.CFMDData: 
                       text_file.write('{}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}\n' \
                           .format(strRow[0].strftime("%Y %m %d %H %M"),strRow[1],249,strRow[2],strRow[3],strRow[4],strRow[5],strRow[6],strRow[7]))  
           print "File : " + outputTxtPathName + " write is ok !!!!!"

###################################################################################
# Main Test
###################################################################################
if __name__ == '__main__':
    start = time.clock()

    # new object
    spointForceData    =   sPointForceData() 

    #update 1 CFMD data   
    ncFilePath         =   "D:\\workspace\\Data\\CFMD(QTP)\\Data_forcing_03hr_010deg_Unzip\\"
    strFileNameList    =   ("Wind","Temp","SHum","Pres","SRad","LRad","Prec")  
    updateCFMDData     =   upDateCFMDData(ncFilePath,
                                          spointForceData,
                                          strFileNameList)
    spointForceData.CFMDData =  updateCFMDData.getCFMDData()
    #update 2 other info  eg:lai



    #write
    txtFilePath        =   "E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\"
    ptForceData2Txt    =   PointForceData2Txt(txtFilePath)
    ptForceData2Txt.writePointData2Txt(spointForceData)
    end = time.clock()
    print "Convert is request:  %f s" % (end - start)
##########################################################################################################
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

##########################################################################################################
import os
import glob 
import datetime 
import numpy as np
import math
from netCDF4 import Dataset 
from netCDF4 import num2date
###################################################################################
# Class write struct 
###################################################################################
class sPointForceData(object):
    startdate                =  datetime.datetime(2002,1,1)
    enddate                  =  datetime.datetime(2011,1,1)
    loop_for_a_while         =  0
    output_dir               =  "."
    Latitude                 =  33.072      # lat  
    Longitude                =  91.939      # lon  
    Forcing_Timestep         =  10800
    Noahlsm_Timestep         =  10800
    Sea_ice_point            =  False
    Soil_layer_thickness     =  [0.045,0.046,0.075,0.123,0.204,0.336,0.554,0.913,0.904,1,1,1,1,1,1,2,2,2]
    Soil_Temperature         =  [277.8238,278.419,279.163,279.657,276.335,274.047,272.954,272.244,271.682,271.359,271.111,270.981,270.927,270.796,270.826,270.946,271.132,271.407]
    Soil_Moisture            =  [0.15,0.16,0.05,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    Soil_Liquid              =  [0.07,0.08,0.02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    Soil_htype               =  [7,7,7,7,4,7,7,7,2,2,2,1,1,1,1,1,1,1]
    Skin_Temperature         =  279.6909
    Canopy_water             =  0  #Canopy moisture content (kg m-2)
    Snow_depth               =  0   #Water equivalent accumulated snow depth (m)
    Snow_equivalent          =  0
    Deep_Soil_Temperature    =  271.95
    Landuse_dataset          =  "USGS"
    Soil_type_index          =  3
    Vegetation_type_index    =  19
    Urban_veg_category       =  1
    glacial_veg_category     =  24
    Slope_type_index         =  3               #Slope category
    Max_snow_albedo          =  0.75
    Air_temperature_level    =  2.0
    Wind_level               =  10.0 
    Green_Vegetation_Min     =  0.01
    Green_Vegetation_Max     =  0.96
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
     sForceTxt    = 0
     shapeRec     = [] 
     def __init__(self,structForceTxtIn,shapeRecList):
         self.sForceTxt        =  structForceTxtIn;
         self.shapeRec         =  shapeRecList;
     def  getUpdateSPointForceData(self):
         self.sForceTxt.Longitude             =  float(self.shapeRec[1]);
         self.sForceTxt.Latitude              =  float(self.shapeRec[2]); 
         self.sForceTxt.Vegetation_type_index =  self.shapeRec[0];
         self.sForceTxt.Soil_htype            =  self.shapeRec[3:21]
         dem                                  =  float(self.shapeRec[22])
         if(dem < 4200):
             dem = 4200
         if(dem > 5300):
             dem = 5300
         self.sForceTxt.Deep_Soil_Temperature =  dem * (-0.0063) + 30.98 + 273 # ch Doc paper
         self.sForceTxt.Skin_Temperature      =  float(self.shapeRec[21])
         #update NDVI  2016.1.31
         ndvi                                 =  float(self.shapeRec[23])
         if(ndvi > 70):
             self.sForceTxt.sfcdif_option     =  1
         return  self.sForceTxt;


###################################################################################
# Class getCFMDFiles
###################################################################################
class getCFMDDataFiles(object):
    strncDataPath       = ""
    strFileNameList     = "" 
    startdate           =  datetime.datetime(2002,1,1)
    enddate             =  datetime.datetime(2011,1,1)
    def __init__(self,strncFilePathIn,strFileNameListIn,startDateIn,endDateIn):
        self.strncDataPath      =  strncFilePathIn;
        self.strFileNameList    =  strFileNameListIn;
        self.startdate          =  startDateIn;
        self.enddate            =  endDateIn;
    def getCFMDFiles(self):
        print "# search filepathlist           ################################"
        ncAllFilePathlist =  self.__searchAllFile()
        return ncAllFilePathlist
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
        startYear  =  self.startdate.year
        endYear    =  self.enddate.year
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
                print subDirectory + " data have been Find From " + str(self.startdate.year) +" to "  \
                                   + str(self.enddate.year)
            ncAllFilePathlist.append(self.__searchSingnalFile(datafinallyJoinPath))
        return ncAllFilePathlist


###################################################################################
# Class update CFMD txtinfo
###################################################################################
class upDateCFMDData(object):
    Latitude            =  33.072      # lat  
    Longitude           =  91.939      # lon  
    LongitudeIdx        = -1      # array x 
    LatitudeIdx         = -1      # array y
    scale_factor        = 0       #2015.10.30
    add_offset          = 0       #2015.10.30
    ncAllFilePathlist   = []
    ###################################################################################
    # Function initForceTxt
    ###################################################################################
    def __init__(self,
                 LatitudeIn,LongitudeIn,
                 ncAllFilePathlistIn):
       self.Latitude           =  LatitudeIn;
       self.Longitude          =  LongitudeIn;
       self.ncAllFilePathlist  =  ncAllFilePathlistIn;
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
    def getCFMDData(self,varTimeDataList):
        varPointAllData      =   self.__getAllPointData(self.ncAllFilePathlist)
        varPointAllData.insert(0,varTimeDataList)
        return zip(*varPointAllData)

    ###################################################################################
    # getSingleCFMDData
    ###################################################################################
    def getSingleCFMDData(self):
        varPointAllData   = self.__getPointData(self.ncAllFilePathlist[0])
        return varPointAllData

    ###################################################################################
    # Function getData
    ###################################################################################
    #getData
    def __getPointData(self,ncFilePathlist):
        varPointData = []
        del varPointData[:]
        varName        = ""
        for file_name in ncFilePathlist:
            ncInput    =  Dataset(file_name,'r', Format='NETCDF3_CLASSIC')
            if (self.LatitudeIdx == -1 or self.LongitudeIdx == -1 ) :
               lats                 = ncInput.variables['lat'][:]  # extract/copy the data
               lons                 = ncInput.variables['lon'][:]
               self.LatitudeIdx     = np.abs(lats - self.Latitude).argmin()
               self.LongitudeIdx    = np.abs(lons - self.Longitude).argmin()
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
            #extract data
            varData        = ncInput.variables[varName][:]
            pointData      = list(varData[:,self.LatitudeIdx, self.LongitudeIdx].data)
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
        #pressure
        values = map(lambda x:x/100.0,varPointAllData[3])
        varPointAllData[3] = values
        #humidity
        values = map(self.__shum2rh,varPointAllData[2],varPointAllData[1],varPointAllData[3])
        varPointAllData[2] = values
        #precipitation
        values = map(lambda x:x/3600.0,varPointAllData[6])
        varPointAllData[6] = values
        return varPointAllData



###################################################################################
# Class write forcedata to txt
###################################################################################
class PointForceData2Txt(object):
      strtxtDataPath      = ""  
        
      def __init__(self,strtxtDataPathIn):
           self.strtxtDataPath   =  strtxtDataPathIn;

      def writePointData2Txt(self,sForceTxt):
           with open(self.strtxtDataPath, "w") as text_file:
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
           print "File : " + self.strtxtDataPath + " write is ok !!!!!"


##########################################################################################################
# NAME
#    ResNcFileProcess.py
# PURPOSE
#    Nc file process
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151010 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
from netCDF4 import Dataset  
import datetime
import os
import numpy as np
import pandas

varTimeDataArray = None

class NcFileProcess(object):
    """description of class"""
    def __init__(self,strncFilePath):
        self.strncDataPath       =  strncFilePath;
    # 2015.11.2
    def strdt3dt(self,strTime):
        strTime    = strTime.tostring()
        outputDt   = datetime.datetime.strptime(strTime,'%Y%m%d%H%M')
        return outputDt  

    # get request input number layer, dataName
    # input 
    def getNcDataByDay(self,varName,nLayer,startTime = None, endTime = None):
        global varTimeDataArray  #wWe are telling to explicitly use the global version

        if startTime is None:
            startTime = datetime.datetime(2010,1,1)
        if endTime is None:
            endTime   = datetime.datetime(2010,12,31)
        file_name   = self.strncDataPath
        if not os.path.exists(file_name):
            print "Error there have no " + file_name
            os.system("pause")
            exit(0)
        ncInput       =  Dataset(file_name,'r', Format='NETCDF3_CLASSIC')
        # get var data
        varData       =  ncInput.variables[varName][:]
        varDataLayer  =  varData.transpose()[nLayer]
        # is get time infomation
        if varTimeDataArray is None:
            varTimeData            =  ncInput.variables["Times"][:]
            varTimeDataArray       =  map(self.strdt3dt,varTimeData)
        # group data
        # 2015.11.2
        varDataFrame         =  pandas.DataFrame(varDataLayer, index = varTimeDataArray, columns=['Temp'])
        varSelDataFrame      =  varDataFrame.loc[startTime:endTime]   
        #group by day
        groupVarSelData      =  varSelDataFrame.groupby(lambda x: (x.year,x.month,x.day))
        groupVarSelDataMean  =  groupVarSelData.mean() 
        #clip by sele data
        resList              =  groupVarSelDataMean['Temp'].values.tolist()
        return resList
        # strdt3dt

    # 2015.12.18
    # get max min by layer and varName
    def getMaxMinData(self,varName,nLayer,startTime = None, endTime = None):
        if startTime is None:
            startTime = datetime.datetime(2009,1,1)
        if endTime is None:
            endTime   = datetime.datetime(2010,12,31)
        dataList      =  self.getNcDataByDay(varName,nLayer,startTime,endTime)
        return [max(dataList),min(dataList)]

    #2015.12.31
    def getAllLayerMeanTempByMonth(self,startTime = None, endTime = None,):
        global varTimeDataArray  #wWe are telling to explicitly use the global version

        if startTime is None:
            startTime = datetime.datetime(2010,1,1)
        if endTime is None:
            endTime   = datetime.datetime(2010,12,31)
        file_name   = self.strncDataPath
        if not os.path.exists(file_name):
            print "Error there have no " + file_name
            os.system("pause")
            exit(0)
        ncInput       =  Dataset(file_name,'r', Format='NETCDF3_CLASSIC')
        # get var data
        varData       =  ncInput.variables["STC"][:]
        dimsSoilLayer =  len(ncInput.dimensions["num_soil_layers"])
        # is get time infomation
        if (varTimeDataArray is None):
            varTimeData            =  ncInput.variables["Times"][:]
            varTimeDataArray       =  map(self.strdt3dt,varTimeData)
        #layer info
        allLayerList = []
        for i in range(0,dimsSoilLayer - 3):
            varDataLayer  =  varData.transpose()[i]
            # group data
            varDataFrame         =  pandas.DataFrame(varDataLayer, index = varTimeDataArray, columns=['Temp'])
            varSelDataFrame      =  varDataFrame.loc[startTime:endTime]   
            #group by day
            groupVarSelData      =  varSelDataFrame.groupby(lambda x: (x.year,x.month))
            groupVarSelDataMean  =  groupVarSelData.mean() 
            #clip by sele data
            resListLayer         =  groupVarSelDataMean['Temp'].values.tolist()
            maxValue             =  max(resListLayer)  
            minValue             =  min(resListLayer)    
            allLayerList.append([maxValue,minValue])
        allLayerList = zip(*allLayerList)
        return allLayerList




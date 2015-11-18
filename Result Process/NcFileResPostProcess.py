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

class NcFileProcess(object):
    """description of class"""
    def __init__(self,strncFilePath):
        self.strncDataPath    =  strncFilePath;
        self.varTimeDataArray      =  None;

    # 2015.11.2
    def strdt3dt(self,strTime):
        strTime    = strTime.tostring()
        outputDt   = datetime.datetime.strptime(strTime,'%Y%m%d%H%M')
        return outputDt  

    # get request input number layer, dataName
    # input 
    def getNcDataByDay(self,varName,nLayer,startTime = None, endTime = None):
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
        if self.varTimeDataArray is None:
            varTimeData            =  ncInput.variables["Times"][:]
            self.varTimeDataArray  =  map(self.strdt3dt,varTimeData)
        # group data
        # 2015.11.2
        varDataFrame         =  pandas.DataFrame(varDataLayer, index = self.varTimeDataArray, columns=['Temp'])
        varSelDataFrame      =  varDataFrame.loc[startTime:endTime]   
        #group by day
        groupVarSelData      =  varSelDataFrame.groupby(lambda x: (x.year,x.month,x.day))
        groupVarSelDataMean  =  groupVarSelData.mean() 
        #clip by sele data
        resList              =  groupVarSelDataMean['Temp'].values.tolist()
        return resList
        # strdt3dt




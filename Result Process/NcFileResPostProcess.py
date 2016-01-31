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
        self.strncDataPath       =  strncFilePath;

    # get request input number layer, dataName
    # input 
    # update globe
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

    #2015.12.31  getAllLayerMeanTempByMonth
    def getAllLayerMeanTempByMonth(self,delLayerNum,varTimeDataArray,startTime = None, endTime = None,):
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
        #layer info
        allLayerList = []
        for i in range(0,dimsSoilLayer-delLayerNum):
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
    
    #2016.1.31 
    def getAllLayerMeanICEByYear(self,varTimeDataArray,startTime = None, endTime = None,):
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
        varDataSMC       =  ncInput.variables["SMC"][:]
        varDataSH2O      =  ncInput.variables["SH2O"][:]
        dimsSoilLayer    =  len(ncInput.dimensions["num_soil_layers"])
        #layer info
        allLayerList = []
        for i in range(0,dimsSoilLayer):
            varDataLayerSMC            =  varDataSMC.transpose()[i]
            varDataLayerSH2O           =  varDataSH2O.transpose()[i]
            # group data
            varDataFrameSMC            =  pandas.DataFrame(varDataLayerSMC, index = varTimeDataArray, columns=['SMC'])
            varDataFrameSH2O           =  pandas.DataFrame(varDataLayerSH2O, index = varTimeDataArray, columns=['SH2O'])

            varSelDataFrameSMC         =  varDataFrameSMC.loc[startTime:endTime]   
            varSelDataFrameSH2O        =  varDataFrameSH2O.loc[startTime:endTime]   

            #group by day
            groupVarSelDataSMC         =  varSelDataFrameSMC.groupby(lambda x: (x.year))
            groupVarSelDataMeanSMC     =  groupVarSelDataSMC.mean() 

            groupVarSelDataSH2O        =  varSelDataFrameSH2O.groupby(lambda x: (x.year))
            groupVarSelDataMeanSH2O    =  groupVarSelDataSH2O.mean() 

            #clip by sele data
            resListLayerSMC            =  groupVarSelDataMeanSMC['SMC'].values.tolist()
            resListLayerSH2O           =  groupVarSelDataMeanSH2O['SH2O'].values.tolist()
            resListLayerICE            =  resListLayerSMC[0] - resListLayerSH2O[0]
            allLayerList.append(resListLayerICE)
        return allLayerList


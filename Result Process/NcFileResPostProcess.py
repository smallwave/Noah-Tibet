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

class NcFileProcess(object):
    """description of class"""
    def __init__(self,strncFilePath):
        self.strncDataPath    =  strncFilePath;
    # get request input number layer, dataName
    def getNcData(self,varName,nLayer,startTime = None ,endTime = None):
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
        # get time infomation
        varTimeData   =  ncInput.variables["Times"][:]
        resList       =  []
        for i in  range(0, len(varDataLayer)): 
            strTime    = varTimeData[i].tostring()
            timeNcFile = datetime.datetime.strptime(strTime,'%Y%m%d%H%M')
            if((startTime - timeNcFile).days == 0): # -1 is equal
                resList.append(varDataLayer[i])
            if((timeNcFile - startTime).days > 0 ):
                startTime = startTime + datetime.timedelta(days=1)
                if((startTime - timeNcFile).days == 0): # -1 is equal
                    resList.append(varDataLayer[i])
                if((startTime - endTime).days > 0):
                    break
        return resList





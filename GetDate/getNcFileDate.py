##########################################################################################################
# NAME
#    getNcFileDate.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160129 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
from netCDF4 import Dataset 
from netCDF4 import num2date
import datetime
# 2016.1.29
class getSingleNcFileDate(object):
    ''' get date '''
    ncTypeFile  =  ""
    def __init__(self,ncTypeFileIn):
        self.ncTypeFile = ncTypeFileIn
    # 2015.11.2
    def strdt3dt(self,strTime):
        strTime    = strTime.tostring()
        outputDt   = datetime.datetime.strptime(strTime,'%Y%m%d%H%M')
        return outputDt  
    # 2016.1.31
    def getNcFileDate(self,varName = "time",ncType = "CFMD"):
        varTimeData  = []
        ncInput      =  Dataset(self.ncTypeFile,'r', Format='NETCDF3_CLASSIC')
        vartimeDate  =  ncInput.variables[varName][:]
        if ncType == "CFMD":
            units        =  ncInput.variables[varName].units
            vardates     =  num2date(vartimeDate[:],units=units)
            varTimeData  =  list(vardates)
        elif ncType == "Noah":
            varTimeData  =  map(self.strdt3dt,vartimeDate)
        ncInput.close
        return varTimeData

# 2016.1.29
class getListNcFileDate(object):
    ''' get date '''
    ncTypeList = []
    def __init__(self,ncTypeListIn):
        self.ncTypeList = ncTypeListIn
    def getCFMDDateAll(self):
        varTimeDataList  = []
        for file_name in self.ncTypeList:
            getFileDate =  getSingleNcFileDate(file_name)
            vardates    =  getFileDate.getNcFileDate()
            varTimeDataList.extend(vardates)
        return varTimeDataList



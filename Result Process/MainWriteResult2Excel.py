import sys
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess
sys.path.append('GetDate')
from getNcFileDate import getSingleNcFileDate
import xlwt 
import datetime


def getModelData(ncFileProcess,nlayer,varTimeDataArray,modelAttr = "SH2O",startTime = None,endTime = None):
    nlayer = nlayer - 1
    if startTime is None:
        startTime = datetime.datetime(2007,4,1)
    if endTime is None:
        endTime   = datetime.datetime(2010,12,31)
    modelRes = ncFileProcess.getNcDataByDay(modelAttr,nlayer,varTimeDataArray,startTime,endTime)
    if (modelAttr == "STC"):
         modelRes = map(lambda x:x - 273.15,modelRes)
    if (modelAttr == "SH2O"):
         modelRes = map(lambda x:x*100,modelRes)
    return modelRes


#Main code
if __name__ == '__main__':

    # nc files
    ncFileProcess  = NcFileProcess("D:\\worktemp\\Permafrost(NOAH)\\Data\\Run(S)\\TGLCH.nc")

    #get varTimeDataArray
    getNoahDateAll    =   getSingleNcFileDate("D:\\worktemp\\Permafrost(NOAH)\\Data\\Run(S)\\TGLCH.nc")
    varTimeDataArray  =   getNoahDateAll.getNcFileDate("Times","Noah")

    exctType     =  1  # 1 temp 2 mos 

    workbook = xlwt.Workbook()
    sheet = workbook.add_sheet('test')
    if exctType == 1: 
        nLayerListSim       = [2,3,5,8,12,15,18,22,23]
    if exctType == 2: 
        nLayerListSim       = [2,3,5,8,10]

    for i in range(0,len(nLayerListSim)):
        modelLayer   = nLayerListSim[i]
        if exctType == 1:
            modelRes    =  getModelData(ncFileProcess,modelLayer,varTimeDataArray,"STC")
        if exctType == 2:
            modelRes    =  getModelData(ncFileProcess,modelLayer,varTimeDataArray,"SH2O")

        for j in range(0,len(modelRes)):
            sheet.write(j+1,i,modelRes[j])

    workbook.save('output.xls')

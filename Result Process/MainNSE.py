##########################################################################################################
# NAME
#    MainNSE.py
# PURPOSE
#   
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160609 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import sys
import numpy as np
import pandas
sys.path.append('Parameter Estimation')
from ReadObs import ReadObsData
import datetime

def nashsutcliff(evalution,simulation):   
    """
    Nash-Sutcliff model efficinecy
    
        .. math::

         NSE = 1-\\frac{\\sum_{i=1}^{N}(e_{i}-s_{i})^2}{\\sum_{i=1}^{N}(e_{i}-\\bar{e})^2} 
    
    :evaluation: Observed data to compared with simulation data.
    :type: list
    
    :simulation: simulation data to compared with evalution data
    :type: list
    
    :return: Nash-Sutcliff model efficiency
    :rtype: float
    
    """   
    if len(evalution)==len(simulation):
        s,e=np.array(simulation),np.array(evalution)
        #s,e=simulation,evalution       
        mean_observed = np.mean(e)
        # compute numerator and denominator
        numerator = sum((e - s) ** 2)
        denominator = sum((e - mean_observed)**2)
        # compute coefficient
        return 1 - (numerator/denominator)
        #return coefficient
        #return float(1 - sum((s-e)**2)/sum((e-np.mean(e))**2))
        
    else:
        print "Error: evalution and simulation lists does not have the same length."


def getExcelDatatoPandas(readObsData,nlayer,dataIdxs,startTime,endTime):
    obsDataRes        =  readObsData.getObsData(nlayer)
    varDataFrame      =  pandas.DataFrame(obsDataRes, index = dataIdxs, columns=['Temp'])
    varSelDataFrame   =  varDataFrame.loc[startTime:endTime]   
    resListLayer      =  varSelDataFrame.values.tolist()
    return resListLayer
#Main code
if __name__ == '__main__':


    plotType  =  2  # 1 temp 2 mos 

    startTime  = datetime.datetime(2007,4,1)
    getEndTime = datetime.datetime(2009,12,31)
    endTime    = datetime.datetime(2010,12,31)
    dataIdxs   = pandas.date_range(start = startTime,end = endTime)
    NseList    = []
    if plotType == 1:
        readObsData    =  ReadObsData("D:\\worktemp\\Permafrost(NOAH)\\Data\\TGLDataPlotTEMP.xls")
        for i in range(1,8):
            obsDataRes     =  getExcelDatatoPandas(readObsData,i,dataIdxs,startTime,getEndTime)
            modelRes       =  getExcelDatatoPandas(readObsData,i+7,dataIdxs,startTime,getEndTime)
            nse            =  nashsutcliff(obsDataRes,modelRes)
            NseList.append(nse)

    if plotType == 2:
        readObsData    =  ReadObsData("D:\\worktemp\\Permafrost(NOAH)\\Data\\TGLDataPlotMOS.xls")
        for i in range(1,6):
            obsDataRes     =  getExcelDatatoPandas(readObsData,i,dataIdxs,getEndTime,endTime)
            modelRes       =  getExcelDatatoPandas(readObsData,i+5,dataIdxs,getEndTime,endTime)
            nse            =  nashsutcliff(obsDataRes,modelRes)
            NseList.append(nse)

    print "ok"




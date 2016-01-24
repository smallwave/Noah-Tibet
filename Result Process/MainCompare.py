##########################################################################################################
# NAME
#    MainCompare.py
# PURPOSE
#   
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151031 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import sys
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess
sys.path.append('Parameter Estimation')
from ReadObs import ReadObsData
import matplotlib.pyplot as plt  
import numpy as np
import matplotlib.patches as mpatches
from matplotlib.dates import YearLocator, MonthLocator, DayLocator, DateFormatter
import datetime
import pandas

def mse(evalution,simulation):
    """
    Mean Squared Error
    
        .. math::
        
         MSE=\\frac{1}{N}\\sum_{i=1}^{N}(e_{i}-s_{i})^2
    
    :evaluation: Observed data to compared with simulation data.
    :type: list
    
    :simulation: simulation data to compared with evalution data
    :type: list
    
    :return: Mean Squared Error
    :rtype: float
    """
    if len(evalution) == len(simulation):
        MSE_values = [] 
        for i in range(len(evalution)):
            MSE_values.append((simulation[i] - evalution[i]) ** 2)        
        MSE_sum = np.sum(MSE_values[0:len(evalution)])
        MSE = MSE_sum / (len(evalution))
        return MSE
    else:
        return "Error: evalution and simulation lists does not have the same length."

def rmse(evalution,simulation):
    """
    Root Mean Squared Error
        .. math::
         RMSE=\\sqrt{\\frac{1}{N}\\sum_{i=1}^{N}(e_{i}-s_{i})^2}
        
    :evaluation: Observed data to compared with simulation data.
    :type: list
    
    :simulation: simulation data to compared with evalution data
    :type: list
    
    :return: Root Mean Squared Error
    :rtype: float
    """
    if len(evalution) == len(simulation):
        return np.sqrt(mse(evalution,simulation))
    else:
        print "Error: evalution and simulation lists does not have the same length." 

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

def correlationcoefficient(evalution,simulation):
    """
    Correlation Coefficient
    
        .. math::
        
         r = \\frac{\\sum ^n _{i=1}(e_i - \\bar{e})(s_i - \\bar{s})}{\\sqrt{\\sum ^n _{i=1}(e_i - \\bar{e})^2} \\sqrt{\\sum ^n _{i=1}(s_i - \\bar{s})^2}}
    
    :evaluation: Observed data to compared with simulation data.
    :type: list
    
    :simulation: simulation data to compared with evalution data
    :type: list
    
    :return: Corelation Coefficient
    :rtype: float
    """ 
    if len(evalution)==len(simulation):
        Corelation_Coefficient = np.corrcoef(evalution,simulation)[0,1]
        return Corelation_Coefficient
    else:
        return "Error: evalution and simulation lists does not have the same length."

def getModelData(ncFileProcess,nlayer,modelAttr = "SH2O",startTime = None,endTime = None):
    nlayer = nlayer - 1
    if startTime is None:
        startTime = datetime.datetime(2007,4,1)
    if endTime is None:
        endTime   = datetime.datetime(2009,12,31)
    modelRes = ncFileProcess.getNcDataByDay(modelAttr,nlayer,startTime,endTime)
    if (modelAttr == "STC"):
         modelRes = map(lambda x:x - 273.15,modelRes)
    if (modelAttr == "SH2O"):
         modelRes = map(lambda x:x*100,modelRes)
    return modelRes

def getObsData(readObsData,nlayer,modelAttr = "TEMP"):
    obsDataRes = readObsData.getObsData(nlayer)
    if (modelAttr == "TEMP"):
        obsDataRes = map(lambda x:x - 273.15,obsDataRes)
    if (modelAttr == "MOS"):
        obsDataRes = map(lambda x:x*100,obsDataRes)
    return obsDataRes

def updateAx_1(ax,modelRes,Title):
    ax.plot(modelRes,'b',label='Model')
    ax.set_title(Title)
    ax.set_ylabel("%")
    #for tick in ax.xaxis.get_major_ticks():
    #    tick.label.set_fontsize(8)
    #    tick.label.set_rotation('vertical')

def updateAx_2(ax,modelRes,obsDataRes,Title,dateIdx = None,yLabel = "Temperature(C)"):
    ax.plot(dateIdx,obsDataRes,'r',label='Obs')
    ax.plot(dateIdx,modelRes,'b',label='Model')
    ax.set_title(Title)
    ax.set_ylabel("Temperature(C)")
    ax = formatAxticks(ax)
    #for tick in ax.xaxis.get_major_ticks():
    #    tick.label.set_fontsize(8)
    #    tick.label.set_rotation('vertical')
    rmseValue = nashsutcliff(obsDataRes,modelRes)
    ax.text(0.95, 0.01, "NSE:{:.3}".format(rmseValue),
        verticalalignment='bottom', horizontalalignment='right',
        transform=ax.transAxes,
        color='green', fontsize=15)


def updateAx_3(ax,modelRes1,modelRes2,obsDataRes,Title):
    ax.plot(obsDataRes,'r',label='Obs')
    ax.plot(modelRes1,'b',label='OLD')
    ax.plot(modelRes2,'g',label='NY06')
    ax.set_title(Title)
    ax.set_ylabel("%")
    #rmseValue = rmse(obsDataRes,modelRes)
    #ax.text(0.95, 0.01, "RMSE:{:.3}".format(rmseValue),
    #    verticalalignment='bottom', horizontalalignment='right',
    #    transform=ax.transAxes,
    #    color='green', fontsize=15)

def updateAx_4(ax,obsDataRes,modelRes1,modelRes2,modelRes3,Title,dateIdx = None):
    ax.plot(dateIdx,obsDataRes,'r',label='Obs')
    ax.plot(dateIdx,modelRes1,'b',label='J75')
    ax.plot(dateIdx,modelRes2,'g',label='C05')
    ax.plot(dateIdx,modelRes3,'y',label='Y05')
    ax.set_title(Title)
    ax.set_ylabel("Temperature(C)")
    ax = formatAxticks(ax)
    #rmseValue = nashsutcliff(obsDataRes,modelRes)
    #ax.text(0.95, 0.01, "NSE:{:.3}".format(rmseValue),
    #    verticalalignment='bottom', horizontalalignment='right',
    #    transform=ax.transAxes,
    #    color='green', fontsize=15)

def updateLastAx(ax,strText):
    ax.text(0.95, 0.41, strText,
       verticalalignment='center', horizontalalignment='right',
       transform=ax.transAxes,
       color='red', fontsize=20)


def formatAxticks(ax):
    days     = DayLocator()    # every month
    months   = MonthLocator()  # every month
    months.MAXTICKS = 2000
    yearsFmt = DateFormatter('%m/%Y')
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_minor_locator(days)
    ax.xaxis.set_major_formatter(yearsFmt)
    ax.autoscale_view()
    ticks = ax.get_xticks()
    n = len(ticks)//6
    ax.set_xticks(ticks[::n])
    return ax


#Main code
if __name__ == '__main__':
    '''
    #1   0.01  
    #2   0.05  Y  ax1  
    #3   0.1   Y  ax2
    #4   0.2   Y  ax3
    #5   0.5   Y  ax4
    #6   0.7   Y  ax5
    #7   0.9   Y  ax6
    #8   1.05  Y  ax7
    #9   1.4   Y  ax8
    #10  1.75  Y  ax9
    #11  2.1   Y  ax10
    #12  2.45  Y  ax11
    #13  2.8   Y  ax12
    #14  3.6
    '''
    plotType  =  1  # 1 temp 2 mos 
    plotCom   =  1  # 
    layerNameList = ["0.05m","0.1m","0.2m","0.5m","0.7m","0.9m","1.05m","1.4m","1.75m","2.1m","2.45m","2.8m",\
                     "3.6m","4.5m","5.5m","6.5m","7.5m","8.5m","9.5m","11m","13m","15m"]

    startTime = datetime.datetime(2007,4,1)
    endTime   = datetime.datetime(2009,12,31)
    dataIdxs  = pandas.date_range(start = startTime,end = endTime)

    #temp
    if plotType == 1:
        #ax define
        f, ((ax1,ax2,ax3,ax4,ax5,ax6),(ax7,ax8,ax9,ax10,ax11,ax12),(ax13,ax14,ax15,ax16,ax17,ax18),\
                (ax19,ax20,ax21,ax22,ax23,ax24)) = plt.subplots(4,6,sharex='col', sharey='row')
        axlist  = [ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10,ax11,ax12,ax13,ax14,ax15,\
                   ax16,ax17,ax18,ax19,ax20,ax21,ax22,ax23,ax24] 
        #layer info
        nLayerListSim       = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
        nLayerListTempObs   = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22] 
        #com 1
        if plotCom == 1:
            ncFileProcess = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run(S)\\TGLCH.nc")
            readObsData   = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGLData2009.xls")
            for i in range(0,22):
                modelLayer = nLayerListSim[i]
                modelRes   = getModelData(ncFileProcess,modelLayer,"STC",startTime,endTime)
                obsLayer   = nLayerListTempObs[i]
                obsDataRes = getObsData(readObsData,obsLayer)
                updateAx_2(axlist[i],modelRes,obsDataRes,layerNameList[i],dataIdxs)
            updateLastAx(ax24,"J75 VS Y05 VlS C05")
            red_patch = mpatches.Patch(color='red', label='Obs')
            blue_patch = mpatches.Patch(color='blue', label='Model')
            plt.legend(handles=[red_patch,blue_patch])
            f.autofmt_xdate()
        # com 3
        if plotCom == 3:
            ncFileProcess1 = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT(J75).nc")
            ncFileProcess2 = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT(C05).nc")
            ncFileProcess3 = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT(Y05).nc")
            readObsData = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGLData2009.xls")
            for i in range(0,22):
                modelLayer = nLayerListSim[i]
                modelRes1  = getModelData(ncFileProcess1,modelLayer,"STC",startTime,endTime)
                modelRes2  = getModelData(ncFileProcess2,modelLayer,"STC",startTime,endTime)
                modelRes3  = getModelData(ncFileProcess3,modelLayer,"STC",startTime,endTime)
                obsLayer   = nLayerListTempObs[i]
                obsDataRes = getObsData(readObsData,obsLayer)
                updateAx_4(axlist[i],obsDataRes,modelRes1,modelRes2,modelRes3,layerNameList[i],dataIdxs)
            updateLastAx(ax24,"J75 VS C05 VS Y05")
            red_patch = mpatches.Patch(color='red', label='Obs')
            blue_patch = mpatches.Patch(color='blue', label='J75')
            green_patch = mpatches.Patch(color='green', label='C05')
            yellow_patch = mpatches.Patch(color='yellow', label='Y05')
            plt.legend(handles=[red_patch,blue_patch,green_patch,yellow_patch])
            f.autofmt_xdate()
    #mos
    if plotType == 2:
        #ax define
        f, ((ax1,ax2,ax3,ax4,ax5),(ax6,ax7,ax8,ax9,ax10),(ax11,ax12,ax13,ax14,ax15)) \
                        = plt.subplots(3,5,sharex='col', sharey='row')
        axlist              = [ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10,ax11,ax12,ax13,ax14,ax15] 
        #layer info
        nLayerListSim       = [2,3,4,5,6,7,8,9,10,11,12,13]
        nLayerListMosObs    = [23,24,25,26,27,28,29,30,31,32,33,34]
         #com 1
        if plotCom == 1:
            ncFileProcess  = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.nc")
            readObsData    = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGLData2009.xls")
            for i in range(0,12):
                modelLayer = nLayerListSim[i]
                modelRes   = getModelData(ncFileProcess,modelLayer,"SH2O")
                obsLayer   = nLayerListMosObs[i]
                obsDataRes = getObsData(readObsData,obsLayer,"MOS")
                updateAx_2(axlist[i],modelRes,obsDataRes,layerNameList[i],dataIdxs,"%")

            updateLastAx(ax15,"KOREN99")
            red_patch   = mpatches.Patch(color='red',label='Obs')
            blue_patch  = mpatches.Patch(color='blue',label='KOREN99')
            plt.legend(handles=[red_patch,blue_patch])
            f.autofmt_xdate()
        if plotCom == 2:
            print "ok"


    plt.subplots_adjust(bottom=0.15)
    plt.show()





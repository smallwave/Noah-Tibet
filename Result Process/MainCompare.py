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

def getModelData(ncFileProcess,nlayer,modelAttr = "SMAV"):
    nlayer = nlayer - 1
    modelRes = ncFileProcess.getNcDataByDay(modelAttr,nlayer)
    if (modelAttr == "STC"):
         modelRes = map(lambda x:x - 273.15,modelRes)
    return modelRes


def getObsData(readObsData,nlayer):
    obsDataRes = readObsData.getObsData(nlayer)
    return obsDataRes


def updateAx(ax,modelRes,obsDataRes,Title):
    ax.plot(obsDataRes,'r',label='Obs')
    ax.plot(modelRes,'b',label='Model')
    ax.set_title(Title)
    ax.set_ylabel("Temperature(C)")
    #for tick in ax.xaxis.get_major_ticks():
    #    tick.label.set_fontsize(8)
    #    tick.label.set_rotation('vertical')
    rmseValue = rmse(obsDataRes,modelRes)
    ax.text(0.95, 0.01, "RMSE:{:.3}".format(rmseValue),
        verticalalignment='bottom', horizontalalignment='right',
        transform=ax.transAxes,
        color='green', fontsize=15)


def updateAxMos(ax,modelRes,Title):
    ax.plot(modelRes,'b',label='Model')
    ax.set_title(Title)
    ax.set_ylabel("%")
    #for tick in ax.xaxis.get_major_ticks():
    #    tick.label.set_fontsize(8)
    #    tick.label.set_rotation('vertical')


def updateLastAx(ax,strText):
    ax.text(0.95, 0.41, strText,
       verticalalignment='center', horizontalalignment='right',
       transform=ax.transAxes,
       color='red', fontsize=20)


#Main code
if __name__ == '__main__':
    '''
    #1   0.01  
    #2   0.05  Y  ax1  
    #3   0.1   Y  ax2
    #4   0.2   Y  ax3
    #5   0.4
    #6   0.7   Y  ax4
    #7   0.9   Y  ax5
    #8   1.05  Y  ax6
    #9   1.4   Y  ax7
    #10  1.75  Y  ax8
    #11  2.1   Y  ax9
    #12  2.45  Y  ax10
    #13  2.8   Y  ax11
    '''
    plotType = 3  # 1 temp 2 mos 3 TWO MOS
    f, ((ax1, ax2, ax3, ax4), (ax5, ax6,ax7,ax8), (ax9, ax10,ax11,ax12)) \
                          = plt.subplots(3, 4, sharex='col', sharey='row')

    nLayerList    = [2,3,4,6,7,8,9,10,11,12,13]
    layerNameList = ["0.05m","0.1m","0.2m","0.7m","0.9m","1.05m","1.4m","1.75m","2.1m","2.45m","2.8m"]
    axlist        = [ax1, ax2, ax3, ax4,ax5, ax6,ax7,ax8,ax9, ax10,ax11]  

    if plotType == 1:
        ncFileProcess = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.nc")
        readObsData = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGL2010TEMP.xls")
        i = 0
        for nLayer in nLayerList :
            modelRes   = getModelData(ncFileProcess,nLayer,"STC")
            obsDataRes = getObsData(readObsData,nLayer)
            updateAx(axlist[i],modelRes,obsDataRes,layerNameList[i])
            i = i + 1

        updateLastAx(ax12,"Soil:FAST2.8m, Y08")
        red_patch = mpatches.Patch(color='red', label='Obs')
        blue_patch = mpatches.Patch(color='blue', label='Model')
        plt.legend(handles=[red_patch,blue_patch])

    if plotType == 2:
        ncFileProcess = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.nc")
        i = 0
        for nLayer in nLayerList :
            modelRes = getModelData(ncFileProcess,nLayer,"SH2O")
            updateAxMos(axlist[i],modelRes,layerNameList[i])
            i = i + 1

        updateLastAx(ax12,"ST:FAST:0.7m,Y08,KOREN99")
        blue_patch = mpatches.Patch(color='blue', label='Model KOREN99')
        plt.legend(handles=[blue_patch])

    if plotType == 3:
        ncFileProcess1 = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT(OLDW).nc")
        ncFileProcess2 = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT(NY06WK).nc")
        i = 0
        for nLayer in nLayerList :
            modelRes1 = getModelData(ncFileProcess1,nLayer,"SH2O")
            modelRes2 = getModelData(ncFileProcess2,nLayer,"SH2O")
            updateAx(axlist[i],modelRes1,modelRes2,layerNameList[i])
            i = i + 1

        updateLastAx(ax12,"KOREN99 VS NY06")
        red_patch = mpatches.Patch(color='blue', label='Model KOREN99 MAXLW AND K')
        blue_patch = mpatches.Patch(color='red', label='Model NY06 MAXLW AND K')
        plt.legend(handles=[red_patch,blue_patch])

    plt.subplots_adjust(bottom=0.15)
    plt.show()





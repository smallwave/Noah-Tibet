##########################################################################################################
# NAME
#    CalPermafrost.py
# PURPOSE
#    Nc file process
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151218 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import sys
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess
import numpy as np
import matplotlib.pyplot as plt
from scipy import interpolate
from scipy.interpolate import InterpolatedUnivariateSpline

class CalPermafrostProperties(object):
    """description of class"""
    def __init__(self,strncFilePath):
        self.strncDataPath    =  strncFilePath;
   
    #2015.12.31 
    def IsPermafrost(self):
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth()
        maxList             =  alllayerMonthMean[0]
        minList             =  alllayerMonthMean[1] 
        if (min(maxList) < 273):  # max min <0
            return 1     #permafrost
        if (min(minList) < 273):  # min min <0
            return 2     #Seasonal frozen soil
        else:
            return 3     #no frozen soil

    #2015.12.18
    def CalCalPermafrostALT(self,layerList = None):
        if layerList is None:
            layerList = [-0.05,-0.1,-0.2,-0.5,-0.7,-0.9,-1.05,-1.4,-1.75,-2.1,-2.45,-2.8,\
                         -3.6,-4.5,-5.5,-6.5,-7.5,-8.5,-9.5,-11,-13,-15]
        lenDepths = len(layerList)
        ncFileProcess = NcFileProcess(self.strncDataPath)
        maxList =[]
        for i in range(0,lenDepths):
            maxMin = ncFileProcess.getMaxMinData("STC",i)
            maxList.append(maxMin[0]) 

        maxList = map(lambda x:x-273.15,maxList)
        #f = interpolate.interp1d(maxList, layerList)
        f = interpolate.interp1d( maxList, layerList)
        print f(-0.0 )
        # calculate new x's and y's
        x_new = np.linspace(maxList[0], maxList[-1], 500)
        y_new = f(x_new)

        plt.plot(maxList,layerList,'o', x_new, y_new)
        plt.xlim([maxList[-1]-2, maxList[0] + 2 ])
        plt.show()




       

     
        
        
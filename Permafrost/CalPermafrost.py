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
from scipy.interpolate import interp1d
import operator

class CalPermafrostProperties(object):
    """description of class"""
    def __init__(self,strncFilePath):
        self.strncDataPath    =  strncFilePath;

    #2016.1.29
    def getSubMax4Alt(self,maxList):
        listRe = []
        isAdd  = True
        for val in maxList:
            if (isAdd):
                if(val <0):
                    isAdd = False
                listRe.append(val)
            else:
                break
        return listRe

    #2015.12.31 
    def IsPermafrost(self,varTimeDataArray):
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(5,varTimeDataArray)
        maxList             =  alllayerMonthMean[0]
        minList             =  alllayerMonthMean[1] 
        if (min(maxList) < 273.15):  # max min <0
            return 1     #permafrost
        if (min(minList) < 273.15):  # min min <0
            return 2     #Seasonal frozen soil
        else:
            return 3     #no frozen soil

    #2015.12.18
    def CalCalPermafrostALT(self,varTimeDataArray,layerList = None):
        if layerList is None:
           layerList        = [-0.045,-0.091,-0.166,-0.289,-0.493,-0.829,-1.383,-2.296,-3.2,-4.2,-5.2,-6.2,\
                               -7.2,-8.2,-9.2,-11.2,-13.2,-15.2]
        lenDepths           =  len(layerList)
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        maxList =[]
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(0,varTimeDataArray)
        maxList             =  alllayerMonthMean[0]
        maxList  = map(lambda x:x-273.15,maxList)
        
        ALTINFO  = 15.0
        if min(maxList) > 0:
            ALTINFO = -2.0
        elif maxList[0] > 0:
            reList = self.getSubMax4Alt(maxList)
            nLen   = len(reList)
            InterFun = interp1d( reList, layerList[0:nLen])
            ALTINFO  = InterFun(0.0)
        FALTINFO  = round(float(ALTINFO),2)
        print FALTINFO
        return FALTINFO
        ## calculate new x's and y's
        #x_new = np.linspace(maxList[0], maxList[-1], 500)
        #y_new = f(x_new)
        #plt.plot(maxList,layerList,'o', x_new, y_new)
        #plt.xlim([maxList[-1]-2, maxList[0] + 2 ])
        #plt.show()

    #2016.1.30
    def CalCalPermafrostMAGT(self,varTimeDataArray,layerList = None):
        if layerList is None:
           layerList        = [-0.045,-0.091,-0.166,-0.289,-0.493,-0.829,-1.383,-2.296,-3.2,-4.2,-5.2,-6.2,\
                               -7.2,-8.2,-9.2,-11.2,-13.2,-15.2]
        lenDepths           =  len(layerList)
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(0,varTimeDataArray)
        maxList             =  map(lambda x:x-273.15,alllayerMonthMean[0])
        minList             =  map(lambda x:x-273.15,alllayerMonthMean[1])
        MAGTINFO            =  0.0
        DAZZINFO            =  0.0
        DiffMinMaxList      =  list(map(operator.sub, maxList, minList))
        index = 0
        for val in DiffMinMaxList:
            index = index + 1
            if val < 0.5:
                maxVal    =  maxList[index-1]
                minVal    =  minList[index-1]
                MAGTINFO  =  (maxVal + minVal)/2.0
                DAZZINFO  =  layerList[index-1]
                break
        #Use 15.2m temperature
        if(MAGTINFO == 0.0):
            maxVal    =  maxList[17]
            minVal    =  minList[17]
            MAGTINFO  =  (maxVal + minVal)/2.0
            DAZZINFO  =  -15.20
        #
        if(MAGTINFO > 0.0):
            MAGTINFO  = 0.0
        #
        if(MAGTINFO <-20.0):
            MAGTINFO  = -20.0

        MAGTINFO  = round(float(MAGTINFO),2)
        print MAGTINFO,DAZZINFO
        return [MAGTINFO,DAZZINFO]
    
    #2016.1.31
    def getVFun(self,l):
        return 10000*10000*abs(l)

    def calICEListFun(self,ice,v):
        return ice*v*(1.0/0.9)

    #2016.1.31
    def CalCalPermafrostICE(self,varTimeDataArray,layerList = None):
        if layerList is None:
           layerList        =  [-0.045,-0.091,-0.166,-0.289,-0.493,-0.829,-1.383,-2.296,-3.2,-4.2,-5.2,-6.2,\
                                -7.2,-8.2,-9.2,-11.2,-13.2,-15.2]
        lenDepths           =  len(layerList)
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        alllayerICE         =  ncFileProcess.getAllLayerMeanICEByYear(varTimeDataArray)
        allVList            =  map(self.getVFun,layerList)
        allICEList          =  map(self.calICEListFun,alllayerICE,allVList)
        ICE                 =  0.0
        ICE                 =  sum(allICEList)
        if(ICE < 0.0):
            ICE  = 0.0
        ICE  = round(float(ICE),2)
        return ICE
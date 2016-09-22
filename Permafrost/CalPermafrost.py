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
import datetime


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

    #2016.6.6
    def getSubMax4AltOfSeasonally(self,maxList):
        listRe = []
        isAdd  = True
        for val in maxList:
            if (isAdd):
                if(val >0):
                    isAdd = False
                listRe.append(val)
            else:
                break
        return listRe


    #2015.12.31 
    def IsPermafrost(self,varTimeDataArray,startTime = None, endTime = None):
        if startTime is None:
            startTime       = datetime.datetime(2010,1,1)
        if endTime is None:
            endTime         = datetime.datetime(2010,12,31)

        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(5,varTimeDataArray,startTime,endTime)
        #alllayerDay         =  ncFileProcess.getAllLayerMaxMinTempByDay(5,varTimeDataArray)
        maxList             =  alllayerMonthMean[0]
        minList             =  alllayerMonthMean[1] 
        self.IdentificationPermafrost(maxAllLevelList,minAllLevelList)

    #2016.9.12
    def IdentificationPermafrost(self,maxAllLevelList,minAllLevelList):
        if (min(maxAllLevelList) < 273.05):  # max min <0
            return 1     #permafrost
        if (min(minAllLevelList) < 273.05):  # min min <0
            return 2     #Seasonal frozen soil
        else:
            return 3     #no frozen soil

    # 2016.8.5
    def StaPermafrostByYear(self,varTimeDataArray,year = 2010):
        startTime       = datetime.datetime(year,1,1)
        endTime         = datetime.datetime(year,12,31)
        if(self.IsPermafrost(varTimeDataArray,startTime,endTime) == 1):
            return 1
        return 0

    # 2016.9.12
    def IsPermafrostByYear(self,varTimeDataArray,startYear, endYear):
        startTime           =  datetime.datetime(startYear,1,1)
        endTime             =  datetime.datetime(endYear,12,31)
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        allLayerMonthTemp   =  ncFileProcess.getAllLayerMeanTempByYearMonth(5,varTimeDataArray,startTime,endTime)
        # first get layer
        allLayerListMax     =  []
        allLayerListMin     =  []
        for layerMonthTemp in allLayerMonthTemp:
            layerYearMonthTemp = list(zip(*[iter(layerMonthTemp)]*12))
            maxValue             =  map(max, layerYearMonthTemp)  
            minValue             =  map(min, layerYearMonthTemp)    
            allLayerListMax.append(maxValue)           #by  layer 
            allLayerListMin.append(minValue)

        allLayerListMax =  zip(*allLayerListMax)   #by  year
        allLayerListMin =  zip(*allLayerListMin)
        # permafrost 
        nYear = endYear-startYear;
        strType = " "
        for i in range(0,nYear):
            nType = self.IdentificationPermafrost(allLayerListMax[i],allLayerListMin[i])
            strType = strType+ " "+ str(nType)
        return strType





            











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
    #2016.6.6
    def CalCalPermafrostALTOfSeasonally(self,varTimeDataArray,layerList = None):
        if layerList is None:
           layerList        = [-0.045,-0.091,-0.166,-0.289,-0.493,-0.829,-1.383,-2.296,-3.2,-4.2,-5.2,-6.2,\
                               -7.2,-8.2,-9.2,-11.2,-13.2,-15.2]
        lenDepths           =  len(layerList)
        ncFileProcess       =  NcFileProcess(self.strncDataPath)
        maxList =[]
        alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(0,varTimeDataArray)
        minList             =  alllayerMonthMean[1]
        minList  = map(lambda x:x-273.15,minList)
        
        ALTINFO  = 15.0
        if min(minList) > 0:
            ALTINFO = 0.0
        if max(minList) < 0:
            ALTINFO = -20.0
        elif minList[0] < 0:
            reList = self.getSubMax4AltOfSeasonally(minList)
            nLen   = len(reList)
            InterFun = interp1d( reList, layerList[0:nLen])
            ALTINFO  = InterFun(0.0)
        FALTINFO  = round(float(ALTINFO),2)
        print FALTINFO
        return FALTINFO


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

    #2016.8.5
    def StaPermafrostCount(self,varTimeDataArray):
        print "ok"
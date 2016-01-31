# Required Packages
import matplotlib.pyplot as plt
import sys
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess
import numpy as np
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
import shapefile
from dbfpy import dbf

def getSubMax4Alt(maxList):
    listRe = []
    isAdd  = True
    for val in maxList:
        if (isAdd):
            if(val <0):
                isAdd = False
            listRe.append(val);
        else:
            break
    return listRe

###################################################################################
# Main Test
###################################################################################
if __name__ == '__main__':
    #layerList = [-0.045,-0.091,-0.166,-0.289,-0.493,-0.829,-1.383,-2.296,-3.2,-4.2,-5.2,-6.2,\
    #             -7.2,-8.2,-9.2,-11.2,-13.2,-15.2]
    #lenDepths = len(layerList)
    #ncFileProcess = NcFileProcess("E:/worktemp/Permafrost(MAPPING)/TEST/101.963346096_37.121391739.nc")
    #maxList =[]
    #alllayerMonthMean   =  ncFileProcess.getAllLayerMeanTempByMonth(0)
    #maxList             =  alllayerMonthMean[0]
    #maxList  = map(lambda x:x-273.15,maxList)
    #ALTINFO  = 100
    #if maxList[0] > 0:
    #    reList = getSubMax4Alt(maxList)
    #    nLen   = len(reList)
    #    InterFun = interp1d( reList, layerList[0:nLen])
    #    ALTINFO  = InterFun(0.0)
    #    print ALTINFO

    ## calculate new x's and y's
    #x_new = np.linspace(min(reList), max(reList), 500)
    #y_new = InterFun(x_new)
    #plt.plot(reList,layerList[0:nLen],'o', x_new, y_new)
    #plt.xlim([min(reList)-2, max(reList) + 2 ])
    #plt.show()

    db = dbf.Dbf("E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf")

    #Editing a value, assuming you want to edit the first field of the first record
    rec = db[0]
    rec["ALT"] = 100.0
    rec.store()
    del rec
    db.close()

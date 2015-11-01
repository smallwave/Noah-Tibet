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

from NcFileResPostProcess import NcFileProcess
import sys
sys.path.append('Parameter Estimation')
from ReadObs import ReadObsData
import matplotlib.pyplot as plt  

#Main code
if __name__ == '__main__':
     ncFileProcess = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.nc")
     modelRes = ncFileProcess.getNcData("STC",2)
     modelRes = map(lambda x:x - 273.15,modelRes)
     readObsData = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGL2010TEMP.xlsx")
     obsDataRes = readObsData.getObsData(2)
     #plot
     plt.plot(obsDataRes,'b*')
     plt.plot(modelRes,'r')
     plt.xlabel("2010")
     plt.ylabel("T")
     plt.legend()
     plt.show()


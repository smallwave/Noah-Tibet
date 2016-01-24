##########################################################################################################
# NAME
#    MainCalALT.py
# PURPOSE
#    MainCalALT program

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151218 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import sys
sys.path.append('Permafrost')
from CalPermafrost import *
from BatchCells import *

#Main code
if __name__ == '__main__':

    selType  =  2
    batRunModel  =   cBatchCells()
    #1 run model
    if selType == 1:
        #strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(TXT)\\"
        strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\QTP(TXT)\\"
        batRunModel.RunNoahModel(strtxtForcePath)
    #1 permafrost
    if selType == 2:
        #strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
        #strOutputTxt   =  "E:\\worktemp\\Permafrost(MAPPING)\\XKKUNLUN(RES)\\PermafrostMap20021.txt"
        strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(NC)\\"
        strOutputTxt   =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\PermafrostMap2002.txt"
        batRunModel.RunCalPermafrost(strncPath,strOutputTxt)

    



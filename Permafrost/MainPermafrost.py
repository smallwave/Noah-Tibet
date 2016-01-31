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

    selType      =  2
    batRunModel  =  cBatchCells()

    #1 run model
    if selType == 1:
        #strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(TXT)\\"
        strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\QTP1996(TXT)\\"
        batRunModel.RunNoahModel(strtxtForcePath)

    #2 check run model  2016.1.30
    if selType == 2:
        strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\QTP1996(TXT)\\"
        #strncPath       =  "E:/worktemp/Permafrost(MAPPING)/TEST/"
        strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP1996(NC)\\"
        batRunModel.CheckModelOutput(strncPath,strtxtForcePath)

    #3 permafrost
    if selType == 3:
        #strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
        #strOutputTxt   =  "E:\\worktemp\\Permafrost(MAPPING)\\XKKUNLUN(RES)\\PermafrostMap20021.txt"
        strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(NC)\\"
        strOutputTxt   =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\PermafrostMap2010.txt"
        batRunModel.RunCalPermafrost(strncPath,strOutputTxt)

    #4 ALT  2016.1.29
    if selType == 4:
        #strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Res2010(Permafrost).dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalAlt(strShpPointPath,strNcFilePath)
    #5 MAGT DAZZ  2016.1.29
    if selType == 5:
        strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Res2010(Permafrost).dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalMAGT(strShpPointPath,strNcFilePath)
    #6 ICE
    if selType == 6:
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Res2010(Permafrost).dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalICE(strShpPointPath,strNcFilePath)            


    



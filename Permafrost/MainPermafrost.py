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
import datetime 

#Main code
if __name__ == '__main__':

    selType      =  3
    batRunModel  =  cBatchCells()

    #1 check txt   2016.9.1
    if selType == 1:
        strtxtForcePathSource       = "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(TXT)\\"
        strtxtForcePathDestination  = "F:\\worktemp\\Permafrost(Change)\\Test\\"
        batRunModel.CheckForceTxt(strtxtForcePathDestination,strtxtForcePathSource)

    #1 run model
    if selType == 2:
        #strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(TXT)\\"
        #strtxtForcePath  = "E:\\worktemp\\Permafrost(MAPPING)\\QTP(TXT)\\"
        strtxtForcePath = "D:\\Data\\QTP(TXT)\\"
        batRunModel.RunNoahModel(strtxtForcePath)

    #2 check run model  2016.1.30
    if selType == 3:
        strtxtForcePath = "D:\\Data\\QTP(TXT)\\"
        #strncPath       =  "E:/worktemp/Permafrost(MAPPING)/TEST/"
        strncPath      =  "F:\\worktemp\\Permafrost(Change)\\Work\QTP(NC)\\"
        batRunModel.CheckModelOutput(strncPath,strtxtForcePath)

    #3 permafrost
    if selType == 4:
        #strncPath      =  "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
        #strOutputTxt   =  "E:\\worktemp\\Permafrost(MAPPING)\\XKKUNLUN(RES)\\PermafrostMap20021.txt"
        #strncPath       =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(NC)\\"
        strncPath       =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(NC)\\"
        strOutputTxt    =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(RES)\\PermafrostMapGZ1982.txt"
        batRunModel.RunCalPermafrost(strncPath,strOutputTxt)

    #4 ALT  2016.1.29
    if selType == 5:
        #strncPath       =  "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        strShpPointPath =  "D:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Permafrost2010New.dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalAlt(strShpPointPath,strNcFilePath)
    #5 MAGT DAZZ  2016.1.29
    if selType == 6:
        strShpPointPath =  "D:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Permafrost2010New.dbf"
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Res2010(Permafrost).dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalMAGT(strShpPointPath,strNcFilePath)
    #6 ICE
    if selType == 7:
        #strShpPointPath =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        strShpPointPath =  "D:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Permafrost2010New.dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalICE(strShpPointPath,strNcFilePath)            

    #7 Seasonnaly frozen soil ALT
    if selType == 8:
        #strShpPointPath =  "D:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\SaesonallyPermafrost2010New.dbf"
        strShpPointPath =  "D:\\worktemp\\Permafrost(MAPPING)\\QTP(RES)\\Test.dbf"
        strNcFilePath   =  "E:/worktemp/Permafrost(MAPPING)/QTP(NC)/"
        batRunModel.RunCalAltOfSeasonally(strShpPointPath,strNcFilePath)   
        
    # Statistical quantity of permafrost
    # 20160805
    if selType == 9:
        iStartTime          =  1983
        iEndTime            =  2013
        #strncPath       =  "E:\\worktemp\\Permafrost(MAPPING)\\QTP(NC)\\"
        strNcFilePath       =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(NC)\\"
        strOutputTxt        =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(RES)\\PermafrostMapCount.txt"
        batRunModel.RunStaPermafrostCount(strNcFilePath,strOutputTxt,iStartTime,iEndTime) 


           


    



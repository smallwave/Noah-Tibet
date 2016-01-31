##########################################################################################################
# NAME
#    MainTXTProduce.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151230 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
from CFMD2Txt import sPointForceData
from CFMD2Txt import upDateTxtInfo
from CFMD2Txt import upDateCFMDData
from CFMD2Txt import getCFMDDataFiles
from CFMD2Txt import PointForceData2Txt
import shapefile
import time 
import datetime 
import os.path
import sys
sys.path.append('GetDate')
from getNcFileDate import getListNcFileDate

###################################################################################
# Main Test
###################################################################################
if __name__ == '__main__':
    start = time.clock()
    # new object
    spointForceData            =   sPointForceData() 
    spointForceData.startdate  =   datetime.datetime(1988,1,1)
    spointForceData.enddate    =   datetime.datetime(1997,1,1)
    #update 1 update soil veg and lon lat
    sfPoint   = shapefile.Reader("E:/worktemp/Permafrost(MAPPING)/Data/Point/Group1996/Test.shp")
    #define vars
    ncFilePath         =   "D:\\workspace\\Data\\CFMD(QTP)\\Data_forcing_03hr_010deg_Unzip\\"
    txtFilePath        =   "E:\\worktemp\\Permafrost(MAPPING)\\QTP1996(TXT)\\"
    strncResPath       =   "E:\\worktemp\\Permafrost(MAPPING)\\QTP1996(NC)\\"
    spointForceData.output_dir = strncResPath

    #get all files
    strFileNameList    =   ("Wind","Temp","SHum","Pres","SRad","LRad","Prec")  
    getCFMDFiles       =   getCFMDDataFiles(ncFilePath,
                                            strFileNameList,
                                            spointForceData.startdate,
                                            spointForceData.enddate)
    ncAllFilePathlist  =   getCFMDFiles.getCFMDFiles()
    if len(ncAllFilePathlist) <= 0 :
        print "There have no Path: " + datafinallyPath
        os.system("pause")
        exit(0)
    #get date info
    getCFMDDateAll    =   getListNcFileDate(ncAllFilePathlist[0])
    varTypeData       =   getCFMDDateAll.getCFMDDateAll()


    #Batch
    shapeRecs = sfPoint.shapeRecords()
    nPoint    = len(shapeRecs)
    for i in range(0,nPoint):
        #update 1 veg soil 
        shapeRec           =   shapeRecs[i].record
        updateCFMDData     =   upDateTxtInfo(spointForceData,shapeRec)
        spointForceData    =   updateCFMDData.getUpdateSPointForceData()
        outputTxtPathName  =   txtFilePath + str(spointForceData.Longitude) + \
                                   "_" + str(spointForceData.Latitude) + ".txt"
        if os.path.isfile(outputTxtPathName) and os.access(outputTxtPathName, os.R_OK):
            continue
        #update 2 CFMD data   
        updateCFMDData     =   upDateCFMDData(spointForceData.Latitude,
                                              spointForceData.Longitude,
                                              ncAllFilePathlist)
        spointForceData.CFMDData =  updateCFMDData.getCFMDData(varTypeData)
        #write files
        ptForceData2Txt    =   PointForceData2Txt(outputTxtPathName)
        ptForceData2Txt.writePointData2Txt(spointForceData)
        print "Current Extract is :  %f  " % i
    end = time.clock()
    print "Convert is request:  %f s" % (end - start)
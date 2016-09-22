##########################################################################################################
# NAME
#    MainTXTStatistics.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160918 -- Initial version created and posted online
# REFERENCES
##########################################################################################################
from CFMD2Txt import upDateCFMDData
from CFMD2Txt import getCFMDDataFiles
import shapefile
import time 
import datetime 
import pandas
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

    startdate  =   datetime.datetime(1983,1,1)
    enddate    =   datetime.datetime(2013,1,1)

    #update 1 update soil veg and lon lat
    sfPoint   = shapefile.Reader("F:/worktemp/Permafrost(Change)/Data/Point/Test.shp")
    #define vars
    ncFilePath         =   "D:\\Data\\CFMD(QTP)\\Data_forcing_03hr_010deg_Unzip\\"
    txtFilePath        =   "D:\\Gaize.txt"


    #get all files
    strFileNameList    =   ["Temp"]
    getCFMDFiles       =   getCFMDDataFiles(ncFilePath,
                                            strFileNameList,
                                            startdate,
                                            enddate)
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
    with open(txtFilePath, "w") as text_file:
        for i in range(0,nPoint):
            shapeRec           =   shapeRecs[i].record
            Longitude          =   float(shapeRec[1]);
            Latitude           =   float(shapeRec[2]); 
            updateCFMDData     =   upDateCFMDData(Latitude,
                                                  Longitude,
                                                  ncAllFilePathlist)
            selVarCFMDData     =  updateCFMDData.getSingleCFMDData()
            varDataFrame       =  pandas.DataFrame(selVarCFMDData, index = varTypeData, columns=['Temp'])
            #group by day
            groupVarSelData     =  varDataFrame.groupby(lambda x: (x.year))
            groupVarSelDataMean =  groupVarSelData.mean() 
            #clip by sele data
            resVarList          =  groupVarSelDataMean['Temp'].values.tolist()
            strResVarList       =  ' '.join(format(var, "10.3f") for var in resVarList)
            text_file.write(str(Longitude)+" " + str(Latitude))
            text_file.write(" " + str(strResVarList))
            text_file.write("\n")
            print "Current Extract is :  %f  " % i

    end = time.clock()
    print "Convert is request:  %f s" % (end - start)
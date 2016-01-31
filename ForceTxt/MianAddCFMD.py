##########################################################################################################
# NAME
#    MianAddCFMD.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20160125 -- Initial version created and posted online
# REFERENCES
##########################################################################################################
import os
import sys
import formic
import datetime 
sys.path.append('ForceTxt')
from UpdateForceTxt import cForceTxtUpdate
from CFMD2Txt import getCFMDDataFiles
from CFMD2Txt import getCFMDDate
from CFMD2Txt import upDateCFMDData
###################################################################################
# Main Test
###################################################################################
if __name__ == '__main__':

    # path
    strtxtForceInPath  =   "E:\\worktemp\\Permafrost(MAPPING)\\GAIZE(TXT)\\"
    ncFilePath         =   "D:\\workspace\\Data\\CFMD(QTP)\\Data_forcing_03hr_010deg_Unzip\\"

    # get all files
    startdate           =  datetime.datetime(2011,1,1)
    enddate             =  datetime.datetime(2013,1,1)
    strFileNameList    =   ("Wind","Temp","SHum","Pres","SRad","LRad","Prec")  
    getCFMDFiles       =   getCFMDDataFiles(ncFilePath,strFileNameList,startdate,enddate)
    ncAllFilePathlist  =   getCFMDFiles.getCFMDFiles()
    if len(ncAllFilePathlist) <= 0 :
        print "There have no Path: " + datafinallyPath
        os.system("pause")
        exit(0)
    #get date info
    getCFMDDateAll    =   getCFMDDate(ncAllFilePathlist[0])
    varTypeData       =   getCFMDDateAll.getCFMDDateAll()

    #process txt
    fileset = formic.FileSet(include="**/*.txt", directory= strtxtForceInPath)
    nFile   = 0 # print process file ID
    for file_name in fileset:
        nFile+=1
        print "################################################################"
        print "Current file is : " + file_name + "; It is the " + str(nFile)
        print "################################################################"
        InputFileDir,InputFile   = os.path.split(file_name)
        filename, file_extension = os.path.splitext(InputFile)
        FileNameS                = filename.split("_")  
        Latitude                 = float(FileNameS[1])      #33.072      # lat  
        Longitude                = float(FileNameS[0])      #91.939      # lon
        
        # update endtime path
        forceTxtUpdate  =  cForceTxtUpdate(file_name)
        forceTxtUpdate.updateEndTime(enddate)
  
        #get CFMD Data
        updateCFMDData           =   upDateCFMDData(Latitude,Longitude,ncAllFilePathlist)
        AllCFMDDataList          =   updateCFMDData.getCFMDData(varTypeData)
        
        # get array of lines
        with open(file_name, 'a') as txtFile:
            if (len(AllCFMDDataList) > 0):
                for strRow in AllCFMDDataList: 
                    txtFile.write('{}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}{:17.10f}\n' \
                        .format(strRow[0].strftime("%Y %m %d %H %M"),strRow[1],249,strRow[2],strRow[3],strRow[4],strRow[5],strRow[6],strRow[7]))  

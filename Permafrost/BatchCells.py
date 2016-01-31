##########################################################################################################
# NAME
#    Run model.py
# PURPOSE
#   Run model
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151231 -- Initial version created and posted online
# REFERENCES

##########################################################################################################
import subprocess
import os
import sys
import formic
import linecache
import shlex
import shapefile
import glob
from dbfpy import dbf
from CalPermafrost import *
sys.path.append('GetDate')
from getNcFileDate import getSingleNcFileDate
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess
import shutil

class cBatchCells(object):
     def __init__(self):
         print "call Batch cells"
     #2015.12.31
     def RunNoahModel(self,strtxtForcePathIn):
        #1 run model
        fileset = formic.FileSet(include="**/*.txt", directory=strtxtForcePathIn)
        nFile   = 0 # print process file ID
        os.chdir('E:\\worktemp\\Permafrost(MAPPING)\\Run(M)\\')
        outputPath = None
        for file_name in fileset:
            nFile+=1
            print "Current file is : " + file_name + "; It is the " + str(nFile)
            print "################################################################"
            # get array of lines
            if outputPath is None:
                with open(file_name, 'r') as txtFile:
                    updateLine  =  5   # from 1 ~  not 0
                    lineTxt     =  linecache.getline(file_name, updateLine)
                    lineTxtS    =  lineTxt.split("=")  
                    outputPath  =  lineTxtS[1].strip()[1:-1]
            InputFileDir,InputFile   = os.path.split(file_name)
            filename, file_extension = os.path.splitext(InputFile)
            items  = [outputPath,filename,".nc"]
            outputFileName = ''.join(items)
            if os.path.isfile(outputFileName) and os.access(outputFileName, os.R_OK):
                continue
            #... updateOutputDirLine
            command   =  'simple_driver.exe '+ file_name
            subprocess.call(command, shell=True)  #call 7z command

     #2016.1.30
     def CheckModelOutput(self,strncPathIn,strtxtForcePathIn):
        #1 run model
        fileset = formic.FileSet(include="**/*.nc", directory=strncPathIn)
        nFile   = 0 # print process file ID
        # 
        varTimeDataArray  =  None;
        for file_name in fileset:
            nFile+=1
            print "################################################################"
            print "Current file is : " + file_name + "; It is the " + str(nFile)
            print "################################################################"
            #get date info
            if (varTimeDataArray is None):
                getNcFileDate     =   getSingleNcFileDate(file_name)
                varTimeDataArray  =   getNcFileDate.getNcFileDate("Times","Noah")

            ncFileProcess         =  NcFileProcess(file_name)
            alllayerMonthMean     =  ncFileProcess.getAllLayerMeanTempByMonth(5,varTimeDataArray)
            maxListValue          =  max(alllayerMonthMean[0])
            if (maxListValue < 100) or  (maxListValue > 400):
                InputFileDir,InputFile   = os.path.split(file_name)
                filename, file_extension = os.path.splitext(InputFile)
                strFileFix               = filename+".txt"
                srcfile                  =  strtxtForcePathIn + strFileFix
                if not os.path.exists(srcfile):
                    print "Error there have no " + srcfile
                    os.system("pause")
                    exit(0)
                dstdir                   =  os.path.join("E:/worktemp/Permafrost(MAPPING)/Run(M)/", strFileFix)
                shutil.copy(srcfile, dstdir)
                
     #2015.12.31
     def RunCalPermafrost(self,strncPathIn,strOutputTxtIn):
        #1 run model
        fileset = formic.FileSet(include="**/*.nc", directory=strncPathIn)
        nFile   = 0 # print process file ID
        # 
        varTimeDataArray  =  None;
        with open(strOutputTxtIn, "w") as text_file:
            for file_name in fileset:
                nFile+=1
                print "################################################################"
                print "Current file is : " + file_name + "; It is the " + str(nFile)
                print "################################################################"
                InputFileDir,InputFile   = os.path.split(file_name)
                filename, file_extension = os.path.splitext(InputFile)
                FileNameS                = filename.split("_")  
                calPermafrost  =  CalPermafrostProperties(file_name)
                #get date info
                if (varTimeDataArray is None):
                    getNcFileDate     =   getSingleNcFileDate(file_name)
                    varTimeDataArray  =   getNcFileDate.getNcFileDate("Times","Noah")

                nType          =  calPermafrost.IsPermafrost(varTimeDataArray)
                text_file.write(FileNameS[0]+" " + FileNameS[1] + " " + str(nType) +"\n")
            print "File : " + strOutputTxtIn + " write is ok !!!!!"

     #2015.1.30
     def RunCalPermafrostFeature(self,strPointShpPath,strNcFilePath,calType = "ALT"):
        db        = dbf.Dbf(strPointShpPath)
        #Batch
        nPoint    = len(db)
        #
        nFile   = 0 # print process file ID
        #
        varTimeDataArray  =  None;
        for i in range(0,nPoint):
            nFile+=1
            print "################################################################"
            print "Current file is the " + str(nFile)
            print "################################################################"
            #update 1 veg soil 
            rec = db[i]
            Longitude            =   float(rec[0])
            Latitude             =   float(rec[1])
            calPermafrostFeature =    0
            strFileFix = str(Longitude)+"_"+str(Latitude)+".nc"
            ncfilePath = strNcFilePath + strFileFix
            if not os.path.exists(ncfilePath):
                print "Error there have no " + file_name
                os.system("pause")
                exit(0)
            calPermafrost  =  CalPermafrostProperties(ncfilePath)
            #get date info
            if (varTimeDataArray is None):
                getNcFileDate     =   getSingleNcFileDate(ncfilePath)
                varTimeDataArray  =   getNcFileDate.getNcFileDate("Times","Noah")
            if calType == "ALT":
                calPermafrostFeature        =  calPermafrost.CalCalPermafrostALT(varTimeDataArray)
                rec[calType]                =  calPermafrostFeature
            elif calType == "MAGT":
                calPermafrostFeature        =  calPermafrost.CalCalPermafrostMAGT(varTimeDataArray)
                rec[calType]                =  calPermafrostFeature[0]
                rec["DAZZ"]                 =  calPermafrostFeature[1]
            elif calType == "ICE":
                calPermafrostFeature        =  calPermafrost.CalCalPermafrostICE(varTimeDataArray)
                rec[calType]                =  calPermafrostFeature
            rec.store()
            #del rec
        db.close()

     #2015.1.29
     def RunCalAlt(self,strPointShpPath,strNcFilePath):
         self.RunCalPermafrostFeature(strPointShpPath,strNcFilePath,"ALT")
         print "ALT  is ok !!!!!"

     #2015.1.29
     def RunCalMAGT(self,strPointShpPath,strNcFilePath):
         self.RunCalPermafrostFeature(strPointShpPath,strNcFilePath,"MAGT")
         print "MAGT  is ok !!!!!"

     def RunCalICE(self,strPointShpPath,strNcFilePath):
         self.RunCalPermafrostFeature(strPointShpPath,strNcFilePath,"ICE")
         print "ICE  is ok !!!!!"
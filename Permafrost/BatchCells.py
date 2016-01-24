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
from CalPermafrost import *

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
     #2015.12.31
     def RunCalPermafrost(self,strncPathIn,strOutputTxtIn):
        #1 run model
        fileset = formic.FileSet(include="**/*.nc", directory=strncPathIn)
        nFile   = 0 # print process file ID
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
                nType          =  calPermafrost.IsPermafrost()
                text_file.write(FileNameS[0]+" " + FileNameS[1] + " " + str(nType) +"\n")
            print "File : " + strOutputTxtIn + " write is ok !!!!!"
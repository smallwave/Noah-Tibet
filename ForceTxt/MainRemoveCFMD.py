##########################################################################################################
# NAME
#    MainRemoveCFMD.py
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
###################################################################################
# Main Test
###################################################################################

if __name__ == '__main__':

    strtxtForceInPath  = "E:/worktemp/Permafrost(MAPPING)/GAIZE(TXT)/"
    #process txt
    fileset = formic.FileSet(include="**/*.txt", directory= strtxtForceInPath)
    nFile   = 0 # print process file ID
    for file_name in fileset:
        # get array of lines
        with open(file_name, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            txtFile.seek(0)
            #... REMOVE 
            lines  =   lines[:26341]
            txtFile.writelines(lines)  
            txtFile.truncate()
            txtFile.close()
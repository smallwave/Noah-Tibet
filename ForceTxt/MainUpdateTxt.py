##########################################################################################################
# NAME
#    MainUpdateTxt.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151231 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################

import os
import sys
import formic
sys.path.append('ForceTxt')
from UpdateForceTxt import cForceTxtUpdate
###################################################################################
# Main Test
###################################################################################
if __name__ == '__main__':

    strtxtForcePath = "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(TXT)\\"
    strncResPath    = "E:\\worktemp\\Permafrost(MAPPING)\\XIKUNLUN(NC)\\"
    #1 run model
    fileset = formic.FileSet(include="**/*.txt", directory= strtxtForcePath)
    nFile   = 0 # print process file ID
    for file_name in fileset:
        nFile+=1
        print "################################################################"
        print "Current file is : " + file_name + "; It is the " + str(nFile)
        print "################################################################"
        # update output path
        forceTxtUpdate  =  cForceTxtUpdate(file_name)
        forceTxtUpdate.updateOutput(strncResPath)
        # update temp

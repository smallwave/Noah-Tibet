##########################################################################################################
# NAME
#    MainPermafrostChange.py
# PURPOSE
#    MainCalALT program

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20160912 -- Initial version created and posted online
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

    selType      =  1
    batRunModel  =  cBatchCells()
    #1 permafrost change
    if selType == 1:
        iStartTime      =  1983
        iEndTime        =  2013
        strncPath       =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(NC5000)\\"
        strOutputTxt    =  "F:\\worktemp\\Permafrost(Change)\\Work\\QTP(RES)\\PermafrostMapChange5000.txt"
        batRunModel.RunCalPermafrostChange(strncPath,strOutputTxt,iStartTime,iEndTime)




##########################################################################################################
# NAME
#    MainPaperPlot.py
# PURPOSE
#    MainCalALT program

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20160921 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import sys
import datetime 
import shapefile

#Main code
if __name__ == '__main__':
       
    #update 1 update soil veg and lon lat
    sfPoint   = shapefile.Reader("F:/worktemp/Permafrost(Change)/Work/Res/PermafrostChange.shp")
    #Batch
    shapeRecs = sfPoint.shapeRecords()
    nPoint    = len(shapeRecs)
    for i in range(0,nPoint):
        #update 1 veg soil 
        shapeRec           =   shapeRecs[i].record

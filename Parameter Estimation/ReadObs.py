##########################################################################################################
# NAME
#    MainCompare.py
# PURPOSE
#   
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151031 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import xlrd
import os

class ReadObsData(object):
    """description of class"""
    def __init__(self,strexcelFilePath):
        self.strxlsDataPath    =  strexcelFilePath;
    # get request input number layer, dataName
    def getObsData(self,nLayer):
        try:
            file_name   = self.strxlsDataPath
            if not os.path.exists(file_name):
                print "Error there have no " + file_name
                os.system("pause")
                exit(0)
            tableIndex    =  0
            colIndex      =  0 
            data  =  xlrd.open_workbook(file_name)
            table =  data.sheets()[tableIndex]
            nrows =  table.nrows   # 
            ncols =  table.ncols   # 
            listRow =[]
            for rownum in range(1,nrows):
                row = table.row_values(rownum)
                if row:
                    listRow.append(row)
            listCol = zip(*listRow)
            return list(listCol[nLayer]) 
        except Exception,e:
            print str(e)

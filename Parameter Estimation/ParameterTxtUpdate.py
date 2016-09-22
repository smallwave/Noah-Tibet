##########################################################################################################
# NAME
#    parameterTxtUpdate.py
# PURPOSE
#    using update soil and veg parameter before model ru
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151011 -- Initial version created and posted online
#    20151028 -- update  updateSoilParameterFile
# REFERENCES
##########################################################################################################
import linecache

class ParameterUpdate(object):
    """description of class"""
    def __init__(self,optParmType,strsoilFilePath):
        self.strsoilFilePath    =  strsoilFilePath;
        if(optParmType == 1):
            self.soilParaList   =  ["BB","DRYSMC","F11","MAXSMC",
                                    "REFSMC","SATPSI","SATDK","SATDW",
                                    "WLTSMC","QTZ"] 
        if(optParmType == 2):
            self.soilParaList   =  ["SBETA_DATA","FXEXP_DATA","REFKDT_DATA","FRZK_DATA"] 

        self.optParmType        = optParmType
    # replace txtfile
    def replace_line(self,lineTxt,dictPara):
        lineTxts       = lineTxt.split(',')
        lineTxtTemp    = map(float,lineTxts[1:11])
        lineTxts[1:11] = lineTxtTemp
        for key in dictPara.keys():
            index = self.soilParaList.index(key)
            sKey  = dictPara[key]
            lineTxts[index+1] = sKey
        newLine  = '{},{:9.2f},{:9.3f},{:10.3f},{:8.3f},{:8.3f},{:8.3f},{:9.2e},{:10.3e},{:8.3f},{:6.2f},{}'\
            .format(lineTxts[0],lineTxts[1],lineTxts[2],lineTxts[3],lineTxts[4],lineTxts[5],lineTxts[6],lineTxts[7],\
                    lineTxts[8],lineTxts[9],lineTxts[10],lineTxts[11])
        return newLine
    # update txtfile        
    def updateSoilParameterFile(self,dictPara,soilType):
        # get array of lines
        with open(self.strsoilFilePath, 'r+') as soilTxtFile:
            lines                 =  soilTxtFile.readlines()
            updatenLine           =  soilType + 3
            #... Perform whatever replacement you'd like on lines
            lineTxt               =  linecache.getline(self.strsoilFilePath, updatenLine)
            newLine               =  self.replace_line(lineTxt,dictPara)
            lines[updatenLine -1] = newLine
            soilTxtFile.seek(0)
            soilTxtFile.writelines(lines)

    def updateGeneralParameterFile(self,dictPara):
        # get array of lines
        with open(self.strsoilFilePath, 'r+') as soilTxtFile:
            lines                 =  soilTxtFile.readlines()
            for key in dictPara.keys():
                index  = self.soilParaList.index(key)
                sKey   = dictPara[key]
                strOut = str(sKey) +"\n"
                if(index == 0):   # SBETA_DATA
                    lines[13] = strOut
                elif(index == 1): # FXEXP_DATA
                    lines[15] = strOut
                elif(index == 2): # REFKDT_DATA
                    lines[23] = strOut
                elif(index == 3): # FRZK_DATA
                    lines[25] = strOut

            #... Perform whatever replacement you'd like on lines
            soilTxtFile.seek(0)
            soilTxtFile.writelines(lines)
            

    def updateParameterFile(self,dictPara,soilType = None):
        if(self.optParmType == 1):
            self.updateSoilParameterFile(dictPara,soilType)
        if(self.optParmType == 2):
            self.updateGeneralParameterFile(dictPara)


           



            
           
  
 
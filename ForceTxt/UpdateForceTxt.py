##########################################################################################################
# NAME
#    UpdateForceTxt.py
# PURPOSE
#   UpdateForceTxt
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20151231 -- Initial version created and posted online
# REFERENCES
##########################################################################################################
import linecache
class cForceTxtUpdate(object):
    """description of class"""
    def __init__(self,strtxtFilePathIn):
        self.strtxtFilePath    =  strtxtFilePathIn;
    # replace txtfile
    def replace_outputPath(self,output_dir):
        newLine   = ' output_dir            = "{}"\n'.format(output_dir)
        return newLine
    # update txtfile        
    def updateOutput(self,strOutputDir):
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... updateOutputDirLine
            updateLine            =  5   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            newLine               =  self.replace_outputPath(strOutputDir)
            lines[updateLine -1]  = newLine
            #... deepSoilTemperature
            updateLine            =  20   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            lineTxts              =  lineTxt.split('=')
            lineTxtTemp           =  float(lineTxts[1]) + 273.15
            newLine               =  ' Deep_Soil_Temperature = {}\n'.format(lineTxtTemp) 
            lines[updateLine -1]  =  newLine

            txtFile.seek(0)
            txtFile.writelines(lines)
    def updateSkinTemp(self,skintemp): 
        # get array of lines
        with open(self.strtxtFilePath, 'r+') as txtFile:
            lines                 =  txtFile.readlines()
            #... deepSoilTemperature
            updateLine            =  16   # from 1 ~  not 0
            lineTxt               =  linecache.getline(self.strtxtFilePath, updateLine)
            newLine               =  ' Skin_Temperature      = {}\n'.format(skintemp) 
            lines[updateLine -1]  =  newLine

            txtFile.seek(0)
            txtFile.writelines(lines)  

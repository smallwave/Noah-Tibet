##########################################################################################################
# NAME
#    UnZIP.py
# PURPOSE
#   
#
# PROGRAMMER(S)
#   wuxb
# REVISION HISTORY
#    20150908 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import subprocess
import glob 
import os
strInputPath      = "E:\\Pres\\"
strMatchSuffix    = "*.gz"
strOutputPath     = "E:\\Pres(UNZIP)\\"

for filename in glob.glob(strInputPath + strMatchSuffix): 
    gzFilePath   = filename
    command      = '7z e '+gzFilePath+' -o'+strOutputPath
    if not os.path.exists(strOutputPath):
        os.makedirs(strOutputPath)
    subprocess.call(command, shell=True)  #call 7z command

    







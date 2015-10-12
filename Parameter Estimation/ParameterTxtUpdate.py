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
#
# REFERENCES
##########################################################################################################


class parameterUpdate(object):
    """description of class"""
    def __init__(self,strsoilFilePath):
        self.strsoilFilePath    =  strsoilFilePath;
    def updateSoilParameterFile(self,updateSTNum,**dictupdatePara):
        with open(self.strsoilFilePath , "r+") as text_file:
               
               text_file.write(' startdate             = "{}"\n'.format(sForceTxt.startdate.strftime("%Y%m%d%H%M")))
               text_file.write(' enddate               = "{}"\n'.format(sForceTxt.enddate.strftime("%Y%m%d%H%M")))
               text_file.write(' loop_for_a_while      = {}\n'.format(sForceTxt.loop_for_a_while))
               text_file.write(' output_dir            = "{}"\n'.format(sForceTxt.output_dir))
               text_file.write(' Latitude              = {}\n'.format(sForceTxt.Latitude))
               text_file.write(' Longitude             = {}\n'.format(sForceTxt.Longitude))
               text_file.write(' Forcing_Timestep      = {}\n'.format(sForceTxt.Forcing_Timestep))
               text_file.write(' Noahlsm_Timestep      = {}\n'.format(sForceTxt.Noahlsm_Timestep))





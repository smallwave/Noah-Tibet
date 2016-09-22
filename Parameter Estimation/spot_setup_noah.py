##########################################################################################################
# NAME
#    spot_setup_noah.py
# PURPOSE
#    parameters sensitivity and estimation

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151007   -- Initial version created and posted online
#    20160725   -- Add optParmType
# REFERENCES
##########################################################################################################

import numpy as np
import spotpy
from datetime import datetime
import subprocess
import os
import sys
from ParameterTxtUpdate import ParameterUpdate
from ReadObs import ReadObsData
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess

##################################################################################### 
# 
##################################################################################### 
class spot_setup(object):
    """description of class"""
    def __init__(self,nalyer = None,soilType = None,peType = None,optParmType = None, varTimeDataArray = None):
        analysestart   = datetime(2007,4,1)
        analysesend    = datetime(2009,12,31)
        if nalyer is None:
            nalyer   = 2
        if soilType is None:
            soilType = 3
        if peType is None:
            peType = "STC"
        if optParmType is None:
            optParmType = 1
        self.optParmType    = optParmType   # suggest parameter type    # general parm   20160725
        self.noahmodel = NoahModel(analysestart,analysesend,nalyer,soilType,peType,optParmType,varTimeDataArray)
    def parameters(self):
        pars = []   #distribution of random value    #name  #stepsize# optguess
        if(self.optParmType == 1):
            #pars.append((np.random.uniform(low=0.5,high=2.5),         'BB',      0.01,  1.58))  
            #pars.append((np.random.uniform(low=0.00,high=0.1),       'DRYSMC',  0.001, 0.006)) 
            #pars.append((np.random.uniform(low=0.18,high= 0.38),      'MAXSMC',  0.01,  0.262)) 
            #pars.append((np.random.uniform(low=0.00,high=0.35),      'REFSMC',  0.01,  0.17)) 
            #pars.append((np.random.uniform(low=0.00,high=0.9),       'SATPSI',  0.001,  0.009)) 
            pars.append((np.random.uniform(low=0.5E-6,high=1.6E-4),     'SATDK',   0.11E-5,  1.19E-4)) 
            #pars.append((np.random.uniform(low=0.1E-3,high=0.9E-5),     'SATDW',   0.405E-6, 0.509E-4)) 
            #pars.append((np.random.uniform(low=0.00,high=0.1),       'WLTSMC',  0.001, 0.006)) 
            #pars.append((np.random.uniform(low=0.10,high=0.99),       'QTZ',     0.01,  0.95))  
        if(self.optParmType  == 2):   # general parm   20160725
            pars.append((np.random.uniform(low=-4,high=-1),     'SBETA_DATA',   0.1,  -2)) 
            pars.append((np.random.uniform(low=0.2,high=4),     'FXEXP_DATA',   0.1,  2)) 
            pars.append((np.random.uniform(low=0.5,high=5),     'REFKDT_DATA',   0.1,  3)) 
            pars.append((np.random.uniform(low=0.1,high=0.25),   'FRZK_DATA',   0.01,  0.15)) 


        dtype=np.dtype([('random', '<f8'), ('name', '|S30'),('step', '<f8'),('optguess', '<f8')])
        return np.array(pars,dtype=dtype)
            
    def simulation(self,vector):
        dictPara = {}
        if(self.optParmType == 1):
            dictPara    = {"SATDK":vector[0]}
            #dictPara    = {"BB":vector[0],"DRYSMC":vector[1],"REFSMC":vector[2],"SATPSI":vector[3],"SATDK":vector[4],  \
            #               "SATDW":vector[5],"WLTSMC":vector[6]}
            #dictPara    = {"BB":vector[0],"MAXSMC":vector[1],"SATPSI":vector[2],"SATDK":vector[3],"SATDW":vector[4]}
            #dictPara    = {"QTZ":vector[0]}
        if(self.optParmType == 2):
            dictPara    = {"SBETA_DATA":vector[0],"FXEXP_DATA":vector[1],"REFKDT_DATA":vector[2],"FRZK_DATA":vector[3]}

        simulations = self.noahmodel._run(dictPara)

        return simulations
 
    def evaluation(self):
        observations= self.noahmodel.observations
        return observations

    def objectivefunction(self,simulation,evaluation):
        objectivefunction= -spotpy.objectivefunctions.rmse(simulation,evaluation)
        return objectivefunction
##################################################################################### 
# 
##################################################################################### 
class NoahModel(object):
    '''
    Input: datastart:    e.g. datetime(1998,6,1)
           dataend:      e.g. datetime(2000,1,1)
           analysestart: e.g. datetime(1999,1,1)
    Output: Initialised model instance with forcing data (climate) and evaluation data (soil temperature)
    '''
    def __init__(self,analysestart,analysesend,nlayer,soilType,peType,optParmType,varTimeDataArray):
        self.analysestart     = analysestart
        self.analysesend      = analysesend
        self.nlayer           = nlayer
        self.soilType         = soilType
        self.peType           = peType
        self.optParmType      = optParmType
        self.varTimeDataArray = varTimeDataArray
        ###########################################################################
        #
        ###################### Init ####################################  
        if(self.optParmType == 1): 
            self.paraUpdate    =  ParameterUpdate(optParmType,"D:\\worktemp\\Permafrost(NOAH)\\Data\\Run(S)\\SOILPARM.TBL")
        if(self.optParmType == 2):   # general parm   20160725
            self.paraUpdate    =  ParameterUpdate(optParmType,"F:\\worktemp\\Permafrost(Change)\\Run(S)\\GENPARM.TBL")

        self.ncFileProcess =  NcFileProcess("F:\\worktemp\\Permafrost(Change)\\Run(S)\\TGLCH.nc");
        ###########################################################################
        #
        ###################### Evaluation data ####################################    
        #just for test
        readObsData        =  ReadObsData("F:\\worktemp\\Permafrost(Change)\\Run(S)\\TGLData2009.xls");
        if (peType == "STC"):
            getnlayer          =  self.nlayer - 1
            obsDataRes         =  readObsData.getObsData(getnlayer)
            obsDataRes         =  map(lambda x:x-273.15,obsDataRes)
        if (peType == "SH2O"):
            getnlayer          =  self.nlayer + 21
            obsDataRes         =  readObsData.getObsData(getnlayer)
            obsDataRes         =  map(lambda x:x*100,obsDataRes)


        self.observations  =  obsDataRes
        ###########################################################################


    def _run(self,dictPara):
        #return alpha,n,porosity,ksat
        '''
        Runs the model instance
        
        Input: Parameter set (in this case VAN-Genuchten Parameter alpha,n,porosity,ksat)
        Output: Simulated values on given observation days
        ''' 
        #NOTE: SATDW = BB*SATDK*(SATPSI/MAXSMC)
        #F11 = ALOG10(SATPSI) + BB*ALOG10(MAXSMC) + 2.0
        #REFSMC1=MAXSMC*(5.79E-9/SATDK)**(1/(2*BB+3)) 5.79E-9 m/s= 0.5 mm
        #REFSMC=REFSMC1+1./3.(MAXSMC-REFSMC1)
        #WLTSMC1=MAXSMC*(200./SATPSI)**(-1./BB)    (Wetzel and Chang, 198
        #WLTSMC=WLTSMC1-0.5*WLTSMC1

        #1 update  SOILPARM.TBL or Other
        self.paraUpdate.updateParameterFile(dictPara,self.soilType)

        ##2 run model
        os.chdir('F:\\worktemp\\Permafrost(Change)\\Run(S)\\')
        command       =  'simple_driver.exe TGLCH.txt'
        subprocess.call(command, shell=True)  #call 7z command
        # 3 get model res return
        getnlayer     =   self.nlayer - 1
        modelRes      =   self.ncFileProcess.getNcDataByDay(self.peType,
                                                            getnlayer,
                                                            self.varTimeDataArray,
                                                            self.analysestart,
                                                            self.analysesend)
        if (self.peType == "STC"):
            return  map(lambda x:x-273.15,modelRes)
        if (self.peType == "SH2O"):
            return  map(lambda x:x*100,modelRes)
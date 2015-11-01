﻿##########################################################################################################
# NAME
#    spot_setup_noah.py
# PURPOSE
#    parameters sensitivity and estimation

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151007 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################

import numpy as np
import spotpy
from datetime import datetime
import subprocess
import os
import sys
from parameterTxtUpdate import ParameterUpdate
from ReadObs import ReadObsData
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess

##################################################################################### 
# 
##################################################################################### 
class spot_setup(object):
    """description of class"""
    def __init__(self):
        analysestart   = datetime(2010,1,1)
        analysesend    = datetime(2010,12,31)
        self.noahmodel = NoahModel(analysestart,analysesend)
    def parameters(self):
        pars = []   #distribution of random value      #name  #stepsize# optguess
        pars.append((np.random.uniform(low=2.00,high=10.00),      'BB',      0.01,  4.52))  
        pars.append((np.random.uniform(low=0.40,high=0.90),       'QTZ',     0.01,  0.65))  
        pars.append((np.random.uniform(low=1.00E-6,high=1.00E-5), 'SATDK',   0.01,  4.12E-6)) 
        pars.append((np.random.uniform(low=0.35,high=0.55),       'MAXSMC',  0.01,  0.434)) 
        pars.append((np.random.uniform(low=0.1,high=0.65),        'SATPSI',  0.01,  0.141)) 
        dtype=np.dtype([('random', '<f8'), ('name', '|S30'),('step', '<f8'),('optguess', '<f8')])
        return np.array(pars,dtype=dtype)
            
    def simulation(self,vector):
        dictPara    = {"BB":vector[0],"QTZ":vector[1],"SATDK":vector[2],"MAXSMC":vector[3],"SATPSI":vector[4]}
        simulations = self.noahmodel._run(dictPara)
        return simulations
 
    def evaluation(self):
        observations= self.noahmodel.observations_05
        return observations

    def likelihood(self,simulation,evaluation):
        likelihood= -spotpy.likelihoods.rmse(simulation,evaluation)
        return likelihood
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
    def __init__(self,analysestart,analysesend):
        self.analysestart = analysestart
        self.analysesend  = analysesend
        ###########################################################################
        #
        ###################### Evaluation data ####################################    
        #just for test
        readObsData   =  ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGL2010TEMP.xlsx");
        obsDataRes    =  readObsData.getObsData(2)
        self.observations_05 = obsDataRes
        ###########################################################################

    def _run(self,dictPara):
        #return alpha,n,porosity,ksat
        '''
        Runs the model instance
        
        Input: Parameter set (in this case VAN-Genuchten Parameter alpha,n,porosity,ksat)
        Output: Simulated values on given observation days
        ''' 
        #1 update  SOILPARM.TBL
        paraUpdate  = ParameterUpdate("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\SOILPARM.TBL")
        soilType    = 3
        paraUpdate.updateSoilParameterFile(soilType,dictPara)

        ##2 run model
        os.chdir('E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\')
        command     = 'simple_driver.exe 91.939_33.072.txt'
        subprocess.call(command, shell=True)  #call 7z command
        # 3 get model res return
        ncFileProcess =  NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.0000.nc");
        modelRes      =  ncFileProcess.getNcData("STC",2,self.analysestart,self.analysesend)
        return  map(lambda x:x-273.15,modelRes)
##########################################################################################################
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
from ParameterTxtUpdate import ParameterUpdate
from ReadObs import ReadObsData
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess

##################################################################################### 
# 
##################################################################################### 
class spot_setup(object):
    """description of class"""
    def __init__(self,nalyer = None,soilType = None):
        analysestart   = datetime(2010,1,1)
        analysesend    = datetime(2010,12,31)
        if nalyer is None:
            nalyer   = 2
        if soilType is None:
            soilType = 3
        self.noahmodel = NoahModel(analysestart,analysesend,nalyer,soilType)
    def parameters(self):
        pars = []   #distribution of random value      #name  #stepsize# optguess
        pars.append((np.random.uniform(low=2.00,high=8.00),       'BB',      0.01,  4.52))  
        pars.append((np.random.uniform(low=0.40,high=0.90),       'QTZ',     0.01,  0.65))  
        pars.append((np.random.uniform(low=1.00E-6,high=8.00E-6), 'SATDK',   0.01,  4.12E-6)) 
        pars.append((np.random.uniform(low=0.35,high=0.55),       'MAXSMC',  0.01,  0.434)) 
        pars.append((np.random.uniform(low=0.1,high=0.65),        'SATPSI',  0.01,  0.141)) 
        dtype=np.dtype([('random', '<f8'), ('name', '|S30'),('step', '<f8'),('optguess', '<f8')])
        return np.array(pars,dtype=dtype)
            
    def simulation(self,vector):
        dictPara    = {"BB":vector[0],"QTZ":vector[1],"SATDK":vector[2],"MAXSMC":vector[3],"SATPSI":vector[4]}
        simulations = self.noahmodel._run(dictPara)
        return simulations
 
    def evaluation(self):
        observations= self.noahmodel.observations
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
    def __init__(self,analysestart,analysesend,nlayer,soilType):
        self.analysestart = analysestart
        self.analysesend  = analysesend
        self.nlayer       = nlayer
        self.soilType     = soilType
        ###########################################################################
        #
        ###################### Init ####################################   
        self.paraUpdate    =  ParameterUpdate("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\SOILPARM.TBL")
        self.ncFileProcess =  NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.nc");
        ###########################################################################
        #
        ###################### Evaluation data ####################################    
        #just for test
        readObsData        =  ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGL2010TEMP.xls");
        obsDataRes         =  readObsData.getObsData(self.nlayer)
        self.observations  =  obsDataRes
        ###########################################################################


    def _run(self,dictPara):
        #return alpha,n,porosity,ksat
        '''
        Runs the model instance
        
        Input: Parameter set (in this case VAN-Genuchten Parameter alpha,n,porosity,ksat)
        Output: Simulated values on given observation days
        ''' 
        #1 update  SOILPARM.TBL
        self.paraUpdate.updateSoilParameterFile(self.soilType,dictPara)
        ##2 run model
        os.chdir('E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\')
        command       =  'simple_driver.exe TGLCH.txt'
        subprocess.call(command, shell=True)  #call 7z command
        # 3 get model res return
        getnlayer     =   self.nlayer - 1
        modelRes      =   self.ncFileProcess.getNcDataByDay("STC",getnlayer,self.analysestart,self.analysesend)
        return  map(lambda x:x-273.15,modelRes)
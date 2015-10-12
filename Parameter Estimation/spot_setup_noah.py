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
import xlrd
import subprocess
import os
import sys
from ParameterTxtUpdate import parameterUpdate
sys.path.append('Result Process')
from NcFileResPostProcess import NcFileProcess


#
class spot_setup(object):
    """description of class"""
    def __init__(self):
        analysestart   = datetime(2010,1,1)
        analysesend    = datetime(2010,12,31)
        self.noahmodel = NoahModel(analysestart,analysesend)
    def parameters(self):
        pars = []   #distribution of random value      #name  #stepsize# optguess
        pars.append((np.random.uniform(low=2.00,high=5.00),  'BB',     0.01,  4.52))  
        pars.append((np.random.uniform(low=0.40,high=0.70),  'QTZ',    0.01,  0.65))  
        pars.append((np.random.uniform(low=2.00,high=5.00),  'SATDK',  0.01,  4.12)) 
        dtype=np.dtype([('random', '<f8'), ('name', '|S30'),('step', '<f8'),('optguess', '<f8')])
        return np.array(pars,dtype=dtype)
            
    def simulation(self,vector):
        simulations = self.noahmodel._run(pBB=vector[0],pQTZ=vector[1],pSATDK=vector[2])
        return simulations
        #x=np.array(vector)
        #simulations= [sum(100.0*(x[1:] - x[:-1]**2.0)**2.0 + (1 - x[:-1])**2.0)]
        #return simulations
 
    def evaluation(self):
        observations= self.noahmodel.observations_05
        return observations
        #observations=[0]
        #return observations

    def likelihood(self,simulation,evaluation):
        likelihood= -spotpy.likelihoods.rmse(simulation,evaluation)
        return likelihood
#
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

        ###################### Evaluation data ####################################    
        try:
            #just for test
            tableIndex    = 0
            colIndex      = 0 
            data = xlrd.open_workbook("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGL2010TEMP.xlsx")
            table = data.sheets()[tableIndex]
            nrows = table.nrows #行数
            ncols = table.ncols #列数
            listRow =[]
            for rownum in range(1,nrows):
                row = table.row_values(rownum)
                if row:
                    listRow.append(row)
            listCol = zip(*listRow)
            self.observations_05 = list(listCol[2]) 
        except Exception,e:
            print str(e)
        ###########################################################################

    def _run(self,pBB=None,pQTZ=None,pSATDK=None):
        #return alpha,n,porosity,ksat
        '''
        Runs the model instance
        
        Input: Parameter set (in this case VAN-Genuchten Parameter alpha,n,porosity,ksat)
        Output: Simulated values on given observation days
        ''' 
        #1 update  SOILPARM.TBL
        paraUpdate  = parameterUpdate("E:\\SOILPARM.TBL")
        dictPara    = {"BB":pBB,"QTZ":pQTZ,"SATDK":pSATDK}
        paraUpdate.updateSoilParameterFile(3,dictPara)

        ##2 run model
        os.chdir('E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\')
        command      = 'simple_driver.exe 91.939_33.072.txt'
        subprocess.call(command, shell=True)  #call 7z command
       
        # 3 get model res return
        ncFileProcess = NcFileProcess("E:\\worktemp\\Permafrost(NOAH)\\Data\\Run\\OUTPUT.0000.nc");
        modelRes  =  ncFileProcess.getNcData("STC",2,self.analysestart,self.analysesend)
        return  map(lambda x:x-273.15,modelRes)

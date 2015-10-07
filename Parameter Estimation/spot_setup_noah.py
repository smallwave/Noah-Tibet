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
from datetime import timedelta, datetime

#
class spot_setup(object):
    """description of class"""
    def __init__(self):
        datastart     = datetime(1998,6,1)
        dataend       = datetime(2000,1,1)
        analysestart  = datetime(1999,1,1)
        self.noahmodel = NoahModel(datastart,dataend,analysestart)

    def parameters(self):
        pars = []   #distribution of random value      #name  #stepsize# optguess
        pars.append((np.random.uniform(low=-32.768,high=32.768),  'BB',   0.02,  0.2))  
        dtype=np.dtype([('random', '<f8'), ('name', '|S30'),('step', '<f8'),('optguess', '<f8')])
        return np.array(pars,dtype=dtype)
            
    def simulation(self,vector):
        simulations= self.noahmodel._run(alpha=vector[0])
        return simulations
        
    def evaluation(self):
        observations=[.0]
        return observations

    def likelihood(self,simulation,evaluation):
        likelihood= -spotpy.likelihoods.nashsutcliff(simulation,evaluation)
        return likelihood
#
class NoahModel(object):
    '''
    Input: datastart:    e.g. datetime(1998,6,1)
           dataend:      e.g. datetime(2000,1,1)
           analysestart: e.g. datetime(1999,1,1)
    
    Output: Initialised model instance with forcing data (climate, groundwater) and evaluation data (soil moisture)
    '''
    def __init__(self,datastart,dataend,analysestart):
        self.datastart    = datastart
        self.dataend      = dataend
        self.analysestart = analysestart

        ###########################################################################
        
        ###################### Evaluation data ####################################    
        eval_soil_moisture = [1,2,3]
        self.eval_dates    = eval_soil_moisture
        self.observations  = eval_soil_moisture      
        ###########################################################################

    def _run(self,alpha=None):
        #return alpha,n,porosity,ksat
        '''
        Runs the model instance
        
        Input: Parameter set (in this case VAN-Genuchten Parameter alpha,n,porosity,ksat)
        Output: Simulated values on given observation days
        '''    
        return  alpha**2
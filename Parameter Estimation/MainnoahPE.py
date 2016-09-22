##########################################################################################################
# NAME
#    MainNoahPubPS.py
# PURPOSE
#    public parameters sensitivity and estimation main program

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151007 -- Initial version created and posted online
#    20160725 -- Update soilType eq -1  suggest general parameter
# REFERENCES
##########################################################################################################
import time 
import spotpy
from Spot_setup_noah import spot_setup
import sys
sys.path.append('GetDate')
from getNcFileDate import getSingleNcFileDate

#Main code
if __name__ == '__main__':

    # start Time
    start = time.clock()
    results=[]

    # init infomation
    rep        =   5000
    nlayer     =   10

    #if else parameter
    soilType   =   1    

    # type
    peType     =   "STC"  #SH2O  STC

    #optimal parameter type 
    optParmType = 2   #  optParmType =1 -> soil    ptParmType =2 -> general    

    #get varTimeDataArray
    getNoahDateAll    =   getSingleNcFileDate("F:\\worktemp\\Permafrost(Change)\\Run(S)\\OUTPUT(NEW).nc")
    varTimeDataArray  =   getNoahDateAll.getNcFileDate("Times","Noah")

    sampler = spotpy.algorithms.fast(spot_setup(nlayer,soilType,peType,optParmType,varTimeDataArray),  dbname='GENPARM',  dbformat='csv')

    #Create samplers for fast algorithm:
    sampler.sample(rep)
    results = sampler.getdata()
    end = time.clock()
    print "This is request:  %f s" % (end - start)


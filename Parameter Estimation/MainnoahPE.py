##########################################################################################################
# NAME
#    noahPE.py
# PURPOSE
#    parameters sensitivity and estimation main program

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151007 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################
import time 
import spotpy
from Spot_setup_noah import spot_setup
from spotpy import analyser

#Main code
if __name__ == '__main__':
    # start Time
    start = time.clock()
    results=[]

    # init infomation
    rep        =   5000
    nlayer     =   13
    soilType   =   1
    peType     =   "STC"  #SH2O  STC

    sampler = spotpy.algorithms.sceua(spot_setup(nlayer,soilType,peType),  dbname='TGLFAST2.8',  dbformat='csv')
    #Create samplers for fast algorithm:
    sampler.sample(rep)
    results = sampler.getdata()
    end = time.clock()
    print "This is request:  %f s" % (end - start)
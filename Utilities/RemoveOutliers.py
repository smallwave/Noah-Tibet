##########################################################################################################
# NAME
#    RemoveOutliers.py
# PURPOSE
#    Remove obs outliers 

# PROGRAMMER(S)
#   wuxb

# REVISION HISTORY
#    20151206 -- Initial version created and posted online
#
# REFERENCES
##########################################################################################################

import numpy as np
sys.path.append('Parameter Estimation')
from ReadObs import ReadObsData

def remove_outliers_bis(arr, k):
    mask = np.ones((arr.shape[0],), dtype=np.bool)
    mu, sigma = np.mean(arr, axis=0), np.std(arr, axis=0, ddof=1)
    for j in range(arr.shape[1]):
        col = arr[:, j]
        mask[mask] &= np.abs((col[mask] - mu[j]) / sigma[j]) < k
    return arr[mask]

def reject_outliers1(data, m = 2.):
    d = np.abs(data - np.median(data))
    mdev = np.median(d)
    s = d/mdev if mdev else 0.
    return data[s<m]

def reject_outliers2(data, m=2):
    return data[abs(data - np.mean(data)) < m * np.std(data)]

def remove_outliers3(arr, k):
    mu, sigma = np.mean(arr, axis=0), np.std(arr, axis=0, ddof=1)
    return arr[np.all(np.abs((arr - mu) / sigma) < k, axis=1)]


#Main code
if __name__ == '__main__':

    readObsData = ReadObsData("E:\\worktemp\\Permafrost(NOAH)\\Data\\TGLData2009.xls")
    obsDataRes = readObsData.getObsData(nlayer)
from optimparallel import minimize_parallel
from pca import *
from readply import *
from main import toTuple
import numpy as np
import pandas as pd
import time
from scipy.optimize import minimize

leftLineIdxs, rightLineIdxs = [1042, 1053, 1073, 1074, 1083, 1098, 1118, 1119, 1139, 1140, 1143, 1589, 1632, 1845, 1853, 1965, 1989, 2010, 2011, 2707, 2709, 2782, 2783, 2853, 2897, 2902, 2904, 2915, 2916, 3045, 3076, 3128, 3202, 3203, 3252, 3253, 3267, 3328, 3341], [20, 22, 37, 38, 40, 46, 59, 67, 69, 81, 109, 110, 115, 119, 337, 338, 343, 613, 834, 835, 864, 1005, 1030, 2039, 2121, 2122, 2198, 2226, 2246, 2247, 2249, 2487, 2488, 2489, 2517, 2579, 2580, 2646]
eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
mean = read_matrix_from_hdf5('mean.h5')

df_lines = pd.read_csv('lines.txt', sep=' ', header=None)

eigenValuesAugmentation_fit = [37.47394805, -49.07828283,  -0.6562043,  -24.62020633, -27.13628352, 6.57057748, -11.42703975, -18.79096601, -10.54424185, 3.44637848, -12.89579981, -7.87242574, -13.9092693, 2.27681137, -7.3060829, -7.73122333, -4.43121648, 5.80548907, 10.15422231, 14.24570948, -17.25150115, 0.97727416, -3.08962112, 5.8461985, 6.87403008, -3.17929581, 1.36895233, -0.74191196, -0.60536829, 5.94243889]

class Minimizer():
    def __init__(self, x0, line, baseParams):
        self.x0 = x0
        self.line = line
        self.baseParams = baseParams
        
    def fun(self, x):
        self.baseParams[1] = x[0]
        self.baseParams[2] = x[1]
        self.baseParams[3] = x[2]
        self.baseParams[4] = x[3]
        self.baseParams[5] = x[4]
        self.baseParams[6] = x[5]
        self.baseParams[7] = x[6]
        model = calcSpecificModel(self.baseParams, mean, eigenVectors)
        idxs = expandIndices(rightLineIdxs)
        sum = 0
        for i in range(0,len(idxs),3):
            minDist = 100000000
            for v in self.line:
                dist = np.sqrt((model[idxs[i]] - v[0])**2 + (model[idxs[i+1]] - v[1])**2 + (model[idxs[i+2]] - v[2])**2)
                if dist < minDist:
                    minDist = dist
            sum += minDist
        return sum
    
    def run(self):
        res = minimize_parallel(self.fun, self.x0, options={'maxiter': 10})
        print('loss: ', res.fun)
        print('x: ', res.x[0], ' ', res.x[1], ' ', res.x[2])
        return res

def fun(x):
    eigenValuesAugmentation_fit[1] = x[0]
    eigenValuesAugmentation_fit[2] = x[1]
    eigenValuesAugmentation_fit[3] = x[2]
    eigenValuesAugmentation_fit[4] = x[3]
    eigenValuesAugmentation_fit[5] = x[4]
    eigenValuesAugmentation_fit[6] = x[5]
    eigenValuesAugmentation_fit[7] = x[6]
    model = calcSpecificModel(eigenValuesAugmentation_fit, mean, eigenVectors)
    idxs = expandIndices(rightLineIdxs)
    sum = 0
    global line
    for i in range(0,len(idxs),3):
                sum += np.sqrt((model[idxs[i]] - line[i])**2 + (model[idxs[i+1]] - line[i+1])**2 + (model[idxs[i+2]] - line[i+2])**2)

    return sum

x0 = [-49.07828283,  -0.6562043,  -24.62020633, -27.13628352, 6.57057748, -11.42703975, -18.79096601]

def testAll():
    for i in range(len(df_lines.values)):
        print('-------------------------------------------------')
        print('model: ', i)
        line = toTuple(df_lines.values[i])
        t = time.time()
        minobj = Minimizer(x0, line, eigenValuesAugmentation_fit)
        minobj.run()
        print('time elapsed: ', time.time() - t)

def saveToFile(list):
    f = open('modelParams.txt', 'w')
    string = ''
    for i in list:
        string += str(i) + ' '
    f.write(string)
    f.close()
    
def testOne():
    #o = minimize(fun, x0, method='Nelder-Mead', options={'maxiter': 10})
    print('-------------------------------------------------')
    line = toTuple(df_lines.values[14])
    t = time.time()
    minobj = Minimizer(x0, line, eigenValuesAugmentation_fit)
    res = minobj.run()
    saveToFile(res.x)
    print('time elapsed: ', time.time() - t)

def main():
    testOne()
        

if __name__ == '__main__':
    main()
import numpy as np
from sklearn.decomposition import PCA
from vedo import *
import readply as rp
import h5py
import threading
import pandas as pd

num_comp = 30
        

def copyList(l):
    r = []
    for i in range(len(l)):
        r.append(l[i])
    return r

def save_matrix_as_hdf5(matrix, filename):
    with h5py.File(filename, 'w') as f:
        dataset = f.create_dataset('matrix', data=matrix)
        
def read_matrix_from_hdf5(filename):
    with h5py.File(filename, 'r') as f:
        dataset = f['matrix']
        matrix = np.array(dataset)
    return matrix

def show(objFile):
    mesh = Mesh(objFile)
    mesh.rotate_x(180)
    mesh.show()
    
def getVertCoords(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    file.close()
    
    coords = []
    for i in range(len(lines)):
        if not lines[i].startswith('v '):
            continue

        line = lines[i].split(" ")
        coords.append(float(line[1]))
        coords.append(float(line[2]))
        coords.append(float(line[3].replace('\n', '')))
    return coords

def createFile(filename, verts):
    filestr = ''
    for i in range(int(len(verts)/3)):
        filestr = filestr + 'v ' + str(verts[3*i]) + ' ' + str(verts[3*i+1]) + ' '+ str(verts[3*i+2]) + '\n'

    filestrrest = ''
    file = open('objs/fitModel_Demo_Augmentation.obj', 'r')
    lines = file.readlines()
    idx = 0
    for i in range(len(lines)):
        if(not lines[i].startswith('v ')):
            filestrrest = filestrrest + lines[i]
    file.close()

    file = open(filename, 'w')
    file.write(filestr + filestrrest)
    file.close()

def calcSpecificModel(eigenValues, mean, eigenVectors):
    U_k = eigenVectors[:, 0:30]
    x_redBase = copyList(eigenValues)
    x_red = copyList(eigenValues)
    basePCAmodel = (np.dot(U_k, x_redBase) + mean).real
    adjustedModel = (np.dot(U_k, x_red) + mean).real
    cutoff = 5
    indices = rp.getIndices('breast_indices/leftBreastIdxLargeArea.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeArea.txt')
    outline = rp.getIndices('breast_indices/leftBreastIdxLargeAreaOutline.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeAreaOutline.txt')
    indices = list(set(indices))
    dists = []
    for i in indices:
        dists.append(rp.getNearestDist(outline, adjustedModel, adjustedModel[i*3], adjustedModel[i*3+1], adjustedModel[i*3+2]))

    indices_exp = rp.expandIndices(indices)
    for i in range(len(indices_exp)):
        dist = dists[int(i/3)]
        if dist > cutoff:
            basePCAmodel[indices_exp[i]] = adjustedModel[indices_exp[i]]
        else:
            basePCAmodel[indices_exp[i]] = (dist/cutoff) * adjustedModel[indices_exp[i]] + (1-(dist/cutoff)) * basePCAmodel[indices_exp[i]]
    return basePCAmodel
    

def createModel(eigenValues):
    X = np.array(rp.getData())
    w = getVertCoords('objs/fitModel_Demo_Augmentation.obj')
    pca = PCA(num_comp)
    pca.fit(X)
    eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
    mean = pca.mean_

    save_matrix_as_hdf5(mean, 'mean.h5')
    
    U_k = eigenVectors[:, 0:num_comp]
    x_red = np.dot(U_k.T, (w - mean).T).real
    x_redBase = np.dot(U_k.T, (w - mean).T).real
    
    x_red[1] = eigenValues[0]
    x_red[2] = eigenValues[1]
    x_red[3] = eigenValues[2]
    
    cutoff = 5

    basePCAmodel = (np.dot(U_k, x_redBase) + mean).real
    adjustedModel = (np.dot(U_k, x_red) + mean).real

    indices = rp.getIndices('breast_indices/leftBreastIdxLargeArea.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeArea.txt')
    outline = rp.getIndices('breast_indices/leftBreastIdxLargeAreaOutline.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeAreaOutline.txt')
    indices = list(set(indices))
    dists = []
    for i in indices:
        dists.append(rp.getNearestDist(outline, adjustedModel, adjustedModel[i*3], adjustedModel[i*3+1], adjustedModel[i*3+2]))

    indices_exp = rp.expandIndices(indices)
    for i in range(len(indices_exp)):
        dist = dists[int(i/3)]
        if dist > cutoff:
            basePCAmodel[indices_exp[i]] = adjustedModel[indices_exp[i]]
        else:
            basePCAmodel[indices_exp[i]] = (dist/cutoff) * adjustedModel[indices_exp[i]] + (1-(dist/cutoff)) * basePCAmodel[indices_exp[i]]
    return basePCAmodel, x_redBase


if __name__ == '__main__':
    params = pd.read_csv('modelParams.txt', sep=' ', header=None).values[0]
    print(params) 
    eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
    mean = read_matrix_from_hdf5('mean.h5')
    basePCAmodel = calcSpecificModel(params, mean, eigenVectors)

    createFile('objs/w_.obj', basePCAmodel)
    #createFile('objs/mean.obj', mean)

    show('objs/w_.obj')



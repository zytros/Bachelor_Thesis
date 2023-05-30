import numpy as np
from sklearn.decomposition import PCA
from vedo import *
import readply as rp
import h5py
import threading
import seaborn as sns
import matplotlib.pyplot as plt

num_comp = 25
        

def getDifference(x, y):
    s = 0
    for i in range(int(len(x)/3)):
        s += sqrt((x[3*i] - y[3*i])**2 + (x[3*i+1] - y[3*i+1])**2 + (x[3*i+2] - y[3*i+2])**2)
    return s

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
    #mesh.rotate_y(-45)
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
    file = open('objs/fitModel_Jg.obj', 'r')
    lines = file.readlines()
    idx = 0
    for i in range(len(lines)):
        if(not lines[i].startswith('v ')):
            filestrrest = filestrrest + lines[i]
    file.close()

    file = open(filename, 'w')
    file.write(filestr + filestrrest)
    file.close()
    
X = np.array(rp.getData())
#print(X[0].shape)
w = getVertCoords('objs/fitModel_Hgcutc.obj')
pca = PCA(30)
pca.fit(X)
#eigenVectors = pca.components_
#eigenValues = pca.explained_variance_
covariance = pca.get_covariance()
#print(covariance.shape)
#eigenValues, eigenVectors = np.linalg.eig(covariance)
#save_matrix_as_hdf5(eigenVectors.real, 'eigenVectors.h5')
eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
#print(eigenVectors.shape)

#stddevs = np.sqrt(pca.explained_variance_[:30])
mean = pca.mean_
#print(mean.shape)
#np.savetxt('mean.txt', mean.real, fmt="%.12f")
#np.savetxt('stddevs.txt', stddevs, fmt="%.12f")

U_k = eigenVectors[:, 0:30]
#np.savetxt("eigVecs.csv", U_k.real, fmt="%.12f")
x_red = np.dot(U_k.T, (w - mean).T).real
print(x_red)

if False:
    x_redBase = np.dot(U_k.T, (w - mean).T).real
    #print(x_red)
    #x_red = np.zeros(num_comp)
    #x_red = np.sqrt([5740, 2518, 1634, 672, 493, 231, 180, 146, 118, 111, 111, 82, 71, 69, 60, 51, 42, 32, 28, 26, 24, 22, 20, 19, 16, 16, 14, 12, 11.8, 10])
    print('before: ', x_red[1:4])
    x_red[1] += 150
    #first component size
    #x_red[1] = 150
    #second component up/down
    #x_red[2] = 100
    #third component left/right & thin/fat
    #x_red[3] = 0

    print('after: ', x_red[1:4])
    cutoff = 5

    basePCAmodel = (np.dot(U_k, x_redBase) + mean).real
    adjustedModel = (np.dot(U_k, x_red) + mean).real

    indices = rp.getIndices('breast_indices/leftBreastIdxLargeArea.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeArea.txt')
    outline = rp.getIndices('breast_indices/leftBreastIdxLargeAreaOutline.txt') + rp.getIndices('breast_indices/rightBreastIdxLargeAreaOutline.txt')
    indices = list(set(indices))
    print('indices: ', len(indices))
    print('outline: ', len(outline))
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

    for i in range(len(w)):
        if i in indices_exp:
            continue
        else:
            w[i] = 10

    createFile('objs/w_.obj', w)
    #createFile('objs/mean.obj', mean)

    show('objs/w_.obj')



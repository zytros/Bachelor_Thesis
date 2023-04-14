import numpy as np
from sklearn.decomposition import PCA
from vedo import *
import readply as rp
import h5py
import threading

num_comp = 30
        

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
#print(X.shape)
w = getVertCoords('objs/fitModel_Demo_Augmentation.obj')
pca = PCA(num_comp)
pca.fit(X)
#eigenVectors = pca.components_
#eigenValues = pca.explained_variance_
covariance = pca.get_covariance()
#print(covariance.shape)
#eigenValues, eigenVectors = np.linalg.eig(covariance)
#save_matrix_as_hdf5(eigenVectors.real, 'eigenVectors.h5')
eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
#print(eigenVectors.shape)

stddevs = np.sqrt(pca.explained_variance_[:30])
mean = pca.mean_
#print(mean.shape)
np.savetxt('mean.txt', mean.real, fmt="%.12f")
np.savetxt('stddevs.txt', stddevs, fmt="%.12f")

U_k = eigenVectors[:, 0:num_comp]
np.savetxt("eigVecs.csv", U_k.real, fmt="%.12f")
x_red = np.dot(U_k.T, (w - mean).T).real
print(x_red)
#x_red = np.zeros(num_comp)
#x_red = np.sqrt([5740, 2518, 1634, 672, 493, 231, 180, 146, 118, 111, 111, 82, 71, 69, 60, 51, 42, 32, 28, 26, 24, 22, 20, 19, 16, 16, 14, 12, 11.8, 10])
print('before: ', x_red[1:4])
#x_red[0] = 100
#first component size
x_red[1] = 0
#second component up/down
#x_red[2] = 0
#third component left/right & thin/fat
#x_red[3] = 0

print('after: ', x_red[1:4])

redModel = (np.dot(U_k, x_red) + mean).real

createFile('objs/w_.obj', redModel)
#createFile('objs/mean.obj', mean)

#show('objs/w_.obj')



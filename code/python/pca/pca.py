import numpy as np
from sklearn.decomposition import PCA

def readObj(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    file.close
    return lines

def getVertList(lines:str):
    verts = []
    for line in lines:
        if line.startswith('#'):
            continue
        elif line.startswith('vn'):
            continue
        elif line.startswith('vt'):
            continue
        elif line.startswith('v'):
            coords = line.split(' ')
            verts.append(float(coords[1]))
            verts.append(float(coords[2]))
            verts.append(float(coords[3].replace('\n', '')))
        else:
            continue
    return verts

def getVertListList(lines:str):
    verts = []
    for line in lines:
        if line.startswith('#'):
            continue
        elif line.startswith('vn'):
            continue
        elif line.startswith('vt'):
            continue
        elif line.startswith('v'):
            coords = line.split(' ')
            verts.append([float(coords[1]), float(coords[2]), float(coords[3].replace('\n', ''))])
        else:
            continue
    return verts
X = np.array([getVertList(readObj('objs/increasedModel_Demo_Augmentation.obj')), getVertList(readObj('objs/fitModel_Demo_Augmentation.obj')), 
              getVertList(readObj('objs/fitModel_Ctutc.obj')), getVertList(readObj('objs/fitModel_Demo_Reduction.obj')), 
              getVertList(readObj('objs/fitModel_Hgcutc.obj')), getVertList(readObj('objs/fitModel_Jg.obj')), 
              getVertList(readObj('objs/increasedModel_Ctutc.obj')), getVertList(readObj('objs/increasedModel_Demo_Reduction.obj')), 
              getVertList(readObj('objs/increasedModel_Hgcutc.obj')), getVertList(readObj('objs/increasedModel_Jg.obj'))])

x_i = np.array(getVertListList(readObj('objs/fitModel_Demo_Augmentation.obj')))
print(X.shape)
print(x_i.shape)

pca = PCA(n_components=10)
pca.fit(X)
mean = pca.mean_
print(mean.shape)
covariance = pca.get_covariance()
eigenValues, eigenVectors = np.linalg.eig(covariance)

U_k = eigenVectors[:, 0:8].dot(np.diag(np.sqrt(eigenValues[0:8])))



x_red = U_k.dot(x_i-mean)
print (U_k.shape)
np.savetxt('x_reduced.csv', eigenValues, fmt="%.12f")
#np.savetxt('eigenVectors.csv', eigenVectors, fmt="%.12f")

print(eigenValues.shape)


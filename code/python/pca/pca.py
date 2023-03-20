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

print(X.shape)
pca = PCA(n_components=9)
Y = pca.fit_transform(X)
#scoreX = pca.score_samples(X)
#ScoreY = pca.score_samples(Y)
#print('scoreX =', scoreX)
#print('scoreY =', ScoreY)
print(Y)
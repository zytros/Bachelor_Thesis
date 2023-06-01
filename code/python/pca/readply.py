import os
import numpy as np
import math

def readPly(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    file.close
    return lines

def getVertList(lines):
    verts = []
    for line in lines:
        if line.startswith('end_header'):
            continue
        elif line.startswith('element'):
            continue
        elif line.startswith('property'):
            continue
        elif line.startswith('format'):
            continue
        elif line.startswith('comment'):
            continue
        elif line.startswith('ply'):
            continue
        else:
            coords = line.split(' ')
            if len(coords) > 4:
                verts.append(float(coords[0]))
                verts.append(float(coords[1]))
                verts.append(float(coords[2].replace('\n', '')))
    return verts

def getFilenames():
    return os.listdir('plys')

def getData():
    data = []
    for file in getFilenames():
        data.append(getVertList(readPly('plys/' + file)))
    return data

def getIndices(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    file.close()
    indices = []
    for i in range(len(lines)):
        indices.append(int(lines[i].replace('\n', '')))
    indices.sort()
    return indices

def expandIndices(indices):
    result = []
    for i in indices:
        result.append(3*i)
        result.append(3*i+1)
        result.append(3*i+2)
    result.sort()
    return result

def getNearestDist(outline, baseModel, x, y, z):
    minDist = 100000000
    idx = -1
    for vert in outline:
        x_base = baseModel[vert*3]
        y_base = baseModel[vert*3+1]
        z_base = baseModel[vert*3+2]
        dist = math.sqrt((x_base - x)**2 + (y_base - y)**2 + (z_base - z)**2)
        if dist < minDist:
            minDist = dist
            idx = vert
    assert idx != -1
    return minDist

if __name__ == '__main__':
    print(getIndices('breast_indices/leftBreastIdx.txt'))
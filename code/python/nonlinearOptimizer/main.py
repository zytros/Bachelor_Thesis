import numpy as np
from readply import readPly, getVertList
from vedo import *
from pca import createFile, show, createModel
import numpy as np

def toTuple(vertlist):
    r = []
    for i in range(int(len(vertlist)/3)):
        r.append([vertlist[3*i], vertlist[3*i+1], vertlist[3*i+2]])
    return r

def getParams():
    r = []
    file = open('params.txt', 'r')
    lines = file.readlines()
    file.close()
    for i in range(len(lines)):
        line = lines[i].split(', ')
        r.append([float(line[0]), float(line[1]), float(line[2])])
    return r

def vertices_within_distance(vertices, plane_normal, distance):
    # Convert the input vertices list to a numpy array for easier manipulation
    vertices_array = np.array(vertices)
    # Calculate the distance of each vertex to the plane
    distances = np.abs(np.dot(vertices_array, plane_normal))
    # Return the vertices within the specified distance of the plane
    r = []
    for i in range(len(vertices)):
        if distances[i] <= distance:
            r.append(vertices[i])
        else:
            r.append([0, 0, 0])
        
    return r

def getLineidxs():
    return [1042, 1053, 1073, 1074, 1083, 1098, 1118, 1119, 1139, 1140, 1143, 1589, 1632, 1845, 1853, 1965, 1989, 2010, 2011, 2707, 2709, 2782, 2783, 2853, 2897, 2902, 2904, 2915, 2916, 3045, 3076, 3128, 3202, 3203, 3252, 3253, 3267, 3328, 3341], [20, 22, 37, 38, 40, 46, 59, 67, 69, 81, 109, 110, 115, 119, 337, 338, 343, 613, 834, 835, 864, 1005, 1030, 2039, 2121, 2122, 2198, 2226, 2246, 2247, 2249, 2487, 2488, 2489, 2517, 2579, 2580, 2646]

def showOnlyVertsInList(allVerts, vertList):
    r = []
    for v in allVerts:
        if v in vertList:
            r.append([v[0], v[1], -10])
        else:
            r.append([v[0], v[1], v[2]])
    return r

def idxVertinList(allVerts, vertList):
    r = []
    for i in range(len(allVerts)):
        if allVerts[i] in vertList:
            r.append(i)
    return r

def getClosestVert(verts, vert):
    closest = []
    dist = 100000
    for v in verts:
        if v[2] > 0:
            continue
        d = sqrt((v[0]-vert[0])**2 + (v[1]-vert[1])**2)
        if d < dist:
            dist = d
            closest = v
    return closest

def flatten(verts):
    r = []
    for v in verts:
        r.append(v[0])
        r.append(v[1])
        r.append(v[2])
    return r

def getLineCoords(model, idxList):
    r = []
    for i in idxList:
        r.append(model[i])
    return r

def createLines(params):
    lines = []
    for i in range(len(params)):
        model, baseX_red = createModel(params[i])
        idxLeft, idxRight = getLineidxs()
        lineLeft = getLineCoords(toTuple(model), idxRight)
        lines.append(flatten(lineLeft))
        print(i)
    return lines
        

if __name__ == '__main__':
    eigenValuesAugmentation_fit = [37.47394805, -49.07828283,  -0.6562043,  -24.62020633, -27.13628352, 6.57057748, -11.42703975, -18.79096601, -10.54424185, 3.44637848, -12.89579981, -7.87242574, -13.9092693, 2.27681137, -7.3060829, -7.73122333, -4.43121648, 5.80548907, 10.15422231, 14.24570948, -17.25150115, 0.97727416, -3.08962112, 5.8461985, 6.87403008, -3.17929581, 1.36895233, -0.74191196, -0.60536829, 5.94243889]
    params = getParams()
    model = getVertList(readPly('0016.ply'))
    x = 9.2
    z = -10
    model = toTuple(model)
    line = []
    for i in range(1500):
        line.append([x, 6 + i/100, z])
    clList = []
    for v in line:
        clList.append(getClosestVert(model, v))
    close = showOnlyVertsInList(model, clList)
    idxList = idxVertinList(model, clList)
    
    for i in range(len(model)):
       if i not in idxList:
           model[i] = [model[i][0], model[i][1], model[i][2]/2]
    
    lines = createLines(params)
    array = np.array(lines)
    #np.savetxt('lines.txt', lines, fmt="%.12f")
    
    createFile('test.obj', flatten(model))
    
    show('test.obj')
    
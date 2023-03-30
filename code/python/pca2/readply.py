import os


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



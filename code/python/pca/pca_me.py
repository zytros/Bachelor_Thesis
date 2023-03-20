import numpy as np
from vedo import *

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

mesh = Mesh('objs/test.obj')
#mesh.show()

s1 = getVertList(readObj('objs/fitModel_Ctutc.obj'))
s2 = getVertList(readObj('objs/fitModel_Demo_Augmentation.obj'))
s3 = getVertList(readObj('objs/fitModel_Demo_Reduction.obj'))
s4 = getVertList(readObj('objs/fitModel_Hgcutc.obj'))
s5 = getVertList(readObj('objs/fitModel_Jg.obj'))
s6 = getVertList(readObj('objs/increasedModel_Ctutc.obj'))
s7 = getVertList(readObj('objs/increasedModel_Demo_Augmentation.obj'))
s8 = getVertList(readObj('objs/increasedModel_Demo_Reduction.obj'))
s9 = getVertList(readObj('objs/increasedModel_Hgcutc.obj'))
s10 = getVertList(readObj('objs/increasedModel_Jg.obj'))

S = [getVertList(readObj('objs/increasedModel_Demo_Augmentation.obj')), getVertList(readObj('objs/fitModel_Demo_Augmentation.obj')), 
              getVertList(readObj('objs/fitModel_Ctutc.obj')), getVertList(readObj('objs/fitModel_Demo_Reduction.obj')), 
              getVertList(readObj('objs/fitModel_Hgcutc.obj')), getVertList(readObj('objs/fitModel_Jg.obj')), 
              getVertList(readObj('objs/increasedModel_Ctutc.obj')), getVertList(readObj('objs/increasedModel_Demo_Reduction.obj')), 
              getVertList(readObj('objs/increasedModel_Hgcutc.obj')), getVertList(readObj('objs/increasedModel_Jg.obj'))]
Sbar = []
for i in s1:
    Sbar.append(0.0)
for i in range(len(S)):
    for j in range(len(S[0])):
        Sbar[j] += S[i][j]
for i in range(len(Sbar)):
    Sbar[i] = Sbar[i]/float(len(S))
    
Sbar = np.array(Sbar)

sig = np.zeros(shape=(len(Sbar), len(Sbar)))

file = open('objs/mat.txt', 'w')
file.write(str(sig))
file.close()
for i in range(len(S)):
    xi = np.array(S[i])
    v = np.subtract(xi, Sbar)
    loc = np.outer(v,v)
    #print(loc.shape, sig.shape)
    sig = np.add(sig, loc)
    
sig = sig * (1/(len(Sbar)-1))
    
u, l = np.linalg.eig(sig)

print(u.shape, l.shape)

filestr = ''
for i in range(int(len(Sbar)/3)):
    filestr = filestr + 'v ' + str(Sbar[3*i]) + ' ' + str(Sbar[3*i+1]) + ' '+ str(Sbar[3*i+2]) + '\n'

filestrrest = ''
file = open('objs/fitModel_Jg.obj', 'r')
lines = file.readlines()
idx = 0
for i in range(len(lines)):
    if(not lines[i].startswith('v ')):
        filestrrest = filestrrest + lines[i]
file.close()

file = open('objs/test.obj', 'w')
file.write(filestr + filestrrest)
file.close()

#mesh2 = Mesh('objs/test.obj')
#mesh2.show()

print(Sbar.shape)
print(Sbar)

with open('objs/mat_u.txt','wb') as f:

    np.savetxt(f, u, fmt='%.5f')
        
with open('objs/mat_l.txt','wb') as f:
    for line in l:
        np.savetxt(f, line, fmt='%.5f')




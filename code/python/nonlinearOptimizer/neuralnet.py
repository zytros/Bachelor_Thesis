import torch
import numpy as np
import pandas as pd
import torch.nn as nn
import torch.nn.functional as F
from pca import *
from main import getLineidxs
from readply import expandIndices, getIndices, getNearestDist

def calcSpecificModel(eigenValues, mean, eigenVectors):
    U_k = eigenVectors[:, 0:30]
    x_redBase = copyList(eigenValues)
    x_red = copyList(eigenValues)
    print('eigenvalues shape:' , np.array(eigenValues).shape)
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

def copyList(l):
    r = []
    for i in range(len(l)):
        r.append(l[i])
    return r

df_lines = pd.read_csv('lines.txt', sep=' ', header=None)
df_params = pd.read_csv('params.txt', sep=' ', header=None)
eigenVectors = read_matrix_from_hdf5('eigenVectors.h5')
mean = read_matrix_from_hdf5('mean.h5')
leftLineIdxs, rightLineIdxs = getLineidxs()

eigenValuesAugmentation_fit = [37.47394805, -49.07828283,  -0.6562043,  -24.62020633, -27.13628352, 6.57057748, -11.42703975, -18.79096601, -10.54424185, 3.44637848, -12.89579981, -7.87242574, -13.9092693, 2.27681137, -7.3060829, -7.73122333, -4.43121648, 5.80548907, 10.15422231, 14.24570948, -17.25150115, 0.97727416, -3.08962112, 5.8461985, 6.87403008, -3.17929581, 1.36895233, -0.74191196, -0.60536829, 5.94243889]
for i in range(30):
    df_lines[114+i] = [eigenValuesAugmentation_fit[i]] * len(df_lines)
train_data = df_lines.sample(frac=0.8,random_state=200)
test_data = df_lines.drop(train_data.index)
x_train = train_data
y_train = train_data.iloc[:, 0:114]
x_test = test_data
y_test = test_data.iloc[:, 0:114]

x_train = torch.FloatTensor(x_train.values)
x_test = torch.FloatTensor(x_test.values)
y_train = torch.LongTensor(y_train.values)
y_test = torch.LongTensor(y_test.values)

print(x_train.shape)

class Model(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(144, 128)
        self.fc2 = nn.Linear(128, 128)
        self.fc3 = nn.Linear(128, 128)
        self.fc4 = nn.Linear(128, 64)
        self.fc5 = nn.Linear(64, 32)
        self.out = nn.Linear(32, 30)
        
    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = F.relu(self.fc3(x))
        x = F.relu(self.fc4(x))
        x = F.relu(self.fc5(x))
        return self.out(x)

class CustomLoss(nn.Module):
    def __init__(self):
        super().__init__()
        
    def forward(self, output, target):
        num = output.shape[0]
        print(num)
        sums = []
        for i in range(num):
            nnOut = output.detach().numpy()[i,:]
            tensTarget = target.detach().numpy()[i,:]
            print('tenstarget shape: ', tensTarget.shape)
            model = calcSpecificModel(nnOut, mean, eigenVectors)
            idxs = rightLineIdxs
            sum = 0
            for i in range(0,len(idxs),3):
                print(i)
                sum += np.sqrt((model[idxs[i]] - tensTarget[i])**2 + (model[idxs[i+1]] - tensTarget[i])**2 + (model[idxs[i+2]] - tensTarget[i])**2)
            sums.append(sum)
        return torch.tensor(sums)
    
myModel = Model()
print(myModel)


with torch.no_grad():
    myModel.eval()
    y_pred = myModel.forward(x_test)

critereon = CustomLoss()
optimizer = torch.optim.Adam(myModel.parameters(), lr=0.01)


epochs = 100
losses = []

for i in range(epochs):
    y_pred = myModel.forward(x_train)
    print(y_pred.shape)
    print(y_train.shape)
    loss = critereon(y_pred, y_train)
    losses.append(loss)
    print(f'epoch: {i:2}  loss: {loss.item():10.8f}')
    
    optimizer.zero_grad()
    loss.backward()
    optimizer.step()
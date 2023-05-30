import seaborn as sns

data = [(0.620200, 258), (0.290000, 64),(0.698700, 310),(0.623000, 265),(0.211901, 19),(0.507099, 197),(0.848200, 408),(0.700600, 311),(0.945600, 459),(0.752700, 340),(0.476400, 172),(0.983600, 479),(0.466800, 167),(0.382100, 123)]
print(len(data))
length = []
time = []

for i in range(len(data)):
    length.append(data[i][1])
    time.append(data[i][0])
    
plot = sns.regplot(x=length, y=time)
fig = plot.get_figure()
fig.savefig("plot_newtonMethod_line_len.png")

data.sort(key=lambda x: x[0])
l = []
for i in range(len(data)):
    l.append((data[i][1], data[i][0]))
print(str(l))
from flask import Flask

file = open('objs/fitModel_Ctutc.obj', 'r')
obj = file.read()
file.close()
file = open('objs/fitModel_Ctutc.mtl', 'r')
mtl = file.read()
file.close()

app = Flask(__name__)

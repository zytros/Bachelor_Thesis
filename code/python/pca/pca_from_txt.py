import pandas as pd
import numpy as np
from vedo import *


mesh = Mesh('objs/w_.obj')
mesh.rotate_x(180)
mesh.show()
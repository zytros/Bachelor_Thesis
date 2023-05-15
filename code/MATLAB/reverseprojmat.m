syms x y z u v c00 c01 c02 c03 c10 c11 c12 c13 c20 c21 c22 c23 a
eqn1 = u == x*c00 + y*c01 + z*c02 + c03;
eqn2 = v == x*c10 + y*c11 + z*c12 + c13;
eqn3 = 1 == x*c20 + y*c21 + z*c22 + c23;
sol = solve([eqn1, eqn2, eqn3], [x,y,z,a]);
xSol = sol.x;
ySol = sol.y;
zSol = sol.z;
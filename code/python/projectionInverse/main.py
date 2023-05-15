import numpy as np

proj_mat = np.array([[0.1561419131231564, 0, 0, 0],
                     [0, -0.2970006669273432, -3.6372091609720005e-17, 5.196152422706632],
                     [0, -2.1003637189268685e-17, 0.1715077131128113, 9.801980198019804],
                     [0, -2.0999436881861573e-17, 0.171473415, 10]])

def project_points_inverse(projection_matrix, points_3d):
    inv = np.linalg.inv(projection_matrix)
    points_3d = np.dot(inv, points_3d)
    return points_3d


def main():
    inv = np.linalg.inv(proj_mat)
    homo_points = [0.5, 0.5, 0.5, 1]
    world_points = project_points_inverse(proj_mat, homo_points)
    w = world_points[3]
    coordinates = [world_points[0]/w, world_points[1]/w, world_points[2]/w]
    print(coordinates)
    print(proj_mat[3,1] + proj_mat[3,2] + proj_mat[3,3])
    print(inv)

if __name__ == '__main__':
    main()
    
#[0] 0.1561419131231564,0,0,0
#[1] 0,-0.2970006669273432,-3.6372091609720005e-17,5.196152422706632
#[2] 0,-2.1003637189268685e-17,0.1715077131128113,9.801980198019804
#[3] 0,-2.0999436881861573e-17,0.171473415,10
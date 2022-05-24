cython: language_level=3
cimport cython

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
cimport numpy as np

matplotlib.use('Agg')

# Set the colormap
plt.rcParams['image.cmap'] = 'BrBG'

ctypedef np.double_t DTYPE_t
@cython.cdivision(True)
cdef void evolve(np.ndarray[DTYPE_t, ndim=2] u, np.ndarray[DTYPE_t, ndim=2] u_previous, double a, double dt, double dx2, double dy2):
    """Explicit time evolution.
    u:            new temperature field
    u_previous:   previous field
    a:            diffusion constant
    dt:           time step. """

    cdef int i, j, m, n

    n = u.shape[0]
    m = u.shape[1]


    # print(type(n))

    for i in range(1, n-1):
        for j in range(1, m-1):
            u[i, j] = u_previous[i, j] + a * dt * (
                (u_previous[i+1, j] - 2*u_previous[i, j] +
                u_previous[i-1, j]) / dx2 +
                (u_previous[i, j+1] - 2*u_previous[i, j] +
                u_previous[i, j-1]) / dy2)
    u_previous[:] = u[:]

@cython.cdivision(True)
def iterate(np.ndarray[DTYPE_t, ndim=2] field,np.ndarray[DTYPE_t, ndim=2]  field0, double a, double dx, double dy, int timesteps, image_interval):
    """Run fixed number of time steps of heat equation"""
    # print(type(a))
    cdef double dx2, dy2, dt
    cdef int m

    dx2 = dx**2
    dy2 = dy**2

    # For stability, this is the largest interval possible
    # for the size of the time-step:
    dt = dx2*dy2 / (2*a*(dx2+dy2))

    for m in range(1, timesteps+1):
        evolve(field, field0, a, dt, dx2, dy2)
        if m % image_interval == 0:
            write_field(field, m)


def init_fields(str filename):
    # Read the initial temperature field from file
    cdef np.ndarray[DTYPE_t, ndim=2] field, field0
    field = np.loadtxt(filename)
    field0 = field.copy()  # Array for field of previous time step
    return field, field0


def write_field(np.ndarray[DTYPE_t, ndim=2] field, step):
    plt.gca().clear()
    plt.imshow(field)
    plt.axis('off')
    plt.savefig('heat_{0:03d}.png'.format(step))

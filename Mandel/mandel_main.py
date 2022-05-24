import numpy as np
import matplotlib.pyplot as plt
import sys
import os
from mandel import compute_mandel as compute_mandel_py
try:
    from Mandel_py import compute_mandel as compute_mandel_cyt
except ImportError:
    pass

def plot_mandel(mandel):
    plt.imshow(mandel)
    plt.axis('off')
    plt.show()

def main(version='py',n=200,filename='py_results.txt'):
    header ='Size, time (s)'
    if os.stat(filename).st_size == 0:
        with open(filename, 'a') as file:
            file.write(f'{header}\n')

    kwargs = dict(cr=0.285, ci=0.01,
          N=n,
                  bound=1.5)

    # choose pure Python or Cython version
    if version == 'py':
        mandel_func = compute_mandel_py
    elif version == 'cyt': 
        try:
            mandel_func = compute_mandel_cyt
        except NameError as ex:
            raise RuntimeError("Cython extension missing") from ex
    else:
        raise RuntimeError("Unknown version")

    mandel_set, runtime = mandel_func(**kwargs)

    with open(filename, 'a') as file:
        file.write(f'{n},{runtime}\n')

    return mandel_set, runtime
    
if __name__ == '__main__':

    Versions = ['py','cyt']
    N = [200,400,600,800,1000]
    for version in Versions:
        if version == 'py':
            print("Using pure Python")
            filename = f'{version}_results.txt'
        elif version == 'cyt': 
            print("Using Cython")
            filename = f'{version}_results.txt'
        for n in N:
            mandel_set, runtime = main(version,n,filename)
            print('Mandelbrot set generated in {0:5.2f} seconds'.format(runtime))
        plot_mandel(mandel_set)

from setuptools import setup
from distutils.core import setup
from Cython.Build import cythonize
import numpy

exts = (cythonize('Mandel_py.pyx'))

setup(ext_modules=exts,
    include_dirs=[numpy.get_include()],
    )
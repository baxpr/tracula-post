#!/usr/bin/env python3

import argparse
import nibabel
import numpy
import sys

parser = argparse.ArgumentParser()
parser.add_argument('--img_niigz')
parser.add_argument('--axis')
args = parser.parse_args()
img_niigz = args.img_niigz
axis = args.axis

img = nibabel.load(img_niigz)
imgdata = img.get_fdata()

# Center of mass
# (function snagged from scipy, https://stackoverflow.com/a/66172045)
def center_of_mass(input):
    normalizer = numpy.sum(input)
    grids = numpy.ogrid[[slice(0, i) for i in input.shape]]
    results = [numpy.sum(input * grids[dir].astype(float)) / normalizer
               for dir in range(input.ndim)]
    if numpy.isscalar(results[0]):
        return tuple(results)
    return [tuple(v) for v in numpy.array(results).T]

imgdata[numpy.isnan(imgdata)] = 0
imgdata[imgdata>0] = 1
com_ijk = center_of_mass(imgdata)
com_xyz = nibabel.affines.apply_affine(img.affine, com_ijk)
if axis=='com':
    print(f'{com_xyz[0]:.0f} {com_xyz[1]:.0f} {com_xyz[2]:.0f}')
    sys.exit(0)
else:
    axis = int(axis) 

# Extents
locs = numpy.where(imgdata>0)
min_ijk = [min(x) for x in locs]
max_ijk = [max(x) for x in locs]
xyz = nibabel.affines.apply_affine(img.affine, numpy.vstack([min_ijk, max_ijk]))
min_xyz = numpy.apply_along_axis(min, 0, xyz)
max_xyz = numpy.apply_along_axis(max, 0, xyz)

# Four slice locations on each axis, 20% 40% 60% 80%
slices = min_xyz[axis] + (max_xyz[axis] - min_xyz[axis]) * numpy.array([0.2, 0.4, 0.6, 0.8])
print(f'{slices[0]:.0f} {slices[1]:.0f} {slices[2]:.0f} {slices[3]:.0f}')

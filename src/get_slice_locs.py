#!/usr/bin/env python3

import argparse
import nibabel
import numpy
import scipy.ndimage

parser = argparse.ArgumentParser()
parser.add_argument('img_niigz')
args = parser.parse_args()
img_niigz = args.img_niigz

img = nibabel.load(img_niigz)
imgdata = img.get_fdata()

# Center of mass
imgdata[numpy.isnan(imgdata)] = 0
imgdata[imgdata>0] = 1
com_ijk = scipy.ndimage.center_of_mass(imgdata)
com_xyz = nibabel.affines.apply_affine(img.affine, com_ijk)
com_xyz = numpy.round(com_xyz)
print(com_xyz)

# Extents
locs = numpy.where(imgdata>0)
min_ijk = [min(x) for x in locs]
max_ijk = [max(x) for x in locs]
xyz = nibabel.affines.apply_affine(img.affine, numpy.vstack([min_ijk, max_ijk]))
xyz = numpy.round(xyz)
min_xyz = numpy.apply_along_axis(min, 0, xyz)
max_xyz = numpy.apply_along_axis(max, 0, xyz)
print(min_xyz)
print(max_xyz)


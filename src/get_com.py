#!/usr/bin/env python3
# 
# Get center of mass of cortex ROI, in voxel index

import sys
import nibabel
import scipy.ndimage
import numpy

axis = sys.argv[1]
nii_file = sys.argv[2]

img = nibabel.load(nii_file)
data = img.get_fdata()

# numpy can't handle SPM's nan voxels, so fix 'em
data[numpy.isnan(data)] = 0

# COM unweighted
data[data>0] = 1

# Get COM
com_vox = scipy.ndimage.center_of_mass(data)
com_world = nibabel.affines.apply_affine(img.affine, com_vox)

if axis is 'x':
    print('%d' % com_world[0])

if axis is 'y':
    print('%d' % com_world[1])

if axis is 'z':
    print('%d' % com_world[2])


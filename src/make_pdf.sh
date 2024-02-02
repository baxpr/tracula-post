#!/usr/bin/env bash

fs_dir=INPUTS/SUBJECT
trac_dir=OUTPUTS/SUBJECT

freeview ${trac_dir}/dmri/dtifit_FA.nii.gz ${trac_dir}/dlabel/diff/aparc+aseg.bbr.nii.gz:colormap=lut:opacity=.2 --layout 2

freeview --layout 1 --viewport axial ${trac_dir}/dmri/dtifit_FA.nii.gz ${trac_dir}/dlabel/diff/aparc+aseg.bbr.nii.gz:colormap=lut:opacity=.2

# FA overlaid on T1 to verify registration
# NOTE analysis is done in diffusion image space, which is NOT aligned with the original T1.
# For reg check we could look at <subjid>/dlabel/<space>/White-Matter.nii.gz  on the b=0

# White matter outline over FA in diffusion space
freeview --layout 2 -v ${trac_dir}/dmri/dtifit_FA.nii.gz \
    -v ${trac_dir}/dlabel/diff/White-Matter.bbr.nii.gz:colormap=binary:binary_color=red:outline=yes \
    -v ${trac_dir}/dlabel/diff/aparc+aseg_mask.bbr.nii.gz:colormap=binary:binary_color=yellow:outline=yes:structure=1


#    -v ${trac_dir}/dlabel/diff/aparc+aseg.bbr.nii.gz:colormap=binary:binary_color=yellow:outline=yes

#-v ${trac_dir}/dlabel/diff/aparc+aseg_mask.bbr.nii.gz:colormap=binary:binary_color=blue:outline=yes \

# FIXME Next do side by slide axial slices of WM on FA and MD.


nslices=$(mri_info --nslices ${trac_dir}/dmri/dtifit_FA.nii.gz)


# Thresholded probmaps on FA
freeview --layout 2 -v ${trac_dir}/dmri/dtifit_FA.nii.gz -tv ${trac_dir}/dpath/merged_avg16_syn_bbr.mgz:structure=5103

freeview --layout 1 --viewport 3d -v ${fs_dir}/mri/nu.mgz -tv ${trac_dir}/dpath/merged_avg16_syn_bbr.mgz


freeview -v  ${trac_dir}/dmri/dtifit_FA.nii.gz -v ${trac_dir}/dpath/cc.bodyc_avg16_syn_bbr/path.pd.nii.gz:isosurface=on:isosurface_color=red

freeview -v  ${trac_dir}/dmri/dtifit_FA.nii.gz -v ${trac_dir}/dpath/cc.bodyc_avg16_syn_bbr/path.pd.nii.gz:colormap=heat -l ${trac_dir}/dpath/cc.bodyc_avg16_syn_bbr/path.map.nii.gz:centroid=yes

freeview -v  ${trac_dir}/dmri/dtifit_FA.nii.gz -t ${trac_dir}/dpath/cc.bodyc_avg16_syn_bbr/path.pd.trk

# Individual probmaps on T1 at center of mass

#!/bin/bash

out_dir=$(pwd)/../OUTPUTS
trac_dir=$(pwd)/../OUTPUTS/SUBJECT
label_info="TEST SUBJ TEST SESS TEST SCAN"

mask_niigz=${trac_dir}/dmri/nodif_brain_mask.nii.gz
fa_niigz=${trac_dir}/dmri/dtifit_FA.nii.gz
md_niigz=${trac_dir}/dmri/dtifit_MD.nii.gz
wm_niigz=${trac_dir}/dlabel/diff/White-Matter.bbr.nii.gz

mkdir -p ${out_dir}/tmp
cd ${out_dir}/tmp

# Center of mass of brain mask
com=$(get_slice_locs.py --axis com --img_niigz ${mask_niigz})
com=(${com// / })

# Individual slices
for axis in 0 1 2; do

    slices=$(get_slice_locs.py --axis $axis --img_niigz ${mask_niigz})
    slices=(${slices// / })

    img=0
    for slice in ${slices[@]}; do

        if [[ "$axis" == "0" ]]; then 
            vp="x"
            ras="${slice} ${com[1]} ${com[2]}"
        elif [[ "$axis" == "1" ]]; then 
            vp="y"
            ras="${com[0]} ${slice} ${com[2]}"
        elif [[ "$axis" == "2" ]]; then 
            vp="z"
            ras="${com[0]} ${com[1]} ${slice}"
        fi
        
        ((img++))
        fname=$(printf "slice_${axis}_%02i.png" ${img})
        freeview --layout 1 --viewport $vp --ras $ras -viewsize 400 400 \
            -v ${fa_niigz} \
            -v ${wm_niigz}:colormap=binary:binary_color=red:outline=yes \
            -ss ${fname}
        convert ${fname} -pointsize 18 -fill white -annotate +10+20 "FA, ${vp} = ${slice} mm" ${fname}

        ((img++))
        fname=$(printf "slice_${axis}_%02i.png" ${img})
        freeview --layout 1 --viewport $vp --ras $ras -viewsize 400 400 \
            -v ${md_niigz} \
            -v ${wm_niigz}:colormap=binary:binary_color=red:outline=yes \
            -ss ${fname}
        convert ${fname} -pointsize 18 -fill white -annotate +10+20 "MD, ${vp} = ${slice} mm" ${fname}
    
    done
done

# Combine slices
montage -mode concatenate slice_0_*.png -border 5 -bordercolor white -tile 2x4 x_mont_%03d.png
montage -mode concatenate slice_1_*.png -border 5 -bordercolor white -tile 2x4 y_mont_%03d.png
montage -mode concatenate slice_2_*.png -border 5 -bordercolor white -tile 2x4 z_mont_%03d.png

# Pad and annotate with assessor name
for i in ?_mont_???.png; do    
    convert \
        -size 1224x1584 xc:white \
        -gravity Center \( ${i} -resize 1194x1454 -geometry +0+0 \) -composite \
        -gravity SouthEast -pointsize 24 -annotate +20+20 "$(date)" \
        -gravity NorthWest -pointsize 24 -annotate +20+40 "${label_info}" \
        ${i}
done

# 3D view of all tract maps on FA
freeview --layout 1 --viewport 3d --viewsize 800 800 \
    --hide-3d-slices --hide-3d-frames \
    -cam dolly 2 azimuth -30 elevation 30 \
    -v ${fa_niigz} \
    -tv ${trac_dir}/dpath/merged_avg16_syn_bbr.mgz \
    -ss view3d.png
convert view3d.png -fuzz 1% -trim +repage -bordercolor black -border 30 view3d.png
convert \
    -size 1224x1584 xc:white \
    -gravity Center \( view3d.png -resize 1194x1454 -geometry +0+0 \) -composite \
    -gravity SouthEast -pointsize 24 -annotate +20+20 "$(date)" \
    -gravity NorthWest -pointsize 24 -annotate +20+40 "${label_info}" \
    view3d.png

# Concatenate into PDF
convert \
    view3d.png \
    x_mont_???.png y_mont_???.png z_mont_???.png \
    -page letter \
    ${out_dir}/tracula.pdf


exit 0


# Trim 3d screenshots
for i in [lr]h_*.png;do convert $i -fuzz 1% -trim +repage t${i};done

# Create first page, 3Ds
montage -mode concatenate \
    tlh_lat_aparc.png tlh_lat_pial.png tlh_lat_thick.png \
    trh_lat_aparc.png trh_lat_pial.png trh_lat_thick.png \
    tlh_med_aparc.png tlh_med_pial.png tlh_med_thick.png \
    trh_med_aparc.png trh_med_pial.png trh_med_thick.png \
    -tile 3x -quality 100 -background black -gravity center \
    -trim -border 5 -bordercolor black -resize 300x first_page.png

convert \
    -size 1224x1584 xc:white \
    -gravity North \( first_page.png -resize 1194x1194 -geometry +0+100 \) -composite \
    -gravity NorthEast -pointsize 24 -annotate +20+50 "QA Summary - recon-all" \
    -gravity SouthEast -pointsize 24 -annotate +20+20 "$the_date" \
    -gravity SouthWest -pointsize 24 -annotate +20+20 "$(cat $FREESURFER_HOME/build-stamp.txt)" \
    -gravity NorthWest -pointsize 24 -annotate +20+50 "${label_info}" \
    first_page.png

# Concatenate into PDF
convert \
    first_page.png \
    x_mont_???.png y_mont_???.png z_mont_???.png \
    -page letter \
    freesurfer_detailed.pdf

mkdir "${SUBJECTS_DIR}"/PDF_DETAIL
cp freesurfer_detailed.pdf "${SUBJECTS_DIR}"/PDF_DETAIL

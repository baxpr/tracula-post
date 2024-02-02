#!/usr/bin/env bash

export out_dir=../OUTPUTS

# Find all the pathstats files and store in a text file
ls -1d "${out_dir}"/SUBJECT/dpath/*_bbr > "${out_dir}"/pathlist.txt

# Extract for each path (tractstats2table can't handle different paths in same pass)
mkdir "${out_dir}"/STATS
while read -r path; do
    tract=$(basename ${path})
    tractstats2table \
        -i "${path}"/pathstats.overall.txt \
        --overall -d comma \
        --tablefile "${out_dir}"/STATS/pathstats-"${tract}".txt
done < "${out_dir}"/pathlist.txt

# Next a bit of python to combine the stat files. Will make a new file at
#  out_dir/STATS/pathstats-all.csv which is what we want to keep
combine_stats.py --out_dir "${out_dir}"

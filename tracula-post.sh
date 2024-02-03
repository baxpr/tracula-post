#!/usr/bin/env bash

# Defaults
export label_info="UNKNOWN SCAN"
export out_dir="/OUTPUTS"
export trac_dir="/OUTPUTS/TRACULA/SUBJECT"

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --label_info)
        export label_info="$2"; shift; shift;;
    --out_dir)
        export out_dir="$2"; shift; shift;;
    --trac_dir)
        export trac_dir="$2"; shift; shift;;
    *)
		echo "Unknown argument $key"; shift;;
  esac
done


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

# PDF
make_pdf.sh

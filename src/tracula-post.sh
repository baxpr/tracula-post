#!/usr/bin/env bash

export out_dir=../OUTPUTS

# Find all the pathstats files and store in a text file
find "${out_dir}"/SUBJECT -name pathstats.overall.txt > "${out_dir}"/pathstats-files.txt

# Extract
mkdir "${out_dir}"/STATS
tractstats2table \
    --load-pathstats-from-file "${out_dir}"/pathstats-files.txt \
    --overall \
    --tablefile "${out_dir}"/STATS/all-pathstats.txt

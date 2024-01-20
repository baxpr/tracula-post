#!/usr/bin/env python

import argparse
import os
import pandas

parser = argparse.ArgumentParser()
parser.add_argument('--out_dir')
args = parser.parse_args()
out_dir = args.out_dir

info = pandas.read_csv(os.path.join(out_dir,'pathlist.txt'), header=None, names=['srcpath'])
info['tractlong'] = info.srcpath.apply(os.path.basename)
info['tract'] = [x.split('_')[0] for x in info.tractlong]
info['statfile'] = [f'{out_dir}/STATS/pathstats-{x}.txt' for x in info.tractlong]

#data = pandas.read_csv(info.statfile[0], usecols=range(1, 19))

#data = [pandas.read_csv(x, usecols=range(1, 19)) for x in info.statfile]


for row in info.itertuples(name='row'):
        
    thisdata = pandas.read_csv(info.statfile[row.Index], usecols=range(1, 19))
    thisdata.insert(0, 'tract', row.tract)
    
    if row.Index==0:
        data = thisdata
    else:
        data = pandas.concat([data, thisdata])

data.to_csv(f'{out_dir}/STATS/pathstats-all.csv', index=False)


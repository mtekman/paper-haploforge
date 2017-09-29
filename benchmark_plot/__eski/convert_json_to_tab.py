#!/usr/bin/env python3

import sys, json, pdb

f = open(sys.argv[1],'r')
data = f.read()

obj = json.loads(data)
#pdb.set_trace()

print("InbreedProb","NumRootFounder","MaxGen","Allele","TotalPeople","NumInbredCouples","TimeTree","TimeRend")

for key in obj:

    junk, inbreed_chance, num_rootfounders, maxgens, allele_size = key.split(' ')

    if 'record' not in obj[key]:
        continue
   
    for rec in obj[key]['record']:

        if 'error' in rec:
            if rec['error'] == {}:
                continue
            
        
        if len(rec) < 1:
            continue
        try:
            people = rec['people']
            inbred = rec['inbredcouples']
            time_tree = rec['time_tree']
            time_rend = rec['time_render']
        except KeyError:
            print("DIS")
            print(obj[key])
            exit(-1)
            
        print(inbreed_chance, num_rootfounders, maxgens, allele_size, people, inbred, time_tree, time_rend, sep='\t')

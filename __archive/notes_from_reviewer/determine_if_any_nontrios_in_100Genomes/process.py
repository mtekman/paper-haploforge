#!/usr/bin/env python3
import sys
import pdb

fam_map = {}

with open(sys.argv[1],'r') as f:
    f.readline()
    for line in f:
        fam, indiv, pat, mat, gend, pheno, pop, relate, sibs, sec, third, other = line.split('\t')

        if fam not in fam_map:
            fam_map[fam] = {}

        if indiv in fam_map[fam]:
            print( "Duplicate", fam, indiv, file=sys.stderr)
            pdb.set_trace()
            exit(-1)

        fam_map[fam][indiv] = { 'mat': mat, 'pat': pat, 'sibs':sibs }

#pdb.set_trace()

for key in fam_map:
    print(key, len(fam_map[key]))

    

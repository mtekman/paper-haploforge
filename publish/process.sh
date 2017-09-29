#!/bin/bash

[ "$1" = "" ] && echo "Give version number" && exit -1

name="bioinformatics_`date +%Y%m%d`.v$1.zip"

zip -r $name\
 bioinfo.cls\
 main.tex\
 OUP_First_SBk_Bot_8401.eps\
 algorithm2e.sty\
 all_in_one.4.eps\
 dos2.4.eps\
 graph_and_path2.4.eps\
 homology.4.eps\
 hpainter_inheritance_small.4.eps\
 path_finder.5.eps\
 pedcreate.4.eps\
 x_compare.4.eps\
 natbib.bst\
 natbib.sty\
 url.sty\
 smallbib.bib\
 supplemental\
 Reference_PDF.pdf

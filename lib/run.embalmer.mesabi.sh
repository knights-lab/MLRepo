#!/bin/bash -x

# Usage: bash ./run.embalmer.sh seqfilepath outputfolder database
# where database is PROK_170704 for refseq or gg97 for green genes

SEQS=$1
OUTFOLDER=$2
DB=$3 

if [ "${DB}" = "gg97" ]; then
    XPARAM='-bc 3'
    OUTPUT=${OUTFOLDER}/gg
    ID=0.97
else
    XPARAM=''
    OUTPUT=${OUTFOLDER}/refseq
    ID=0.935
fi

# only make dir if it doesn't already exist
mkdir -p ${OUTPUT}
    
echo "emb12 -r /scratch.global/gabe/databases/${DB}.edx -a /scratch.global/gabe/databases/${DB}.acx -b /scratch.global/gabe/databases/${DB}.tax -q ${SEQS} -o ${OUTPUT}/embalmer_output.b6 -n -m CAPITALIST -bs -i ${ID} -fr -f -sa ${XPARAM}"
emb12 -r /scratch.global/gabe/databases/${DB}.edx -a /scratch.global/gabe/databases/${DB}.acx -b /scratch.global/gabe/databases/${DB}.tax -q ${SEQS} -o ${OUTPUT}/embalmer_output.b6 -n -m CAPITALIST -bs -i ${ID} -fr -f -sa ${XPARAM}

# CONVERT blast alignment to OTU and Taxa table
echo "embalmulate ${OUTPUT}/embalmer_output.b6  ${OUTPUT}/otutable.txt ${OUTPUT}/taxatable.txt GGtrim"
embalmulate ${OUTPUT}/embalmer_output.b6  ${OUTPUT}/otutable.txt ${OUTPUT}/taxatable.txt GGtrim

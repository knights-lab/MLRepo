#!/bin/bash -x

# Usage: bash ./run.embalmer.sh seqfilepath outputfolder database
# where database is PROK_170704 for refseq or gg97 for green genes or CHLORO for chloroplasts
# to be used for interactive runs of embalmer ONLY:
# isub -n nodes=1:ppn=16 -m 48GB -w 24:00:00

SEQS=$1
OUTFOLDER=$2
DB=$3 

if [ "${DB}" = "gg97" ]; then
    XPARAM='-bc 3'
    OUTPUT=${OUTFOLDER}/gg
fi
if [ "${DB}" = "PROK_170704" ]; then
    XPARAM=''
    OUTPUT=${OUTFOLDER}/refseq
fi
if [ "${DB}" = "CHLORO" ]; then
    XPARAM=''
    OUTPUT=${OUTFOLDER}/chloro
fi

# only make dir if it doesn't already exist
mkdir -p ${OUTPUT}
    
echo "b12q -r /scratch/gabe/databases/${DB}.edx -a /scratch/gabe/databases/${DB}.acx -b /scratch/gabe/databases/${DB}.tax -q ${SEQS} -o ${OUTPUT}/embalmer_output.b6 -n -m CAPITALIST -bs -i 0.935 -fr -f -sa ${XPARAM}"
b12q -r /scratch/gabe/databases/${DB}.edx -a /scratch/gabe/databases/${DB}.acx -b /scratch/gabe/databases/${DB}.tax -q ${SEQS} -o ${OUTPUT}/embalmer_output.b6 -n -m CAPITALIST -bs -i 0.935 -fr -f -sa ${XPARAM}

# CONVERT blast alignment to OTU and Taxa table
echo "embalmulate ${OUTPUT}/embalmer_output.b6  ${OUTPUT}/otutable.txt ${OUTPUT}/taxatable.txt GGtrim"
embalmulate ${OUTPUT}/embalmer_output.b6  ${OUTPUT}/otutable.txt ${OUTPUT}/taxatable.txt GGtrim

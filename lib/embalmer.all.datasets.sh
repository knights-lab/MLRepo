#!/bin/bash -x

# Usage: bash ./embalmer.all.datasets.sh PROK_170704
# Usage: bash ./embalmer.all.datasets.sh gg97

DB=$1

bash ./run.embalmer.sh ./turnbaugh_twins/raw/Turnbaugh_twins_split_library_seqs.fna ./turnbaugh_twins ${DB}

bash ./run.embalmer.sh ./bacteremia/raw/seqs-bacteremia.fna ./bacteremia ${DB}

bash ./run.embalmer.sh ./cho/raw/Cho_trimmed_150.fasta ./cho ${DB}

bash ./run.embalmer.sh ./david/raw/fixed.fasta ./david ${DB}

bash ./run.embalmer.sh ./ridaura/raw/Ridaura_split_library_seqs.fna ./ridaura ${DB}

bash ./run.embalmer.sh ./sokol/raw/study_1460_split_library_seqs.fna ./sokol ${DB}

bash ./run.embalmer.sh ./bushman_cafe/raw/Wu_split_library_seqs.fna ./bushman_cafe ${DB}

bash ./run.embalmer.sh ./claesson/raw/Claesson_elderly_gut_study_486_split_library_seqs.fna ./claesson ${DB}

bash ./run.embalmer.sh ./dethlefsen/raw/Dethlefsen_split_library_seqs.fna ./dethlefsen ${DB}

bash ./run.embalmer.sh ./gevers/raw/Gevers_CCFA_RISK_study_1939_split_library_seqs.fna ./gevers ${DB}

bash ./run.embalmer.sh ./kostic/raw/study_1457_split_library_seqs.fna ./kostic ${DB}

bash ./run.embalmer.sh ./hmp/raw/hmp_split_library_seqs.fna ./hmp ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Yatsunenko_global_gut_study_850_ref_13_8/study_850_split_library_seqs.fna ./yatsunenko ${DB}

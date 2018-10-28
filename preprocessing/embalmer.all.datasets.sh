#!/bin/bash -x

# Usage: bash ./embalmer.all.datasets.sh PROK_170704
# Usage: bash ./embalmer.all.datasets.sh gg97

DB=$1

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Turnbaugh_twins_obesity_study_77_ref_13_8/study_77_split_library_seqs.fna ./turnbaugh_twins ${DB}

bash ./run.embalmer.sh ./bacteremia/raw/seqs-bacteremia.fna ./bacteremia ${DB}

bash ./run.embalmer.sh ./cho/raw/Cho_trimmed_150.fasta ./cho ${DB}

bash ./run.embalmer.sh ./david/raw/david_corrected_seqs.fna ./david ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Ridaura_Cohousing_Discordant_Humanized_Mice_Titanium_study_1522_ref_13_8/study_1522_split_library_seqs.fna ./ridaura ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Sokol_IBD_dysfunction_study_1460_ref_13_8/Sokol_IBD_dysfunction_study_1460_split_library_seqs.fna ./sokol ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Bushman_enterotypes_cafe_study_1010_ref_13_8/Bushman_enterotypes_cafe_study_1010_split_library_seqs.fna ./bushman_cafe ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Claesson_elderly_gut_study_486_ref_13_8/Claesson_elderly_gut_study_486_split_library_seqs.fna ./claesson ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Gevers_CCFA_RISK_study_1939_gg_ref_13_8/Gevers_CCFA_RISK_study_1939_split_library_seqs.fna ./gevers ${DB}

bash ./run.embalmer.sh /home/knightsd/public/qiime_db/processed/Kostic_colorectal_cancer_fusobacterium_study_1457_ref_13_8/study_1457_split_library_seqs.fna ./kostic ${DB}

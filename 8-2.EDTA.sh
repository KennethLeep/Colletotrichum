#!/bin/bash

set -e
source config.sh
mkdir -p "$EDTA" "$EDTA/logs"

module load miniconda
source activate "$ENVS/edta_env"

exec > >(tee "$EDTA/logs/EDTA.sh.log") 2>&1

cd "$EDTA"

perl "$ENVS/edta_env/bin/EDTA.pl" \
    --genome "$FUN2CLEAN/${TRAINER}sorted.fa" \
    --species others \
    --step all \
    --protlib "$EVIDENCE/final_clean_proteome.faa" \
    --cds "$EVIDENCE/${TRAINER}_cleaned.fasta" \
    --threads $CORES \
    --sensitive 1 \
    --force 1

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$GFACS" "$GFACS/logs"

module load miniconda
source activate "$ENVS/gfacs_env"

for iso in "${ISOREFS[@]}"
do
    mkdir -p "$GFACS/${iso}"
    SPECIES_PATH="${SPECIES_MAP[$iso]// /_}"
    perl "$ENVS/gfacs_env/bin/gFACs.pl" \
        -f EVM_1.1.1_gff3 \
        --fasta "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.fasta" \
        --create-gff3 \
        --statistics \
        --statistics-at-every-step \
        --min-exon-size 20 \
        --min-intron-size 20 \
        --min-CDS-size 150 \
        --unique-genes-only \
        --get-fasta \
        --get-protein-fasta \
        --create-gtf \
        -O "$GFACS/${iso}" \
        "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.gff3"
done

conda deactivate
exit 0
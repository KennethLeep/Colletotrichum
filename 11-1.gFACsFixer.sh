#!/bin/bash

set -e
source config.sh

module load miniconda
source activate "$ENVS/gt_env"

mkdir -p "$FIXER" "$FIXER/rawinputs" "$FIXER/intermediates"
RAWIN="$FIXER/rawinputs"
INT="$FIXER/intermediates"

for iso in "${ISOREFS[@]}"
do
    cp -v "$GFACS/${iso}/out.gff3" "$RAWIN/${iso}out.gff3"
    sed -e 's/;\.exon/_exon/g' \
        -e 's/;\.intron/_intron/g' \
        -e 's/;;/;/g' \
        -e 's/;$//' "$RAWIN/${iso}out.gff3" > "$INT/${iso}_sanitized.gff3"
    gt gff3 -sort -tidy -retainids "$INT/${iso}_sanitized.gff3" > "$INT/${iso}_sorted.gff3"
    gt cds -matchdescstart -seqfile "$FUN2CLEAN/${iso}sorted.fa" -o "$INT/${iso}out_fixed.gff3" "$INT/${iso}_sorted.gff3"
done

conda deactivate

source activate "$ENVS/cleanup_env"

for iso in "${ISOREFS[@]}"
do
    agat_convert_sp_gxf2gxf.pl -g "$INT/${iso}out_fixed.gff3" -o "$INT/${iso}_agatted.gff3"
    cat "$INT/${iso}_agatted.gff3" | python "$SCRIPT_DIR/locus_fixer.py" > "$FIXER/${iso}_antismash.gff3"
done

conda deactivate

for iso in "${ISOREFS[@]}"
do
    mkdir -p "$FUN2/${iso}_annotation/predict_results_original"
    mv "$FUN2/${iso}_annotation/predict_results/"*.* "$FUN2/${iso}_annotation/predict_results_original"
    SPECIES_PATH="${SPECIES_MAP[$iso]// /_}"
    cp "$GFACS/${iso}/genes.fasta" "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.transcripts.fa"
    cp "$GFACS/${iso}/genes.fasta.faa" "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.proteins.fa"
    cp "$REPEAT/${iso}/${iso}sorted.fa.masked" "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.fasta"
    cp "$FIXER/${iso}_antismash.gff3" "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.gff3"
    sed -i 's/>ID=/>/g; s/;//g' "$FUN2/${iso}_annotation/predict_results/${SPECIES_PATH}_${iso}.proteins.fa"
done
 
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$IPR" "$IPR/logs" "$IPR/inputs"

module load rstudio-desktop/2024.12.1
module load openjdk/11.0.23_9-7yrjwam
module load miniconda

source activate "$ENVS/funannotate2_env"

export _JAVA_OPTIONS="-Xmx10G"

LOC="$SOFTWARE/interproscan-5.76-107.0"

for iso in "${ISOREFS[@]}"
do
    mkdir -p "$IPR/${iso}"
    cp "$GFACS/${iso}/genes.fasta.faa" "$IPR/inputs/${iso}_proteins_raw.faa"
    sed 's/\*//g' "$IPR/inputs/${iso}_proteins_raw.faa" > "$IPR/inputs/${iso}_proteins_fixed.faa"
    "$LOC/interproscan.sh" -i "$IPR/inputs/${iso}_proteins_fixed.faa" -f XML,TSV -goterms -pa -cpu $CORES -dp --output-dir "$IPR/${iso}"
done

conda deactivate
exit 0
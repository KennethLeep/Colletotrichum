#!/bin/bash

set -e
source config.sh
mkdir -p "$ANTI" "$ANTI/logs"

module load miniconda
source activate "$ENVS/funannotate2_env"

for iso in "${ISOREFS[@]}"
do
    mkdir -p "$ANTI/$iso"
    antismash --taxon fungi \
        --cb-general --cb-subcluster --cb-knownclusters \
        --asf --pfam2go \
        --genefinding-gff3 "$FIXER/${iso}_antismash.gff3" \
        --genefinding-tool none \
        --cpus $CORES \
        --output-dir "$ANTI/$iso" \
        --output-basename "$iso" \
        "$FUN2CLEAN/${iso}sorted.fa"
done

conda deactivate
exit 0
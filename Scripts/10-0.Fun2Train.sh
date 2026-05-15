#!/bin/bash

set -e
source config.sh
mkdir -p "$FUN2" "$FUN2/logs"

module load miniconda
source activate "$ENVS/funannotate2_env"

#exec > >(tee "$FUN2/logs/Fun2Train.sh.log") 2>&1

for train in "${TRAINING[@]}"
do
    funannotate2 train \
        -f "$REPEAT/${train}/${train}sorted.fa.masked" \
        -s "${SPECIES_MAP[$train]}" \
        -o "$FUN2/$train" \
        --cpus @CORES \
        --busco-lineage "glomerellales" \
        --augustus-species "verticillium_longisporum1"
done

conda deactivate
exit 0
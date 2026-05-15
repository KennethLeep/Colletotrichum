#!/bin/bash

set -e
source config.sh

module load miniconda
source activate "$ENVS/funannotate2_env"

NAME="${ISOREFS[$SLURM_ARRAY_TASK_ID]}"

for iso in "${ISOREFS[@]}"
do
    funannotate2 annotate -i "$FUN2/${iso}_annotation" \
        -o "$FUN2/${iso}_annotation" \
        -s "${SPECIES_MAP[$iso]}" \
        -st "$iso" \
        --cpus $CORES \
        --busco-lineage glomerellales
done

conda deactivate
exit 0
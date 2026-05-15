#!/bin/bash

set -e
source config.sh
mkdir -p "$QUAST" "$QUAST/logs"

module load miniconda
source activate "$ENVS/quast_env"

exec > >(tee "$QUAST/logs/Quast.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    quast.py "$REPEAT/${iso}/${iso}sorted.fa.masked" -r "$REFS/${SPECIES_MAP[$iso]}.fa" -o "$QUAST/${iso}_Masked"
done

conda deactivate
exit 0
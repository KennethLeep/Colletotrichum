#!/bin/bash
set -e

source config.sh
mkdir -p "$QUAST" "$QUAST/logs"

exec > >(tee "$QUAST/logs/Quast_Clean.sh.log") 2>&1

module load miniconda
source activate "$ENVS/quast_env"

for iso in "${ISOREFS[@]}"
do
    quast.py "$FUN2CLEAN/${iso}sorted.fa" -r "$REFS/${SPECIES_MAP[$iso]}.fa" -o "$QUAST/${iso}_Clean"
done

conda deactivate
exit 0
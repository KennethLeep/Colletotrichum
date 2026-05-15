#!/bin/bash

set -e
source config.sh
mkdir -p "$QUAST" "$QUAST/logs"

exec > >(tee "$QUAST/logs/Quast_Pilon.sh.log") 2>&1

module load miniconda
source activate "$ENVS/quast_env"

for iso in "${ISOLATES_ILL[@]}"
do
    quast.py "$PILON/${iso}_pilon.fasta" -r "$REFS/${SPECIES_MAP[$iso]}.fa" -o "$QUAST/${iso}_pilon"
done

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$TRNA" "$TRNA/logs"

module load miniconda
source activate "$ENVS/trna_env"

exec > >(tee "$TRNA/logs/tRNAscan-SE.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    tRNAscan-SE -G -I -a "$TRNA/${iso}trnascanned.fasta" -j "$TRNA/${iso}trna.gff3" -f "$TRNA/${iso}trna.ss" -o "$TRNA/${iso}trna.out" --thread $CORES "$REPEAT/${iso}/${iso}sorted.fa.masked"
done

conda deactivate
exit 0
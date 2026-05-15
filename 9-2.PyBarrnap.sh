#!/bin/bash

set -e
source config.sh
mkdir -p "$PYBAR" "$PYBAR/logs"

module load miniconda
source activate "$ENVS/pybarrnap_env"

exec > >(tee "$PYBAR/logs/PyBarrnap.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    pybarrnap --kingdom euk --threads $CORES --outseq "$PYBAR/${iso}barred.fasta" "$REPEAT/${iso}/${iso}sorted.fa.masked" > "$PYBAR/${iso}.gff"
done

conda deactivate
exit 0
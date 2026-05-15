#!/bin/bash

set -e
source config.sh
mkdir -p "$SIGNAL" "$SIGNAL/logs"

module load miniconda
source activate "$ENVS/signalp_env"

#exec > >(tee "$SIGNAL/logs/SignalP.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    signalp6 --fastafile "$GFACS/${iso}/genes.fasta.faa" --output_dir "$SIGNAL/${iso}" --organism euk --mode fast
done

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$EGG" "$EGG/logs"

module load miniconda
source activate "$ENVS/eggnog_env"

for iso in "${ISOREFS[@]}"
do
    emapper.py -i "$GFACS/${iso}/genes.fasta.faa" --output "$EGG/${iso}" --cpu $CORES --dbmem --go_evidence all --pfam_realign realign
done

conda deactivate
exit 0
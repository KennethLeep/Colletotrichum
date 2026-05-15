#!/bin/bash

source config.sh

module load miniconda
source activate "$ENVS/mashtree_env"

mkdir -p "$MASH"

mashtree --numcpus $CORES --sketch-size 10000 --outmatrix "$MASH/colletotrichum_parsed_distances.tab" "$PARSE/"*".fasta" > "$MASH/colletotrichum_parsed_verification.dnd"

conda deactivate
exit 0
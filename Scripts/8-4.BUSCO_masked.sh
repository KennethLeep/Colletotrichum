#!/bin/bash

set -e
source config.sh
mkdir -p "$BUSCO" "$BUSCO/logs" "$BUSCO/Masked"

exec > >(tee "$BUSCO/logs/BUSCO_masked.sh.log") 2>&1

module load miniconda
source activate "$ENVS/busco_env"

for iso in "${ISOLREFS[@]}"
do
    busco -i "$REPEAT/${iso}/${iso}sorted.fa.masked" -l glomerellales_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/Masked" -m genome -c $CORES
done

conda deactivate
exit 0
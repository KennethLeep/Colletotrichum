#!/bin/bash

set -e
source config.sh
mkdir -p "$BUSCO" "$BUSCO/logs"

module load miniconda
source activate "$ENVS/busco_env"
PARALLELCORES=$(( CORES / 4 ))

for iso in "${ISOLATES_ILL[@]}"
do
    busco -i "$ASSEMBLIES/${iso}.fa" -l fungi_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/fungi" -m genome -c $PARALLELCORES
    busco -i "$ASSEMBLIES/${iso}.fa" -l ascomycota_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/asco" -m genome -c $PARALLELCORES
    busco -i "$ASSEMBLIES/${iso}.fa" -l sordariomycetes_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/sordar" -m genome -c $PARALLELCORES
    busco -i "$ASSEMBLIES/${iso}.fa" -l glomerellales_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/glom" -m genome -c $PARALLELCORES
done

conda deactivate
exit 0
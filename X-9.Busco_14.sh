#!/bin/bash

set -e
source config.sh
mkdir -p "$BUSCO" "$BUSCO/logs"

module load miniconda
source activate "$ENVS/busco_env"

busco -i "$FUN2CLEAN/GCC14sorted.fa" -l fungi_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/fungi" -m genome -c $CORES
busco -i "$FUN2CLEAN/GCC14sorted.fa" -l ascomycota_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/asco" -m genome -c $CORES
busco -i "$FUN2CLEAN/GCC14sorted.fa" -l sordariomycetes_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/sordar" -m genome -c $CORES
busco -i "$FUN2CLEAN/GCC14sorted.fa" -l glomerellales_odb12 --download_path "$BUSCODL" --out_path "$BUSCO/glom" -m genome -c $CORES

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$FUN2CLEAN" "$FUN2CLEAN/logs"
module load miniconda
source activate "$ENVS/funannotate2_env"

ISOS=(GCC14_cleaned)

mv "$FUN2CLEAN/GCC14sorted.fa" "$FUN2CLEAN/GCC14sorted_old.fa"

for iso in ${ISOS[@]}
do
    funannotate2 clean -f "$ASSEMBLIES/${iso}.fa" -o "$FUN2CLEAN/${iso}sorted.fa" -m 1000 -r GCC14_ --cpus $CORES --exhaustive --logfile "$FUN2CLEAN/logs/FUN2CLEAN_${iso}_rework.log"
    mv "$FUN2CLEAN/${iso}sorted.fa" "$FUN2CLEAN/GCC14sorted.fa"
done



conda deactivate
exit 0
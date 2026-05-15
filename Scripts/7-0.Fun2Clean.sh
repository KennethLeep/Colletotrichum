#!/bin/bash

set -e
source config.sh

mkdir -p "$FUN2CLEAN" "$FUN2CLEAN/logs"
module load miniconda
source activate "$ENVS/funannotate2_env"

for iso in "${ISOREFS[@]}"
do
    funannotate2 clean -f "$ASSEMBLIES/${iso}.fa" -o "$FUN2CLEAN/${iso}sorted.fa" -m 1000 -r ${iso}_ --cpus $CORES --exhaustive --logfile "$FUN2CLEAN/logs/Fun2Clean_${iso}.log"
done

conda deactivate
exit 0
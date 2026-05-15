#!/bin/bash

set -e
source config.sh
mkdir -p "$INFERNAL" "$INFERNAL/logs"

module load miniconda
source activate "$ENVS/infernal_env"

exec > >(tee "$INFERNAL/logs/Infernal.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    cmscan --cpu $CORES --cut_ga --rfam --nohmmonly --tblout "$INFERNAL/${iso}table.tblout" -o "$INFERNAL/${iso}output.txt" "$DBS/InfernalDB/Rfam.cm" "$REPEAT/${iso}/${iso}sorted.fa.masked"
done

conda deactivate
exit 0
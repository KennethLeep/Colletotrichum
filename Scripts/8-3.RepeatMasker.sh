#!/bin/bash

set -e
source config.sh
mkdir -p "$REPEAT" "$REPEAT/logs"

module load miniconda
source activate "$ENVS/edta_env"

exec > >(tee "$REPEAT/logs/RepeatMasker.sh.log") 2>&1

for iso in "${ISOREFS[@]}"
do
    RepeatMasker \
        -lib "$EDTA/${TRAINER}sorted.fa.mod.EDTA.TElib.fa" \
        -xsmall \
        -gff \
        -pa $CORES \
        -dir "$REPEAT/${iso}" \
        "$FUN2CLEAN/${iso}sorted.fa"
done

conda deactivate
exit 0
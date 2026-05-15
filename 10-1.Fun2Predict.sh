#!/bin/bash

set -e
source config.sh
mkdir -p "$FUN2" "$FUN2/logs"

module load miniconda
source activate "$ENVS/funannotate2_env"

for iso in "${ISOREFS[@]}"
do
    if [[ "${SPECIES_MAP[$iso]}" == "Colletotrichum siamense" ]]; then
        PARAMS="${TRAINING[0]}"
    elif [[ "${SPECIES_MAP[$iso]}" == "Colletotrichum camelliae" ]]; then
        PARAMS="${TRAINING[1]}"
    else echo "Isolate not found in species list, cannot specify a training model, please consult ReadMe for more"
        exit 1
    fi
    SPECIES_FILENAME="${SPECIES_MAP[$iso]// /_}"
    funannotate2 predict \
        -f "$REPEAT/${iso}/${iso}sorted.fa.masked" \
        -p "$FUN2/$PARAMS/train_results/${SPECIES_FILENAME}.params.json" \
        -ps "$EVIDENCE/final_clean_proteome.faa" \
        -o "$FUN2/${iso}_annotation" \
        -s "${SPECIES_MAP[$iso]}" \
        -st "${iso}" \
        -c $CORES
done

conda deactivate
exit 0
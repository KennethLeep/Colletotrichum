#!/bin/bash

set -e
source config.sh
mkdir -p "$HIFI" "$HIFI/logs"

module load miniconda
source activate "$ENVS/hifiasm_env"

exec > >(tee "$HIFI/logs/HiFiASM.sh.log") 2>&1

for iso in "${ISOLATES_PB[@]}"
do
    mkdir -p "$HIFI/${iso}"
    hifiasm -t $CORES -o "$HIFI/${iso}/${iso}_asm" "$READS/${iso}_reads.fq"
done

echo "HiFiASM assembly of sequence is complete. You MUST run Bandage to manually verify files before continuing."

conda deactivate
exit 0
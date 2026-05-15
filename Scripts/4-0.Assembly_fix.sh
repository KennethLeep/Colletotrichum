#!/bin/bash

set -e
source config.sh
mkdir -p "$ASSEMBLIES" "ASSEMBLIES/logs"

module load miniconda
source activate "$ENVS/cleanup_env"

exec > >(tee "$ASSEMBLIES/logs/Assembly_fix.sh.log") 2>&1

for iso in "${ISOLATES_ILL[@]}"
do
    mv "$ASSEMBLIES/"*"${iso}"*.fa "$ASSEMBLIES/${iso}.fa"
    seqkit stats "$ASSEMBLIES/${iso}.fa"
done

conda deactivate
exit 0
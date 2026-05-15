#!/bin/bash

set -e
source config.sh
mkdir -p "$QUAST" "$QUAST/logs"
exec > >(tee "$QUAST/logs/Quast_Clean.sh.log") 2>&1

module load miniconda
source activate "$ENVS/quast_env"

quast.py "$FUN2CLEAN/GCC14sorted.fa" -r "$REFS/LS19.fa" -o "$QUAST/${iso}_Clean_Purged"

conda deactivate
exit 0
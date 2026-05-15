#!/bin/bash

set -e
source config.sh

module load miniconda
source activate "$ENVS/cleanup_env"

for iso in "${ISOLATES_PB[@]}"
do
    echo "Processing: ${iso}"
    grep '^S' "$HIFI/${iso}/${iso}_asm.bp.hap1.p_ctg.gfa" | \
    awk '{print ">"$2"\n"$3}' | \
    seqkit fx2tab -n -g -l
done >> "$HIFI/AssemblyChar.sh.log"

conda deactivate
exit 0
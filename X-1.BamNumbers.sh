#!/bin/bash

set -e
source config.sh
module load miniconda
source activate "$ENVS/btk_env"

for iso in "${ISOLATES_ILL[@]}"
do
    samtools coverage "$BAM/${iso}_mapped.bam" | grep -v "^#" | awk -v name="$iso" '{len=$3-$2+1; sumdepth += ($7 * len); totallen += len} END {print name ": Weighted Average Depth: " sumdepth/totallen}'
done >> "$BAM/logs/BamNumbers.sh.log"

conda deactivate
exit 0
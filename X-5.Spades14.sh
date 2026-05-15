#!/bin/bash

set -e
source config.sh
mkdir -p "$SPADES/GCC14clean" "$SPADES/GCC14contam" "$SPADES/logs"

exec > >(tee "$SPADES/logs/Spades.sh.GCC14rework.log") 2>&1

module load miniconda
source activate "$ENVS/spades_env"

#spades.py -1 "$PURGEDREADS/GCC14_clean_R1.fastq" -2 "$PURGEDREADS/GCC14_clean_R2.fastq" -s "$PURGEDREADS/GCC14_clean_orphans.fastq" -o "$SPADES/GCC14clean" -t $CORES --isolate

spades.py -1 "$CONTAMREADS/GCC14_clean_R1.fastq" -2 "$CONTAMREADS/GCC14_clean_R2.fastq" -s "$CONTAMREADS/GCC14_clean_orphans.fastq" -o "$SPADES/GCC14contam" -t $CORES --isolate

conda deactivate
exit 0
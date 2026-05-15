#!/bin/bash

set -e
source config.sh
mkdir -p "$CLUSTER" "$CLUSTER/logs"

module load miniconda
source activate "$ENVS/cleanup_env"

exec > >(tee "$CLUSTER/logs/rDNAClusterRemover.sh.log") 2>&1

mv "$REPEAT/GCC05PB/GCC05PBsorted.fa.masked" "$CLUSTER/GCC05PB_clustered.fa"
mv "$REPEAT/GCC14PB/GCC14PBsorted.fa.masked" "$CLUSTER/GCC14PB_clustered.fa"
mv "$REPEAT/LT31/LT31sorted.fa.masked" "$CLUSTER/LT31_clustered.fa"

grep ">" "$CLUSTER/GCC05PB_clustered.fa" | sed 's/>//' | grep -v "GCC05PB_19" > "$CLUSTER/GCC05_good_contigs.list"
grep ">" "$CLUSTER/GCC14PB_clustered.fa" | sed 's/>//' | grep -v "GCC14PB_18" > "$CLUSTER/GCC14_good_contigs.list"
grep ">" "$CLUSTER/LT31_clustered.fa" | sed 's/>//' | grep -v "LT31_21" > "$CLUSTER/LT31_good_contigs.list"

samtools faidx "$CLUSTER/GCC05PB_clustered.fa" -r "$CLUSTER/GCC05_good_contigs.list" > "$REPEAT/GCC05PB/GCC05PBsorted.fa.masked"
samtools faidx "$CLUSTER/GCC14PB_clustered.fa" -r "$CLUSTER/GCC14_good_contigs.list" > "$REPEAT/GCC14PB/GCC14PBsorted.fa.masked"
samtools faidx "$CLUSTER/LT31_clustered.fa" -r "$CLUSTER/LT31_good_contigs.list" > "$REPEAT/LT31/LT31sorted.fa.masked"

conda deactivate
exit 0
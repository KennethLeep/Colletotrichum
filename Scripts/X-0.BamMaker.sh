#!/bin/bash
set -e
source config.sh
mkdir -p "$BAM" "$BAM/logs"

exec > >(tee "$BAM/logs/BamMaker.sh.log") 2>&1

module load miniconda
source activate $ENVS/btk_env

for iso in ${ISOLATES_ILL[@]}
do
    minimap2 -ax sr -t $CORES "$FUN2CLEAN/${iso}sorted.fa" "$KRAKEN/KrakenExcludes/${iso}_clean_R1.fastq" "$KRAKEN/KrakenExcludes/${iso}_clean_R2.fastq" | samtools sort -@ $CORES -o "$BAM/${iso}_mapped_pairs.bam"
    minimap2 -ax sr -t $CORES "$FUN2CLEAN/${iso}sorted.fa" "$KRAKEN/KrakenExcludes/${iso}_clean_orphans.fastq" | samtools sort -@ $CORES -o "$BAM/${iso}_mapped_orphans.bam"
    samtools merge -@ $CORES "$BAM/${iso}_mapped.bam" "$BAM/${iso}_mapped_pairs.bam" "$BAM/${iso}_mapped_orphans.bam"
    samtools index -c "$BAM/${iso}_mapped.bam"
done

conda deactivate
exit 0
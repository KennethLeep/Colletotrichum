#!/bin/bash

set -e
source config.sh
mkdir -p "$PILON" "$PILON/logs"

iso=GCC14

exec > >(tee "$PILON/logs/Pilon.sh.GCC14rework.log") 2>&1

module load miniconda
source activate "$ENVS/pilon_env"

export _JAVA_OPTIONS="-Xmx180G"

cp "$SPADES/${iso}clean/scaffolds.fasta" "$PILON/${iso}clean/${iso}_scaffolds.fasta"

bwa index "$PILON/${iso}clean/${iso}_scaffolds.fasta"

bwa mem -t $CORES "$PILON/${iso}clean/${iso}_scaffolds.fasta" "$PURGEDREADS/${iso}_clean_R1.fastq" "$PURGEDREADS/${iso}_clean_R2.fastq" | samtools view -Sb -@ $CORES | samtools sort -o "$PILON/${iso}clean/${iso}_paired.bam" -@ $CORES

bwa mem -t $CORES "$PILON/${iso}clean/${iso}_scaffolds.fasta" "$PURGEDREADS/${iso}_clean_orphans.fastq" | samtools view -Sb -@ $CORES | samtools sort -o "$PILON/${iso}clean/${iso}_orphans.bam" -@ $CORES

samtools index "$PILON/${iso}clean/${iso}_paired.bam"
samtools index "$PILON/${iso}clean/${iso}_orphans.bam"

pilon --genome "$PILON/${iso}clean/${iso}_scaffolds.fasta" --frags "$PILON/${iso}clean/${iso}_paired.bam" --unpaired "$PILON/${iso}clean/${iso}_orphans.bam" --output "${iso}_pilon_cleaned" --outdir "$PILON" --threads $CORES --fix all

conda deactivate
exit 0
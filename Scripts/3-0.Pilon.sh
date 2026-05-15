#!/bin/bash

set -e
source config.sh
mkdir -p "$PILON" "$PILON/logs"

exec > >(tee "$PILON/logs/Pilon.sh.${iso}.log") 2>&1

module load miniconda
source activate "$ENVS/pilon_env"

export _JAVA_OPTIONS="-Xmx180G"

for iso in "${ISOLATES_ILL[@]}"
do
    cp "$SPADES/${iso}/scaffolds.fasta" "$PILON/${iso}_scaffolds.fasta"
    bwa index "$PILON/${iso}_scaffolds.fasta"
    bwa mem -t $CORES "$PILON/${iso}_scaffolds.fasta" "$KRAKEN/KrakenExcludes/${iso}_clean_R1.fastq" "$KRAKEN/KrakenExcludes/${iso}_clean_R2.fastq" | samtools view -Sb -@ $CORES | samtools sort -o "$PILON/${iso}_paired.bam" -@ $CORES
    bwa mem -t $CORES "$PILON/${iso}_scaffolds.fasta" "$KRAKEN/KrakenExcludes/${iso}_clean_orphans.fastq" | samtools view -Sb -@ $CORES | samtools sort -o "$PILON/${iso}_orphans.bam" -@ $CORES
    samtools index "$PILON/${iso}_paired.bam"
    samtools index "$PILON/${iso}_orphans.bam"
    pilon --genome "$PILON/${iso}_scaffolds.fasta" --frags "$PILON/${iso}_paired.bam" --unpaired "$PILON/${iso}_orphans.bam" --output "${iso}_pilon" --outdir "$PILON" --threads $CORES --fix all
done

conda deactivate
exit 0
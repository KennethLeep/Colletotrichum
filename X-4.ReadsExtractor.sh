#!/bin/bash

source config.sh
mkdir -p "$FIXREADS" "$FIXREADS/logs"

exec > >(tee "$FIXREADS/logs/ReadsExtractor.sh.log") 2>&1

module load miniconda
source activate $ENVS/pilon_env

iso=GCC14 #change this value if another isolate name is being cleaned

cp $BLOBEXCLUDE/${iso}*.fa "$FIXREADS"
FILELIST=()
FULLLIST=$(ls $FIXREADS)
for item in ${FULLLIST[@]}
do
    if [ -f "$FIXREADS/$item" ]; then
        FILELIST+=($item)
    fi
done

for file in ${FILELIST[@]}
do
    base=$(basename "$file" .fa)
    mkdir -p "$FIXREADS/$base"
    bwa index "$FIXREADS/$file"
    bwa mem -t $CORES -M "$READS/$file" \
        "$KRAKEN/KrakenExcludes/${iso}_clean_R1.fastq" \
        "$KRAKEN/KrakenExcludes/${iso}_clean_R2.fastq" | \
        samtools view -@ $CORES -b -o "$FIXREADS/$base/mapped_paired_reads.bam"
    bwa mem -t $CORES -M "$FIXREADS/$file" \
        "$KRAKEN/KrakenExcludes/${iso}_clean_orphans.fastq" | \
        samtools view -@ $CORES -b -o "$FIXREADS/$base/mapped_orphans_reads.bam"
    samtools merge -o "$FIXREADS/$base/mapped_reads.bam" \
        "$FIXREADS/$base/mapped_orphans_reads.bam" \
        "$FIXREADS/$base/mapped_paired_reads.bam"
    samtools sort -n -@ $CORES -m 4G "$FIXREADS/$base/mapped_reads.bam" \
        -o "$FIXREADS/$base/sorted_reads.bam"
    samtools fastq -@ $CORES \
        -1 "$FIXREADS/$base/${iso}_clean_R1.fastq" \
        -2 "$FIXREADS/$base/${iso}_clean_R2.fastq" \
        -s "$FIXREADS/$base/${iso}_clean_orphans.fastq" \
        -F 4 "$FIXREADS/$base/sorted_reads.bam"
done

conda deactivate
exit 0
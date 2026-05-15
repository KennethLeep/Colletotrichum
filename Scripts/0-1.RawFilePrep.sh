#!/bin/bash

set -e
source config.sh

mkdir -p "$READS" "$READS/logs"
identmatch=$(echo "${ISOLATES_ILL[@]}" | tr ' ' '|')

exec > >(tee "$READS/logs/RawFilePrep.sh.log") 2>&1

echo "Starting Illumina reads importing and formatting"

echo "Step One - Verifying files from RawSequences folder"
for file in "$RAW/"*_1.fq.gz
do
    base=$(basename "$file")
    file2="${file%_1.fq.gz}_2.fq.gz"
    base2=$(basename "$file2")
    echo "Checking if $base has a matching Isolate ID"
    echo ""
    if echo "$base" | grep -Eiq "$identmatch"; then
        echo "Found matching Isolate ID for file: $base"
        echo ""
        echo "Searching for matching pair"
        if [ -f "$file2" ]; then
            echo "Success!: Found matching pair for $base"
            echo "Forward string: $base"
            echo "Reverse string: $base2"
        else
            echo "Error: Successful ident match but no matching reverse string for $base."
            exit 1
        fi
    else echo "Found an input file without a matching Isolate ID. Please see the ReadMe.txt and update the config.sh"
        exit 1
    fi
done

echo "Step One completed."
echo "Starting Step Two - Combining and copying raw reads files"

for iso in "${ISOLATES_ILL[@]}"
do
    for suffix in 1 2; do
        files=( "$RAW/"*"$iso"*"_${suffix}.fq.gz" )
        if [ -f "${files[0]}" ]; then
            if [ -f "${files[1]}" ]; then
                echo "Multiple matching inputs found for: $iso, $suffix. Combining them now"
                cat "${files[@]}" > "$READS/${iso}_${suffix}.fq.gz"
            else
                echo "Single matching input found for: $iso, $suffix. No combining necessary."
                cp "${files[0]}" "$READS/${iso}_${suffix}.fq.gz"
            fi
        else
            echo "No raw input files found matching isolate ID: $iso. Please add input files or check isolate ID in config.sh"
        fi
    done
done

echo "Step Two finished."
echo "Starting Step Three - unzipping raw reads files - this may take a moment"

for file in "$READS/"*.gz
do
    echo "Decompressing $file"
    gunzip $file
done

echo "Step Three finished. Illumina processing completed! Starting PacBio Processing."
echo "PacBio Step One, activating environment"

module load miniconda
source activate "$ENVS/cleanup_env"

echo "Environment activated."
echo "PacBio Step Two, formatting input files"

for iso in ${ISOLATES_PB[@]}
do
    echo "Processing $iso"
    samtools fastq "$RAW/${iso}.hifi_reads.bam" > "$READS/${iso}_reads.fq"
done

echo "PacBio Step Two completed. PacBio processing completed!"
echo "Total processing job completed, deactivating environment and shutting down."

conda deactivate
exit 0
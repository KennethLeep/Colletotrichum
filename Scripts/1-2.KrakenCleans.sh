#!/bin/bash

set -e
source config.sh

exec > >(tee "$KRAKEN/logs/KrakenCleans.sh.log") 2>&1

module load miniconda
source activate "$ENVS/kraken2_env"

for iso in "${ISOLATES_ILL[@]}"
do
    python "$ENVS/kraken2_env/bin/extract_kraken_reads.py" -k "$KRAKEN/KrakenResults/${iso}_orphans.output" -r "$KRAKEN/KrakenReports/${iso}_orphans.report" -s "$TRIMS/${iso}_orphans.fastq" --exclude --taxid 2 2157 10239 33208 5204 --output "$KRAKEN/KrakenExcludes/${iso}_clean_orphans.fastq" --fastq-output --include-children

    python "$ENVS/kraken2_env/bin/extract_kraken_reads.py" -k "$KRAKEN/KrakenResults/${iso}_paired.output" -r "$KRAKEN/KrakenReports/${iso}_paired.report" -s1 "$TRIMS/${iso}_R1.fastq" -s2 "$TRIMS/${iso}_R2.fastq" --exclude --taxid 2 2157 10239 33208 5204 --output "$KRAKEN/KrakenExcludes/${iso}_clean_R1.fastq" -o2 "$KRAKEN/KrakenExcludes/${iso}_clean_R2.fastq" --fastq-output --include-children
done

conda deactivate
exit 0
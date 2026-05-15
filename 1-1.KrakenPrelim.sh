#!/bin/bash

set -e
source config.sh

if [ ! -f "$KRAKEN/KrakenDatabase/hash.k2d" ]; then
    echo "ERROR: Kraken2 database not found in $KRAKEN/KrakenDatabase."
    echo "Please run KrakenSetup.sh before submitting this job."
    exit 1
fi

exec > >(tee "$KRAKEN/logs/KrakenPrelim.sh.log") 2>&1

module load miniconda
source activate "$ENVS/kraken2_env"

for iso in ${ISOLATES_ILL[@]}
do
    kraken2 --db "$KRAKEN/KrakenDatabase" --threads $CORES --confidence 0.5 --paired "$TRIMS/${iso}_R1.fastq" "$TRIMS/${iso}_R2.fastq" --output "$KRAKEN/KrakenResults/${iso}_paired.output" --report "$KRAKEN/KrakenReports/${iso}_paired.report"

    kraken2 --db "$KRAKEN/KrakenDatabase" --threads $CORES --confidence 0.5 "$TRIMS/${iso}_orphans.fastq" --output "$KRAKEN/KrakenResults/${iso}_orphans.output" --report "$KRAKEN/KrakenReports/${iso}_orphans.report"
done

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$SPADES" "$SPADES/logs"

exec > >(tee "$SPADES/logs/Spades.sh.log") 2>&1

module load miniconda
source activate "$ENVS/spades_env"

for iso in "${ISOLATES_ILL[@]}"
do
    spades.py -1 "$KRAKEN/KrakenExcludes/${iso}_clean_R1.fastq" -2 "$KRAKEN/KrakenExcludes/${iso}_clean_R2.fastq" -s "$KRAKEN/KrakenExcludes/${iso}_clean_orphans.fastq" -o "$SPADES/${iso}" -t $CORES --isolate
done

conda deactivate
exit 0
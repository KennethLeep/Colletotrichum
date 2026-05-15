#!/bin/bash

set -e
source config.sh
mkdir -p "$BLOB" "$BLOB/logs"

exec > >(tee "$BLOB/logs/BlobTools.sh.log") 2>&1

module load miniconda
source activate "$ENVS/btk_env"

mkdir -p "$BLOB/taxdump"
curl -L ftp://ftp.ncbi.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz | tar xzf - -C "$BLOB/taxdump"

for iso in ${ISOLATES_ILL[@]}
do
    blobtools create --fasta "$FUN2CLEAN/${iso}sorted.fa" --taxdump "$BLOB/taxdump" "$BLOB/${iso}_blobdir"
    blobtools add --cov "$BAM/${iso}_mapped.bam" "$BLOB/${iso}_blobdir"
    blobtools view --view blob --plot "$BLOB/${iso}_blobdir"
    blobtools filter --table "$BLOB/${iso}_summary.tsv" "$BLOB/${iso}_blobdir"
done

conda deactivate
exit 0
#!/bin/bash

set -e
source config.sh
mkdir -p "$BLOBEXCLUDE" "$BLOB/logs"
exec > >(tee "$BLOB/logs/BlobExcluder.sh.log") 2>&1

module load miniconda
source activate "$ENVS/btk_env"

iso=GCC14

cp "$FUN2CLEAN/${iso}sorted.fa" "$BLOBEXCLUDE/${iso}sorted.fa"

blobtools filter --param ${iso}_mapped_cov--Min=30 --fasta "$BLOBEXCLUDE/${iso}sorted.fa" --suffix cleaned "$BLOB/${iso}_blobdir"

blobtools filter --param ${iso}_mapped_cov--Max=30 --fasta "$BLOBEXCLUDE/${iso}sorted.fa" --suffix contam "$BLOB/${iso}_blobdir"

rm "$BLOBEXCLUDE/${iso}sorted.fa"

echo "Filtering Summary for ${iso}:"
echo "Cleaned contigs: $(grep -c ">" "$BLOBEXCLUDE/${iso}sorted.cleaned.fa")"
echo "Contaminant contigs: $(grep -c ">" "$BLOBEXCLUDE/${iso}sorted.contam.fa")"

conda deactivate
exit 0
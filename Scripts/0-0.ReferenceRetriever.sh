#!/bin/bash

set -e
source config.sh
mkdir -p "$REFS" "$REFS/logs" "$ASSEMBLIES"

module load miniconda
source activate "$ENVS/ncbidata_env"
exec > >(tee "$REFS/logs/ReferenceRetriever.sh.log") 2>&1

for ref in "${REFIDS[@]}"
do
    STRAINID=$(datasets summary genome accession ${ref} --as-json-lines | dataformat tsv genome --fields organism-infraspecific-strain | tail -n +2 | tr -d '-')
    datasets download genome accession ${ref} --include genome,gff3 --filename "$REFS/${ref}.zip"
    unzip "$REFS/${ref}.zip" -d "$REFS/${ref}"
    rm "$REFS/${ref}.zip"
    cp "$REFS/${ref}/ncbi_dataset/data/${ref}/${ref}"*".fna" "$REFS/${STRAINID}.fa"
    GFF_SOURCE="$REFS/${ref}/ncbi_dataset/data/${ref}/genomic.gff"
    if [[ -f "$GFF_SOURCE" ]]; then
        cp "$GFF_SOURCE" "$REFS/${STRAINID}.gff"
    else
        echo "Note: No GFF found for $ref ($STRAINID). Skipping GFF copy."
    fi
    echo "$STRAINID" > "$REFS/references.txt"
done

for ref in "${TOPREFS[@]}"
do
    cp "$REFS/${ref}.fa" "$REFS/${SPECIES_MAP[$ref]}.fa"
done

for ref in "$REF_LIST"
do
    cp "$REFS/${ref}.fa" "$ASSEMBLIES/${ref}.fa"
done

conda deactivate
exit 0

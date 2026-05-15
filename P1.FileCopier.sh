#!/bin/bash

source config.sh

module load miniconda
source activate "$ENVS/ncbidata_env"
mkdir -p "$PAN"

cd "$PAN"

datasets download genome taxon "Colletotrichum" --filename colletotrichum_dataset.zip

unzip colletotrichum_dataset.zip

FOLDERLOC="$PAN/ncbi_dataset/data"

FOLDERLIST=( $(ls -d "$FOLDERLOC"/*/ | xargs -n 1 basename) )

mkdir -p "$PAN/singlesource"

dataformat tsv genome --inputfile "$FOLDERLOC/assembly_data_report.jsonl" --fields accession,organism-name > "$PAN/species_master.tsv"

declare -A ACC_2_SPEC

while IFS=$'\t' read -r accession name; do
    clean_name="${name// /_}"
    ACC_2_SPEC["$accession"]="$clean_name"
done < <(tail -n +2 "$PAN/species_master.tsv")

for folder in "${FOLDERLIST[@]}"
do
    species="${ACC_2_SPEC[$folder]}"
    cp "$FOLDERLOC/${folder}/${folder}"*.fna "$PAN/singlesource/${species}_${folder}.fna"
done

conda deactivate
exit 0
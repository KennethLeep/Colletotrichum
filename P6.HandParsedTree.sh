#!/bin/bash

set -e
source config.sh

module load miniconda
source activate "$ENVS/mashtree_env"

rm -rf "$MASH/HandParsed" && mkdir -p "$MASH/HandParsed"

HANDLIST=(GCA_014705415 GCA_000350065 GCF_026319165 GCF_030867785 GCF_000319635 GCA_011947485 GCA_026740055 GCA_018853505 GCA_032988895 GCA_049996515 GCA_014705345 GCA_014705405 GCA_014705055 GCA_047496625 GCA_011947465 GCA_011426385 GCA_027942835 GCA_020226115 GCF_013390185 GCA_026319135 GCF_026319265 GCA_045514765 GCA_000446055)

FILELIST=( $(ls "$PANCLEAN/"*".fasta") )

for file in "${FILELIST[@]}"
do
    for access in "${HANDLIST[@]}"; do
        if [[ "$file" == *"$access"* ]]; then
        cp $file "$MASH/HandParsed"
        fi
    done
done

for iso in "${ISOLATES[@]}"
do
    cp "$PANCLEAN/${iso}sorted.fasta" "$MASH/HandParsed/${iso}.fasta"
done

mkdir -p "$MASH/HandTree"
mashtree --numcpus $CORES --sketch-size 10000 --outmatrix "$MASH/HandTree/Colletotrichum_Hand_Parsed.tab" "$MASH/HandParsed/"*".fasta" > "$MASH/HandTree/Colletotrichum_Hand_Parsed.dnd"

conda deactivate
exit 0
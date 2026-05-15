#!/bin/bash

source config.sh
mkdir -p "$PANCLEAN" "$PANCLEAN/logs"

module load miniconda
source activate "$ENVS/funannotate2_env"

RAW_FILENAMES=( "$PAN/singlesource/"*.fna )
FILENAMES=()

for entry in "${RAW_FILENAMES[@]}"
do
    base_name=$(basename "$entry")
    if [ ! -f "$PANCLEAN/${base_name}.fa" ]; then
    FILENAMES+=("$entry")
    fi
done

for file in "${FILENAMES[@]}"
do
    base=$(basename "$file")
    echo "Processing $base"
    funannotate2 clean -f "${file}" -o "$PANCLEAN/${base}.fa" -m 1000 -r "Contig_" --cpus 30 --exhaustive --logfile "$PANCLEAN/logs/${base}.log"
    echo "Processing for $base complete"
done

for iso in "${ISOLATES[@]}"
do
    cp "$FUN2CLEAN/${iso}sorted.fa" "$PANCLEAN/${iso}sorted.fasta"
done

for f in "$PANCLEAN/"*".fna.fa"; do mv "$f" "${f%.fna.fa}.fasta"; done
for f in "$PANCLEAN/"*".1.fasta"; do mv "$f" "${f%.1.fasta}.fasta"; done
for f in "$PANCLEAN/"*".2.fasta"; do mv "$f" "${f%.2.fasta}.fasta"; done
for f in "$PANCLEAN/"*".fasta"; do
    new_f=$(echo "$f" | tr -d '()[],:;')
    if [ "$f" != "$new_f" ]; then
        mv "$f" "$new_f"
        echo "Fixed: $new_f"
    fi
done

conda deactivate
exit 0
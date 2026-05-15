#!/bin/bash

set -e
source config.sh
mkdir -p "$FASTA" "$FASTA/logs"

exec > >(tee "$FASTA/logs/FileRelocator.sh.log") 2>&1

for iso in "${ISOLATES_PB[@]}"
do
    if [[ -f "$HIFI/${iso}/all_positive_graph_nodes.fasta" ]]; then
        mv "$HIFI/${iso}/all_positive_graph_nodes.fasta" "$FASTA/${iso}PacBio_raw.fasta"
    else
        echo "You must run Bandage to manually verify integrity of PacBio assemblies first!"
        echo "After running, export confirmed file as all_positive_graph_nodes.fasta per the instructions in the ReadMe.txt!"
        exit 1
    fi
done

exit 0
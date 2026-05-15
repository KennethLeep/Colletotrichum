#!/bin/bash

set -e
source config.sh

module load miniconda
source activate "$ENVS/funannotate2_env"

for iso in "${ISOREFS[@]}"
do
    echo "EggNog Section"
    mkdir -p "$FUN2/${iso}_annotation/annotate_misc"
    f2a emapper -i "$FUN2/${iso}_annotation/" --parse "$EGG/${iso}.emapper.annotations" -o "$FUN2/${iso}_annotation/annotate_misc"
    mv "$FUN2/${iso}_annotation/annotate_misc/${iso}.annotations.txt" "$FUN2/${iso}_annotation/annotate_misc/eggnog.annotations.txt"
    sed -i 's/ID=//g; s/;//g' "$FUN2/${iso}_annotation/annotate_misc/eggnog.annotations.txt"

    echo "InterProScan Section"
    f2a iprscan -i "$FUN2/${iso}_annotation/" --parse "$IPR/$iso/${iso}_proteins_fixed.faa.tsv" -o "$FUN2/${iso}_annotation/annotate_misc"
    sed -i 's/ID=//g; s/;//g' "$FUN2/${iso}_annotation/annotate_misc/iprscan.annotations.txt"
    sed -i 's/(InterPro)//g' "$FUN2/${iso}_annotation/annotate_misc/iprscan.annotations.txt"
    sed -i '/InterPro:IPR/ s/note/db_xref/' "$FUN2/${iso}_annotation/annotate_misc/iprscan.annotations.txt"
    sed -i 's/go_term/go_terms/g' "$FUN2/${iso}_annotation/annotate_misc/iprscan.annotations.txt"

    echo "SignalP6 Section"
    f2a signalp6 -i "$FUN2/${iso}_annotation/" --parse "$SIGNAL/${iso}/prediction_results.txt" -o "$FUN2/${iso}_annotation/annotate_misc"
    sed -i 's/ID=//g; s/;//g' "$FUN2/${iso}_annotation/annotate_misc/signalp.annotations.txt"
    sed -i 's/SignalP:/SECRETED: SignalP /g' "$FUN2/${iso}_annotation/annotate_misc/signalp.annotations.txt"

    echo "antiSMASH Section"
    f2a antismash -i "$FUN2/${iso}_annotation/" --parse "$ANTI/${iso}/${iso}.gbk" -o "$FUN2/${iso}_annotation/annotate_misc"
done

conda deactivate
exit 0
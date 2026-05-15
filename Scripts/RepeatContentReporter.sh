#!/bin/bash

set -e
source config.sh

exec > >(tee "$REPEAT/logs/RepeatContentReporter.sh.log") 2>&1
CONTIGS=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)

for iso in "${ISOLATES_PB[@]}"
do
    echo "Counting isolate: $iso"
    for contig in "${CONTIGS[@]}"
    do
        echo "Counting contig: ${iso}_${contig}"
        grep -c "${iso}_${contig}" "$REPEAT/${iso}/${iso}sorted.fa.out.gff"
    done
done

exit 0
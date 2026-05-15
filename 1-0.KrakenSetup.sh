#!/bin/bash

set -e
source config.sh
mkdir -p "$KRAKEN" "$KRAKEN/logs" "$KRAKEN/KrakenResults" "$KRAKEN/KrakenReports" "$KRAKEN/KrakenDatabase" "$KRAKEN/KrakenExcludes"

exec > >(tee "$KRAKEN/logs/KrakenSetup.sh.log") 2>&1

wget -O "$KRAKEN/KrakenDatabase/pluspf.tar.gz" https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_20251015.tar.gz
tar -xzvf "$KRAKEN/KrakenDatabase/pluspf.tar.gz" -C "$KRAKEN/KrakenDatabase"
rm "$KRAKEN/KrakenDatabase/pluspf.tar.gz"

exit 0
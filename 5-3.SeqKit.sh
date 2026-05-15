#!/bin/bash

set -e
source config.sh
mkdir -p "$SEQK" "$SEQK/logs"

module load miniconda
source activate "$ENVS/cleanup_env"

exec > >(tee "$SEQK/logs/SeqKit.sh.log") 2>&1

echo "h1tg000018l h1tg000019l h1tg000020l h1tg000021l h1tg000022l h1tg000023l h1tg000024l h1tg000025l h1tg000026l h1tg000027l h1tg000028l h1tg000029l h1tg000030l h1tg000031l h1tg000032l h1tg000033l h1tg000034l h1tg000035l h1tg000036l h1tg000037l h1tg000038l h1tg000039l h1tg000040l h1tg000041l h1tg000042l" | tr ' ' '\n' > "$SEQK/GCC14PB_excludes.txt"

seqkit grep -v -r -f "$SEQK/GCC14PB_excludes.txt" "$FASTA/GCC14PBPacBio_raw.fasta" > "$SEQK/GCC14PBPacBio_clean.fasta"

echo "h1tg000013l h1tg000023l h1tg000025l h1tg000026l h1tg000027l h1tg000028l h1tg000029l h1tg000030l h1tg000031l h1tg000032l h1tg000033l h1tg000034l h1tg000035l h1tg000049l h1tg000050l h1tg000051l h1tg000052l h1tg000053l h1tg000055l h1tg000061l h1tg000062l h1tg000063l h1tg000067l h1tg000068l h1tg000069l h1tg000070l h1tg000072l h1tg000074l h1tg000076l h1tg000012l h1tg000020l h1tg000021l h1tg000022l h1tg000036l h1tg000037l h1tg000038l h1tg000039l h1tg000040l h1tg000041l h1tg000042l h1tg000043l h1tg000044l h1tg000045l h1tg000046l h1tg000047l h1tg000048l h1tg000054l h1tg000056l h1tg000057l h1tg000058l h1tg000059l h1tg000060l h1tg000064l h1tg000065l h1tg000066l h1tg000071l h1tg000073l h1tg000075l" | tr ' ' '\n' > "$SEQK/GCC05PB_excludes.txt"

seqkit grep -v -r -f "$SEQK/GCC05PB_excludes.txt" "$FASTA/GCC05PBPacBio_raw.fasta" > "$SEQK/GCC05PBPacBio_clean.fasta"

conda deactivate
exit 0
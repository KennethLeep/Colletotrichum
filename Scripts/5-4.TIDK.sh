#!/bin/bash

set -e
source config.sh
mkdir -p "$TIDK" "$TIDK/logs"

module load miniconda
source activate "$ENVS/cleanup_env"

exec > >(tee "$TIDK/logs/TIDK.sh.log") 2>&1

#build the tidk database
tidk build

#first, confirm the actual telomeric repeat sequence is standard; you need perform this on only a single isolate per species
tidk explore --minimum 5 --maximum 12 --threshold 10 "$SEQK/GCC05PBPacBio_clean.fasta"

#find where in the source file the repeats occur; edit the --string field with the exact repeat sequence you determined was your telomeric repeat in the step above
for iso in "${ISOLATES_PB[@]}"
do
    tidk search --string TTAGGG --output counts --dir $TIDK --extension tsv "$SEQK/${iso}PacBio_clean.fasta"
done

#use the information in <isolate>counts.tsv, the output of the above step, to determine where specifically to "cut" any internal telomeres, if present; you will need a separate command for each cut, use the model below for each cut
#once chimeric telomeric repeats located on contig 4 and the precise coordinates, separate out the contig into 2 separate files
samtools faidx "$SEQK/GCC05PBPacBio_clean.fasta" "NODE_h1tg000004l_length_11215123_cov_1:1-4341835" > "$TIDK/GCC05PBChrom4a.fasta"
samtools faidx "$SEQK/GCC05PBPacBio_clean.fasta" "NODE_h1tg000004l_length_11215123_cov_1:4341836-11215123" > "$TIDK/GCC05PBChrom4b.fasta"

#re-run the search to ensure the new contigs are now T2T; if not, you may need to adjust your cut location above
tidk search --string TTAGGG --output chromAcounts.tsv --dir $TIDK --extension tsv "$TIDK/GCC05PBChrom4a.fasta"
tidk search --string TTAGGG --output chromBcounts.tsv --dir $TIDK --extension tsv "$TIDK/GCC05PBChrom4b.fasta"

#extract the good contigs from the clean file, leaving out the chimeric contig(s); this creates the list for the next script
grep ">" "$SEQK/GCC05PBPacBio_clean.fasta" | sed 's/>//' | grep -v "NODE_h1tg000004l_length_11215123_cov_1" > "$TIDK/good_contigs.list"

#this script uses the list generated in the previous step to create a new, edited fasta that contains only those contigs that DO NOT need to be clipped; use this model to produce your own fasta - you will need one run of this script per isolate that needs cutting
samtools faidx "$SEQK/GCC05PBPacBio_clean.fasta" -r "$TIDK/good_contigs.list" > "$TIDK/original_clean_minus_4.fasta"

#and recombine the split contigs with the newly generated clean fasta using the model below
cat "$TIDK/original_clean_minus_4.fasta" "$TIDK/GCC05PBChrom4a.fasta" "$TIDK/GCC05PBChrom4b.fasta" > "$TIDK/GCC05PB_TIDK.fasta"

#to accommodate downstream scripts, all isolates must "pass" through this process, so for those that do not need any editing based on the scan results showing no internal telomeres, simply run the command below once for each to allow each to be copied and renamed
cp "$SEQK/GCC14PBPacBio_clean.fasta" "$TIDK/GCC14PB_TIDK.fasta"

#lastly, this command outputs and unifies the PacBio assemblies with the (if done) Illumina assemblies in the /Assemblies folder for the annotation steps

for iso in "${ISOLATES_PB[@]}"
do
    cp "$TIDK/${iso}_TIDK.fasta" "$ASSEMBLIES/${iso}.fa"
done


conda deactivate
exit 0
#!/bin/bash

echo "Beginning Clean_Proteome.sh"

set -e
source config.sh
mkdir -p "$EVIDENCE" "$EVIDENCE/CPi" "$EVIDENCE/logs"

module load miniconda
source activate "$ENVS/cleanup_env"

exec > >(tee "$EVIDENCE/logs/Clean_Proteome.sh.log") 2>&1

echo "Starting cleaning process:"

echo "Combining protein files"
echo "Input files concatenated:"
ls $RAW/Proteomes/*.faa
cat $RAW/Proteomes/*.faa > $EVIDENCE/CPi/combined_proteins.faa

echo "Beginning basic filtering phase"
echo "Documenting software versions used:"
cd-hit -v | head -n 1
hmmsearch -h | grep HMMER
seqkit version

echo "Documenting total sequences in source files:"
seqkit stats $EVIDENCE/CPi/combined_proteins.faa

echo "SeqKitting files to remove exact duplicates"
seqkit rmdup -s $EVIDENCE/CPi/combined_proteins.faa > $EVIDENCE/CPi/seqkitoutput1.faa
echo "Documenting count of hits removed:"
seqkit stats $EVIDENCE/CPi/seqkitoutput1.faa

echo "CD-Hitting files at 90% homology"
cd-hit -i $EVIDENCE/CPi/seqkitoutput1.faa -o $EVIDENCE/CPi/clustered_90.faa -c 0.9 -n 5 -M 0 -T $CORES
echo "Documenting count of hits removed:"
seqkit stats $EVIDENCE/CPi/clustered_90.faa

echo "CD-Hitting files at 60% homology"
cd-hit -i $EVIDENCE/CPi/clustered_90.faa -o $EVIDENCE/CPi/clustered_60.faa -c 0.6 -n 4 -M 0 -T $CORES
echo "Documenting count of hits removed:"
seqkit stats $EVIDENCE/CPi/clustered_60.faa
echo "CD-Hit phase completed."

echo "Beginning HMMER phase"
echo "Running HMMER search"
hmmsearch --cpu $CORES --tblout "$EVIDENCE/CPi/pfam_hits.tblout" "$DBS/pfam_db/Pfam-A.hmm" "$EVIDENCE/CPi/clustered_60.faa" > /dev/null
echo "Extracting results"
grep -v "^#" "$EVIDENCE/CPi/pfam_hits.tblout" | grep -Ei "transposase|reverse transcriptase|integrase|gag|pol|retrotransposon|hobo|mariner|gypsy|copia|starship|ty1|ty3|line-1|TIR|LTR|CACTA|Mutator|MULE|hAT|PIF|Harbinger|Kolobok|MITE|SINE|TRIM|LARD|Gret1|Vine-1|Vv-SINE|Grt1|Retrotrans_gag|RV_residue|RVT_1|Integrase_H2C2|rve|DDE_3|Mariner_TNP|Pif1|Helitron_like_N" | awk '{print $1}' | sort -u > $EVIDENCE/CPi/transposon_ids.txt
echo "Running seqkit grep"
seqkit grep -v -f "$EVIDENCE/CPi/transposon_ids.txt" "$EVIDENCE/CPi/clustered_60.faa > $EVIDENCE/final_clean_proteome.faa
echo "Documenting count of hits removed:"
seqkit stats $EVIDENCE/final_clean_proteome.faa

echo "Processing complete, deactivating environment"
conda deactivate
echo "Overall process complete, please see logs for details"
exit 0
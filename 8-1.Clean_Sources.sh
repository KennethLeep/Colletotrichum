#!/bin/bash

set -e
source config.sh

mkdir -p "$EVIDENCE" "$EVIDENCE/logs" "$EVIDENCE/CSi"

exec > >(tee "$EVIDENCE/logs/Clean_Sources.sh.log") 2>&1

module load miniconda
source activate "$ENVS/cleanup_env"

grep -v -i -E "transposase|reverse transcriptase|integrase|gag|pol|retrotransposon|hobo|mariner|gypsy|copia|starship|ty1|ty3|line-1|TIR|LTR|CACTA|Mutator|MULE|hAT|PIF|Harbinger|Kolobok|MITE|SINE|TRIM|LARD|Gret1|Vine-1|Vv-SINE|Grt1|Retrotrans_gag|RV_residue|RVT_1|Integrase_H2C2|rve|DDE_3|Mariner_TNP|Pif1|Helitron_like_N" "$REFS/${TRAINER}.gff3" > "$EVIDENCE/CSi/genomic_no_TE.gff3"

agat_sp_keep_longest_isoform.pl --gff "$EVIDENCE/CSi/genomic_no_TE.gff3" -o "$EVIDENCE/CSi/genomic_longest.gff3"

agat_sp_extract_sequences.pl -g "$EVIDENCE/CSi/genomic_longest.gff3" -f "$REFS/${TRAINER}.fa" -t cds -o "$EVIDENCE/CSi/cds_longest.fasta"

seqkit seq -m 150 -i "$EVIDENCE/CSi/cds_longest.fasta" | seqkit replace -p ".*" -r "gene_{nr}" > "$EVIDENCE/CSi/cds_pre_cdhit.fasta"

cd-hit-est -i "$EVIDENCE/CSi/cds_pre_cdhit.fasta" -o "$EVIDENCE/${TRAINER}_cleaned.fasta" -c 0.9 -n 8 -M 0 -T $CORES

seqkit stats "$EVIDENCE/${TRAINER}_cleaned.fasta"

conda deactivate
exit 0
#!/bin/bash
#SBATCH --job-name="Orthofinder session"
#SBATCH -p ceres
#SBATCH -N 1
#SBATCH -n 40
#SBATCH --mem=256GB
#SBATCH -t 12:00:00
#SBATCH --mail-user=kenneth.leep@usda.gov
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH -A colletotrichum_ga_625
#SBATCH -o "/project/colletotrichum_ga_625/troubleshooting/Orthofinder.stdout.log"
#SBATCH -e "/project/colletotrichum_ga_625/troubleshooting/Orthofinder.stderr.log"

set -e
source config.sh

mkdir -p "$ORTHO" "$ORTHO/logs"

module load miniconda
source activate "$ENVS/ortho_env"

for iso in "${ISOREFS[@]}"
do
    cp "$FUN2/${iso}_annotation/annotate_results/"*".proteins.fa" "$ORTHO/${iso}.proteins.fa"
done

orthofinder -t $CORES -a $CORES -f "$ORTHO"

conda deactivate
exit 0
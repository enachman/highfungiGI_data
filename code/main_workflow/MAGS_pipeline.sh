#!/bin/bash
#SBATCH --job-name=MetaWRAP
#SBATCH --mail-user=andrew.brand@bcm.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=160:00:00
#SBATCH --error ./logs/metaWRAP.e%j
#SBATCH --output ./logs/metaWRAP.o%j
#SBATCH --no-requeue


# Define directories

work_dir="/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/workflow-output/work"

# Initialize Nextflow environment

module load java/jdk-18.0.1.1

export PATH="/mount/britton/kyle/DBs/nextflow_files:$PATH"
export NXF_OPTS="-Xms500M -Xmx2G"
export NXF_ANSI_LOC=false
export NXF_CONDA_ENABLED=true
export NXF_EXECUTOR=slurm
export NXF_WORK=${work_dir}


# Initiate Nextflow job

nextflow -c MAGS_c.conf -log ./logs/nextflow.log run MAGS_n.nf -profile MAB -resume --with-trace


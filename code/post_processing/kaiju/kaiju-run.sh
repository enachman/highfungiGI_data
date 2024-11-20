#!/bin/bash
#SBATCH --job-name=kaiju
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=250G
#SBATCH --time=80:00:00
#SBATCH --error ./logs/kaiju.e%j
#SBATCH --output ./logs/kaiju.o%j

module load anaconda3/2023.03-1
source activate /mount/britton/kyle/conda_envs/kaiju_env



### Define absolute path to batch file
input_path="/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/workflow-output/BIN_REASSEMBLY"
### Define output file location.
output_dir="/mount/britton/Erika/2024-07-29-Funannotate_life-gift_batch_2/code-output/kaiju"

db_dir="/mount/britton/kyle/DBs/kaiju/nr_and_fungi"

for file in "${input_path}"/*; do
    sampName=$(basename "$file")
    for fa in "${file}/reassembled_bins/"*.fa; do
        binName=$(basename "$fa" .fa)
        echo " Processing $sampName $binName"
        echo
        mkdir -p "${output_dir}/${sampName}/${binName}"
        sub_outdir="${output_dir}/${sampName}/${binName}"
        echo " Running kaiju"
        kaiju -t "${db_dir}/nodes.dmp" -f "${db_dir}/kaiju_db_nr_euk.fmi" -i "$fa" -o "${sub_outdir}/kaiju.out"
        kaiju2table -t "${db_dir}/nodes.dmp" -n "${db_dir}/names.dmp" -r species -o "${sub_outdir}/kaiju.table" "${sub_outdir}/kaiju.out"
        echo " Converting kaiju to korona outputs"
        kaiju2krona -t "${db_dir}/nodes.dmp" -n "${db_dir}/names.dmp" -i "${sub_outdir}/kaiju.out" -o "${sub_outdir}/kaiju2krona.out"
        /mount/britton/kyle/DBs/github_repositories/krona_git/Krona/tools_unpack/bin/ktImportText -o "${sub_outdir}/kaiju.out.html" "${sub_outdir}/kaiju2krona.out"
        echo " Bin complete"
        echo
    done
done



### notes from running it command line.   Ignore this if it's working fine:

### first.  You need a lot of memory.  at least 120G, recomemded 250G.
### activate /mount/britton/kyle/conda_envs/kaiju_env
### then go to whatever location you want your output and run these four things.  the only thing you need to change is the input fasta. denoted by <sample_fasta>.
### kaiju -t /mount/britton/kyle/DBs/kaiju/nr_and_fungi/nodes.dmp -f /mount/britton/kyle/DBs/kaiju/nr_and_fungi/kaiju_db_nr_euk.fmi -i <sample_fasta>  -o kaiju.out
### kaiju2table -t /mount/britton/kyle/DBs/kaiju/nr_and_fungi/nodes.dmp -n /mount/britton/kyle/DBs/kaiju/nr_and_fungi/names.dmp -r species -o kaiju.table kaiju.out
### kaiju2krona -t /mount/britton/kyle/DBs/kaiju/nr_and_fungi/nodes.dmp -n /mount/britton/kyle/DBs/kaiju/nr_and_fungi/names.dmp -i kaiju.out -o kaiju2krona.out
### /mount/britton/kyle/DBs/github_repositories/krona_git/Krona/tools_unpack/bin/ktImportText -o kaiju.out.html kaiju2krona.out 
### This should give you a table file and a fancy krona file with results.


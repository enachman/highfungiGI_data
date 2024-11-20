#!/usr/bin/env nextflow

workflow {
    read_csv = Channel.fromPath("$params.index")
    | splitCsv( header: true )
    megahit_out = megahit(read_csv)
    binning_out = binning(megahit_out)
    bin_refinement_out = bin_refinement(binning_out)
    bin_reassembly_out = bin_reassembly(bin_refinement_out[0], bin_refinement_out[1], bin_refinement_out[2], bin_refinement_out[3])
    checkm(bin_reassembly_out)
    quast(bin_reassembly_out)
}

process megahit {
    conda '/mount/britton/kyle/conda_envs/metawrap_env'
    tag "Running megahit on $sample (Attempt #$task.attempt)"

    input:
    tuple val(sample), path(forward_kneads), path(reverse_kneads)

    output:
    val sample
    path "megahit_temp/final.contigs.fa"
    path forward_kneads
    path reverse_kneads

    script:
    
    """
    megahit -t 10 -1 ${forward_kneads} -2 ${reverse_kneads} -o ./megahit_temp
    """
}

process binning {
    conda '/mount/britton/kyle/conda_envs/metawrap_env'
    tag "Doing binning on $sample (Attempt #$task.attempt)"

    input: 
    val sample
    path contigs
    path forward_kneads
    path reverse_kneads


    output:
    val sample
    path "INITIAL_BINNING/${sample}/metabat2_bins/"
    path "INITIAL_BINNING/${sample}/maxbin2_bins/"
    path "INITIAL_BINNING/${sample}/concoct_bins/"
    path forward_kneads
    path reverse_kneads

    script:

    """
    cp ${forward_kneads} ${sample}_temp_1.fastq.gz
    cp ${reverse_kneads} ${sample}_temp_2.fastq.gz
    gzip -df ${sample}_temp_1.fastq.gz
    gzip -df ${sample}_temp_2.fastq.gz
    mkdir -p INITIAL_BINNING/${sample}
    metawrap binning --metabat2 --maxbin2 --concoct -a ${contigs} -o INITIAL_BINNING/${sample} ${sample}_temp_1.fastq ${sample}_temp_2.fastq
    rm -rf ${sample}_temp_1.fastq
    rm -rf ${sample}_temp_2.fastq
    """
}

process bin_refinement {
    conda '/mount/britton/kyle/conda_envs/metawrap_env'
    tag "adjusting contig names on $sample (Attempt #$task.attempt)"
    publishDir "${params.outdir}", mode: 'rellink'

    input:
    val sample
    path metabat2
    path maxbin2
    path concoct
    path forward_kneads
    path reverse_kneads


    output:
    val sample
    path "BIN_REFINEMENT/${sample}/metawrap_50_30_bins/"  // this must change if the parameters for -c and -x change. the file will always reflect these two.
    path forward_kneads
    path reverse_kneads
    path "BIN_REFINEMENT/${sample}/"


    script:
    
    """
    mkdir -p BIN_REFINEMENT/${sample}
    metawrap bin_refinement -c 50 -x 30 -m 190 -o BIN_REFINEMENT/${sample}/ -A ${metabat2}/ -B ${maxbin2}/ -C ${concoct}/
    """
}

process bin_reassembly {
    conda '/mount/britton/kyle/conda_envs/metawrap_env'
    tag "Running bin_reassembly on $sample (Attempt #$task.attempt)"
    publishDir "${params.outdir}", mode: 'rellink'

    input:
    val  sample
    path metawrap_bins
    path forward_kneads
    path reverse_kneads


    output:
    val sample
    path "BIN_REASSEMBLY/${sample}/reassembled_bins/"

    script:


    """
    cp ${forward_kneads} ${sample}_temp_1.fastq.gz
    cp ${reverse_kneads} ${sample}_temp_2.fastq.gz
    gzip -df ${sample}_temp_1.fastq.gz
    gzip -df ${sample}_temp_2.fastq.gz
    mkdir -p BIN_REASSEMBLY/${sample}
    metawrap reassemble_bins -c 50 -x 30 -m 190 -o BIN_REASSEMBLY/${sample} -b ${metawrap_bins} -1 ${sample}_temp_1.fastq -2 ${sample}_temp_2.fastq
    rm -rf ${sample}_temp_1.fastq
    rm -rf ${sample}_temp_2.fastq
    """
}

process checkm {
    conda '/mount/britton/kyle/conda_envs/metawrap_env'
    tag "Running checkm on $sample (Attempt #$task.attempt)"
    publishDir "${params.outdir}", mode: 'rellink'

    input:
    val  sample
    path reassembled_bins


    output:
    val sample
    path "checkm/${sample}/"

    script:


    """
    checkm lineage_wf -x fa --tab_table --reduced_tree ${reassembled_bins}/ checkm/${sample}/
    """
}

process quast {
    conda '/mount/britton/kyle/conda_envs/quast'
    tag "Running checkm on $sample (Attempt #$task.attempt)"
    publishDir "${params.outdir}", mode: 'rellink'

    input:
    val  sample
    path reassembled_bins


    output:
    val sample
    path "quast/${sample}/"

    script:


    """
    quast --no-plots -t 16 -o "quast/${sample}/" "${reassembled_bins}"/*.fa
    """
}

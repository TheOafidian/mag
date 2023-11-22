/*
 * Hostile for read removal
 */
process HOSTILE_FILTER_HOST_READS {
    tag "$meta.id"
    
    conda "bioconda::hostile=0.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singulairty_pull_docker_container ? 
    'https://depot.galaxyproject.org/singularity/hostile:0.0.2--pyhdfd78af_0':
    'quay.io/biocontainers/hostile:0.2.0--pyhdfd78af_0'}"

    publishDir "${params.outdir}/hostremoved"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.clean*.fastq.gz"), emit: host_removed
    path("versions.yml")                      , emit: versions

    script:
    def args = task.ext.args ?: ''
    def single = reads instanceof Path
    def input = single ? "--fastq1 ${reads}" : "--fastq1 ${reads[0]} --fastq2 ${reads[1]}"
    """
    hostile clean \\
     $input \\
     --threads $task.cpus \\
     $args
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hostile: \$(hostile --version ;)
    END_VERSIONS    
    """

}

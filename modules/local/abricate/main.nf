process ABRICATE_RUN {
    tag "Abricate"
    publishDir "${params.output_dir}/01_AMR_scan/abricate/", mode: 'copy'
    conda "bioconda::abricate=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'biocontainers/abricate:1.0.1--ha8f3691_1' }"


    input:
        file assembly
        
    output:
        tuple file("${assembly.baseName}.tsv"), val("abricate"), val("1.0.1"), val("2021-05-01")

    script:
    """
        abricate --threads ${params.threads} \\
        --minid ${params.min_ID} \\
        --mincov ${params.min_COV} \\
        --db ${params.abricate_db} \\
        --datadir ${params.db_dir}/abricate/  \\
        $assembly > ${assembly.baseName}.tsv
    """
}
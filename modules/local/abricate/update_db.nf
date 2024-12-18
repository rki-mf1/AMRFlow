process ABRICATE_UPDATE {
    tag 'update_abricate_db'
    publishDir "${params.db_dir}/", mode: 'copy'
    conda "bioconda::abricate=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'biocontainers/abricate:1.0.1--ha8f3691_1' }"
        
    output:
        path "abricate/${params.abricate_update_db}"
    script:
    """
        mkdir -p abricate/${params.abricate_update_db}
        abricate-get_db --db ${params.abricate_update_db} --force --dbdir abricate
    """
}
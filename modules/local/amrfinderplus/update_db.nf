process AMRFINDER_UPDATE {
    tag "update_amrfinder_db"
    publishDir "${params.db_dir}/", mode: 'copy'
    conda "bioconda::ncbi-amrfinderplus=4.0.23"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:4.0.23--hf69ffd2_0':
        'biocontainers/ncbi-amrfinderplus:4.0.23--hf69ffd2_0' }"
    
    output:
        path "amrfinder"
    script:
    """
        amrfinder_update -d amrfinder
    """
}
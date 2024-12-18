process AMRFINDER_UPDATE {
    tag "update_amrfinder_db"
    publishDir "${params.db_dir}/", mode: 'copy'
    conda "bioconda::ncbi-amrfinderplus=3.12.8"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:3.12.8--h283d18e_0':
        'biocontainers/ncbi-amrfinderplus:3.12.8--h283d18e_0' }"
    
    output:
        path "amrfinder"
    script:
    """
        amrfinder_update -d amrfinder
    """
}
process DEEPARG_UPDATE {
    tag 'update_deeparg_db'
    publishDir "${params.db_dir}/", mode: 'copy'
    conda "bioconda::deeparg=1.0.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/deeparg:1.0.4--pyhdfd78af_0' :
        'biocontainers/deeparg:1.0.4--pyhdfd78af_0' }"
    
    output:
        path "deeparg"
    script:
    """
        deeparg download_data -o deeparg
    """
}
process ABRICATE_UPDATE {
    tag 'update_abricate_db'
    publishDir "${params.db_dir}/", mode: 'copy'
    conda "bioconda::abricate=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/abricate%3A1.0.1--ha8f3691_1':
        'biocontainers/abricate:1.0.1--ha8f3691_1' }"

    input:
        path (tsv), name: "abricate/${params.abricate_update_db}/src/amr_cds.tsv"
        path (ffn), name: "abricate/${params.abricate_update_db}/src/amr_cds.ffn"

    output:
        path "abricate/${params.abricate_update_db}"
    script:
    """
        abricate-get_db --db ${params.abricate_update_db} --force --dbdir abricate

    """
}
process HAMRONIZATION_ABRICATE_RUN{
    tag "hAMRonization"
    publishDir "${params.output_dir}/02_hAMRonization/abricate/", mode: 'copy'
    conda "bioconda::hamronization=1.1.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hamronization:1.1.4--pyhdfd78af_0':
        'biocontainers/hamronization:1.1.4--pyhdfd78af_0' }"


    input:
        tuple file(tool_output), val(tool_name), val(tool_version), val(db_version)

    output:
        file("${tool_output.baseName}_abricate_standardized.tsv")
        
    script:
    """
        hamronize ${tool_name} \\
            ${tool_output} \\
            --format tsv \\
            --output ${tool_output.baseName}_abricate_standardized.tsv \\
            --analysis_software_version ${tool_version} \\
            --reference_database_version ${db_version}
    """
}

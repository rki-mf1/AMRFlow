process HAMRONIZATION_SUMMARIZE_IGS {
    tag "hAMRonization_summarize_IGS"
    publishDir "${params.output_dir}/03_hAMRonization_summarize/", mode: 'copy'
    conda "bioconda::hamronization=1.1.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hamronization:1.1.4--pyhdfd78af_0':
        'biocontainers/hamronization:1.1.4--pyhdfd78af_0' }"

    input:
        tuple val(sample_name), path(report_files)

    output:
        tuple val(sample_name), file("${sample_name}_report.json")

    script: 
    """
    hamronize summarize $report_files \\
        --summary_type json \\
        --output ${sample_name}_report.json
    """
}
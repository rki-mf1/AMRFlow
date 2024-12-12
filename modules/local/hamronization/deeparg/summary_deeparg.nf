process HAMRONIZATION_SUMMARIZE_DEEPARG {
    tag "hAMRonization_summarize deeparg"
    publishDir "${params.output_dir}/03_hAMRonization_summarize/", mode: 'copy'
    conda "bioconda::hamronization=1.1.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hamronization:1.1.4--pyhdfd78af_0':
        'biocontainers/hamronization:1.1.4--pyhdfd78af_0' }"

    input:
        path report_files
    output:
        file "summarized_report_deeparg.tsv"
        file "summarized_report_deeparg.html"
    script: 
    """
        hamronize summarize $report_files  \\
        --summary_type tsv \\
        --output summarized_report_deeparg.tsv

        hamronize summarize $report_files \\
        --summary_type interactive \\
        --output summarized_report_deeparg.html
    """
}
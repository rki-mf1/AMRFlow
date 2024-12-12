process DEEPARG_RUN { 
    tag "DeepARG"
    publishDir "${params.output_dir}/01_AMR_scan/deeparg/", mode: 'copy'
    conda "bioconda::deeparg=1.0.4"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/deeparg:1.0.4--pyhdfd78af_0' :
        'biocontainers/deeparg:1.0.4--pyhdfd78af_0' }"

    input: 
        file(assembly)
    output: 
        tuple file("${assembly.baseName}.tsv"), val("deeparg"), val("1.0.4"), val("2021-05-01")
    script:
    """
        deeparg predict -d ${params.db_dir}/deeparg \\
        --type nucl \\
        --model LS \\
        -i $assembly \\
        -o ${assembly.baseName}

        mv ${assembly.baseName}.mapping.ARG ${assembly.baseName}.tsv 
    """
}
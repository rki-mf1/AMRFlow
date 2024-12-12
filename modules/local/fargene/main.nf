process FARGENE_RUN {
    tag "fARGene"
    publishDir "${params.output_dir}/01_AMR_scan/fargene/", mode: 'copy'
    conda "bioconda::fargene=0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fargene:0.1--py27h21c881e_4' :
        'biocontainers/fargene:0.1--py27h21c881e_4' }"

    input:
        file assembly
        
    output:
        tuple file("${assembly.baseName}/hmmsearchresults/${assembly.baseName}_${params.hmm_model}-hmmsearched.out"), val("fargene"), val("0.1"), val("2021-05-01")

    script:
    """
        fargene \\
            -p ${params.threads} \\
            -i $assembly \\
            --hmm-model ${params.hmm_model} \\
            -o ${assembly.baseName}
    """
}  
process FARGENE_RUN {
    tag "fARGene"
    publishDir "${params.output_dir}/01_AMR_scan/fargene/", mode: 'copy'
    conda "bioconda::fargene=0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fargene:0.1--py27h21c881e_4' :
        'biocontainers/fargene:0.1--py27h21c881e_4' }"

    input:
        tuple val(meta), path(assembly)
        
    output:
        tuple val(meta), file("${assembly.baseName}/hmmsearchresults/${assembly.baseName}_${params.hmm_model}-hmmsearched.out"), emit: out
        path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    def VERSION = '0.1' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
        fargene \\
            $args \\
            -p $task.cpus \\
            -i $assembly \\
            --hmm-model ${params.hmm_model} \\
            -o ${assembly.baseName} \\
            --force

        cat <<-END_VERSIONS > versions.yml
        ${task.process}":
            fargene: $VERSION
        END_VERSIONS
    """
}  
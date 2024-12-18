def min_COV_amrfinder = (params.min_COV / 100).toFloat()
def min_ID_amrfinder = (params.min_ID/ 100).toFloat()

process AMRFINDER_RUN{
    tag "AMRfinderPlus"
    publishDir "${params.output_dir}/01_AMR_scan/amrfinder/", mode: 'copy'
    conda "bioconda::ncbi-amrfinderplus=3.12.8"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:3.12.8--h283d18e_0':
        'biocontainers/ncbi-amrfinderplus:3.12.8--h283d18e_0' }"

    input:
        file assembly
    output:
        tuple file("${assembly.baseName}.tsv"), val("amrfinderplus"), val("3.10.1"), val("2021-05-01")
       
    script:
    """
        if [ -n "${params.organism_amrfinder}" ]; then
            amrfinder --threads ${params.threads} \\
                --ident_min ${min_ID_amrfinder} \\
                --coverage_min ${min_COV_amrfinder} \\
                --database ${params.db_dir}/amrfinder/latest/ \\
                --organism ${params.organism_amrfinder} \\
                -n $assembly \\
                -o ${assembly.baseName}.tsv
        else
            amrfinder --threads ${params.threads} \\
                --ident_min ${min_ID_amrfinder} \\
                --coverage_min ${min_COV_amrfinder} \\
                --database ${params.db_dir}/amrfinder/latest/ \\
                -n $assembly \\
                -o ${assembly.baseName}.tsv
             
            echo "correct"
        fi
    """

    
}
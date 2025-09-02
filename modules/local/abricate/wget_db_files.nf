process ABRICATE_DOWNLOAD_DB {
    tag 'update_download_db'
    
    conda "bioconda::gnu-wget==1.18--hb829ee6_10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--hb829ee6_10':
        'biocontainers/gnu-wget:1.18--hb829ee6_10' }"
        
    output:
        path "amr_cds.tsv"  , emit: tsv
        path "amr_cds.ffn"  , emit: ffn

    script:
    """     
        wget https://ftp.ncbi.nlm.nih.gov/pathogen/Antimicrobial_resistance/AMRFinderPlus/database/latest/ReferenceGeneCatalog.txt -O amr_cds.tsv
        wget https://ftp.ncbi.nlm.nih.gov/pathogen/Antimicrobial_resistance/AMRFinderPlus/database/latest/AMR_CDS.fa -O amr_cds.ffn

    """
}
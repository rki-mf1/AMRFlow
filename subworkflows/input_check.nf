//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fasta_channel(it) }
        .set { assembly }

    emit:
    assembly                                     // channel: [ val(meta), [ reads ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

def create_fasta_channel(LinkedHashMap row) {
    // create meta map
    def organisms = ["Acinetobacter_baumannii", "Burkholderia_cepacia", "Burkholderia_mallei", "Burkholderia_pseudomallei", "Campylobacter", "Citrobacter_freundii", "Clostridioides_difficile", "Corynebacterium_diphtheriae", "Enterobacter_asburiae", "Enterobacter_cloacae", "Enterococcus_faecalis", "Enterococcus_faecium", "Escherichia", "Haemophilus_influenzae", "Klebsiella_oxytoca", "Klebsiella_pneumoniae", "Neisseria_gonorrhoeae", "Neisseria_meningitidis", "Pseudomonas_aeruginosa", "Salmonella", "Serratia_marcescens", "Staphylococcus_aureus", "Staphylococcus_pseudintermedius", "Streptococcus_agalactiae", "Streptococcus_pneumoniae", "Streptococcus_pyogenes", "Vibrio_cholerae", "Vibrio_parahaemolyticus", "Vibrio_vulnificus"]
    def meta = [:]
    meta.id         = row.sample
    meta.genus      = row.genus
    meta.species    = row.species

    // add path(s) of the fastq file(s) to the meta map
    def fasta_meta = []
    if (!file(row.fasta).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> fasta file does not exist!\n${row.fasta}"
    }

    // check if species and/or genus are suppoted by amrfinderplus
    if (row.genus+"_"+row.species in organisms){
        meta.amrfinderopt = "--organism "+ row.genus +"_"+ row.species +" --mutation_all "+ meta.id+"-mutations.tsv"
    } else if (row.genus in organisms) {
        meta.amrfinderopt = "--organism " + row.genus + " --mutation_all "+ meta.id+"-mutations.tsv"
    } else {
        meta.amrfinderopt = ""
    }

    // check if

    fasta_meta = [ meta, [ file(row.fasta) ] ]

    return fasta_meta
}

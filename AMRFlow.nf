#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SET PIPELINE PARAMETERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


// global prameter
params.assembly_dir=""
params.threads=32                               //default 32
params.output_dir = "./results"                 //default ./results
params.no_summary = false                       //default false
params.db_dir = ""
params.help = false
params.plots = false                            //default false
params.IGS = false                              //default false

// update config    
params.update = false                          
params.abricate_update_db = "ncbi"              //default ncbi

// tools 
params.run_abricate    = false
params.run_amrfinder   = false
params.run_deeparg     = false
params.run_fargene     = false

params.min_ID = 90                   //default 90%
params.min_COV = 90                  //default 90%


// ----------------abricate--------------------

params.abricate_db = "ncbi"                     //default

// ----------------amrfinder-------------------

params.organism_amrfinder = ""  //default none



// -----------------deeparg--------------------



// -----------------fARGene--------------------

params.hmm_model = "class_a"


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PARAMETERS SANITY CHECK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


Set valid_params = ['assembly_dir', 'threads', 'output_dir', 'no_summary', 'db_dir', 'update', 
                    'abricate_update_db', 'run_abricate', 'run_amrfinder', 'run_deeparg','run_fargene',
                    'abricate_db', 'min_COV', 'min_ID','organism_amrfinder', 'hmm_model','plots','IGS', 'help']



def parameter_diff = params.keySet() - valid_params
if (parameter_diff.size() != 0){
    exit 1, "ERROR: Parameter(s) $parameter_diff is/are not valid in the pipeline!\n"
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ORGANISM AMRFINDER SANITY CHECK
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def valid_organisms = ['Acinetobacter_baumannii', 'Burkholderia_cepacia', 'Burkholderia_pseudomallei', 'Campylobacter', 'Citrobacter_freundii', 'Clostridioides_difficile', 'Enterobacter_asburiae', 'Enterobacter_cloacae', 'Enterococcus_faecalis', 'Enterococcus_faecium', 'Escherichia', 'Klebsiella_oxytoca', 'Klebsiella_pneumoniae', 'Neisseria_gonorrhoeae', 'Neisseria_meningitidis', 'Pseudomonas_aeruginosa', 'Salmonella', 'Serratia_marcescens', 'Staphylococcus_aureus', 'Staphylococcus_pseudintermedius', 'Streptococcus_agalactiae', 'Streptococcus_pneumoniae', 'Streptococcus_pyogenes', 'Vibrio_cholerae', 'Vibrio_parahaemolyticus', 'Vibrio_vulnificus']

if (params.organism_amrfinder?.trim() && !valid_organisms.contains(params.organism_amrfinder)) {
    error "Set parameter not in the list. Check list here: \n\n${valid_organisms.join(', ')} \n\n or run without an organism flag if organism is not supported"
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    HELP MESSAGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


if (params.help) { exit 0, helpMSG() }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PIPELINE EXECUTION MESSAGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


log.info """\

            A M R F l o w : Genomic Antimicrobial Resistance Detection through customizable, multi-tool analyses
            = = = = = = = = = = = = = = = =     = = = = = = = = = = = = = = =    = = = = = = = = = = = = = = = =
            Input files:            $params.assembly_dir
            Output path:            $params.output_dir
            Tools:                  
                    ABRicate:       $params.run_abricate
                    AMRFinder:      $params.run_amrfinder
                    DeepARG:        $params.run_deeparg
                    fARGene:        $params.run_fargene                   
            DB Update:              $params.update            
            Abricate DB:            $params.abricate_db
            Min. Identity:          $params.min_ID
            Min. Coverage:          $params.min_COV
            Organism:               $params.organism_amrfinder 
            No Summary:             $params.no_summary
            Plots:                  $params.plots
            Threads:                $params.threads
            IGS:                    $params.IGS

            Start Time:             ${new Date().format('yyyy-MM-dd HH:mm:ss')}                  
        """


def writeLog(String message) {
    new File('run_log.txt') << message + "\n"
}

writeLog("Pipeline started at: ${new Date().format('yyyy-MM-dd HH:mm:ss')}")
writeLog("Parameters used: ${params.collect{ k, v -> "$k=$v" }.join(', ')}")

def moveReport(String reportFile, String outputDir) {
    def outputDirFile = new File(outputDir) 
    if (!outputDirFile.exists()) {
        outputDirFile.mkdirs() 
    }
    
    def timestamp = new Date().format('yyyyMMdd_HHmmss')
    def newReportFile = new File(outputDirFile, "${reportFile.split('\\.')[0]}_${timestamp}.${reportFile.split('\\.')[1]}")
    
    new File(reportFile).renameTo(newReportFile)
    println "Report moved to: ${newReportFile}"
}

moveReport('run_log.txt', params.output_dir)


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


include { ABRICATE_RUN                           } from './modules/local/abricate/main'
include { ABRICATE_UPDATE                        } from './modules/local/abricate/update_db'
include { AMRFINDER_RUN                          } from './modules/local/amrfinderplus/main'
include { AMRFINDER_UPDATE                       } from './modules/local/amrfinderplus/update_db'
include { DEEPARG_RUN                            } from './modules/local/deeparg/main'
include { DEEPARG_UPDATE                         } from './modules/local/deeparg/update_db'
include { FARGENE_RUN                            } from './modules/local/fargene/main'
include { HAMRONIZATION_ABRICATE_RUN             } from './modules/local/hamronization/abricate/main'
include { HAMRONIZATION_AMRFINDER_RUN            } from './modules/local/hamronization/amrfinder/main'
include { HAMRONIZATION_DEEPARG_RUN              } from './modules/local/hamronization/deeparg/main'
include { HAMRONIZATION_FARGENE_RUN              } from './modules/local/hamronization/fargene/main'
include { HAMRONIZATION_SUMMARIZE                } from './modules/local/hamronization/summarize/main'
include { HAMRONIZATION_SUMMARIZE_IGS            } from './modules/local/hamronization/summarize/main_IGS'
include { HAMRONIZATION_SUMMARIZE_ABRICATE       } from './modules/local/hamronization/abricate/summary_abricate'
include { HAMRONIZATION_SUMMARIZE_AMRFINDER      } from './modules/local/hamronization/amrfinder/summary_amrfinder'
include { HAMRONIZATION_SUMMARIZE_DEEPARG        } from './modules/local/hamronization/deeparg/summary_deeparg'
include { HAMRONIZATION_SUMMARIZE_FARGENE        } from './modules/local/hamronization/fargene/summary_fargene'
include { PRESENCE_ABSENCE as PA_1               } from './modules/local/summary/presence_absence'
include { PRESENCE_ABSENCE as PA_2               } from './modules/local/summary/presence_absence'
include { PRESENCE_ABSENCE as PA_3               } from './modules/local/summary/presence_absence'
include { PRESENCE_ABSENCE as PA_4               } from './modules/local/summary/presence_absence'
include { HEATMAPS as H_1                        } from './modules/local/summary/heatmap'
include { HEATMAPS as H_2                        } from './modules/local/summary/heatmap'
include { HEATMAPS as H_3                        } from './modules/local/summary/heatmap'
include { HEATMAPS as H_4                        } from './modules/local/summary/heatmap'



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


workflow{

    if(params.update){
        if (params.run_abricate){
            ABRICATE_UPDATE()
        }
        if (params.run_amrfinder){
            AMRFINDER_UPDATE()
        }
        if (params.run_deeparg){
            DEEPARG_UPDATE()
        }
    }

    else{
        
        if (!file(params.assembly_dir).exists()) {
            exit(1), "Provided assembly path does not exist or ist empty: ${params.assembly_dir}"
        }
        
        assemblies_ch = Channel.fromPath("${params.assembly_dir}/*.{fna,fa,fasta}")
        all_reports = Channel.empty()
        

        if(params.run_abricate){
            assemblies_abricate_ch = Channel.fromPath("${params.assembly_dir}/*.{fna,fa,fasta}")
            run_output_abricate = ABRICATE_RUN(assemblies_abricate_ch)
            hamronization_reports_abricate = HAMRONIZATION_ABRICATE_RUN(run_output_abricate)
            all_reports = all_reports.concat(hamronization_reports_abricate)
            
            if(params.plots){
                collective_table_abricate = HAMRONIZATION_SUMMARIZE_ABRICATE(hamronization_reports_abricate.collect())
                presence_absence_abricate = PA_1(collective_table_abricate[0], "abricate")
                H_1(presence_absence_abricate, "abricate", collective_table_abricate[0])
            }
        }

        if(params.run_amrfinder){
            assemblies_amrfinder_ch = Channel.fromPath("${params.assembly_dir}/*.{fna,fa,fasta}")
            run_output_amrfinder = AMRFINDER_RUN(assemblies_amrfinder_ch)
            hamronization_reports_amrfinder = HAMRONIZATION_AMRFINDER_RUN(run_output_amrfinder)
            all_reports = all_reports.concat(hamronization_reports_amrfinder)
           
            if(params.plots){
                collective_table_amrfinder = HAMRONIZATION_SUMMARIZE_AMRFINDER(hamronization_reports_amrfinder.collect())
                presence_absence_amrfinder = PA_2(collective_table_amrfinder[0], "amrfinder")
                H_2(presence_absence_amrfinder, 'amrfinder', collective_table_amrfinder[0])
            }
        }

        if(params.run_deeparg){
            assemblies_deeparg_ch = Channel.fromPath("${params.assembly_dir}/*.{fna,fa,fasta}")
            run_output_deeparg = DEEPARG_RUN(assemblies_deeparg_ch)
            hamronization_reports_deeparg = HAMRONIZATION_DEEPARG_RUN(run_output_deeparg)
            all_reports = all_reports.concat(hamronization_reports_deeparg)

            if(params.plots){
                collective_table_deeparg = HAMRONIZATION_SUMMARIZE_DEEPARG(hamronization_reports_deeparg.collect())
                presence_absence_deeparg = PA_3(collective_table_deeparg[0], "deeparg")
                H_3(presence_absence_deeparg, 'deeparg', collective_table_deeparg[0])
            }
        }

        if (params.run_fargene){
            assemblies_fargene_ch = Channel.fromPath("${params.assembly_dir}/*.{fna,fa,fasta}")
            run_output_fargene = FARGENE_RUN(assemblies_fargene_ch)
            hamronization_reports_fargene = HAMRONIZATION_FARGENE_RUN(run_output_fargene)
            all_reports = all_reports.concat(hamronization_reports_fargene)

            if(params.plots){
                collective_table_fargene = HAMRONIZATION_SUMMARIZE_FARGENE(hamronization_reports_fargene.collect())
                presence_absence_fargene = PA_4(collective_table_fargene[0], "fargene")
                H_4(presence_absence_fargene, 'fargene', collective_table_fargene[0])
            }
        }

        all_reports = all_reports.collect()

        if(params.IGS){

            sample_names = assemblies_ch.map {file_path ->
            file_path.getName().split("\\.")[0]}.collect()
 
            all_reports = all_reports
                .flatten()
                .map { report_path ->
                    def report_str = report_path.toString()  
                    def sample_name = report_str.split('/')[-1].split('_')[0..1].join('_')
                    tuple(sample_name, report_str)
                }
                .groupTuple(by: 0)  // Group by the sample name (first element in each tuple) 
                .filter { sample_name, reports -> sample_names.contains(sample_name) }

            HAMRONIZATION_SUMMARIZE_IGS(all_reports)
        }
    
        if(params.no_summary == false){
            HAMRONIZATION_SUMMARIZE(all_reports)
        }
    }
}

workflow.onComplete {
    writeLog("Pipeline completed at: ${new Date().format('yyyy-MM-dd HH:mm:ss')}")
}


def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    c_red = "\033[0;31m";
    log.info """
    ____________________________________________________________________________________________
    ${c_green}Engines${c_reset} (choose one):
      -profile conda
      -profile mamba
      -profile singularity
    ____________________________________________________________________________________________
    
    ${c_yellow}Usage examples:${c_reset}
    nextflow run AMRFlow.nf --assembly_dir ./fastas --output_dir ./resultsA  --run_amrfinder  --db_dir ./databases -profile conda
    nextflow run AMRFlow.nf --assembly_dir ./fastas --output_dir ./resultsB  --run_abricate --abricate_db resfinder --run_amrfinder --db_dir ./databases -profile mamba
    nextflow run AMRFlow.nf --assembly_dir ./fastas --output_dir ./resultsC  --run_abricate --abricate_db ncbi --min_COV 90 --min_ID 80 --threads 32 -profile singularity

    ${c_yellow}Setup Example:${c_reset}     |If you want to setup all tools, run this command. ${c_red}(MANDATORY)${c_reset}
                       |This should setup all tools and download their databases into one directory defined in --db_dir. 
                       |After this manditory setup, the pipeline can be use.

    ${c_dim}nextflow run AMRFlow.nf --update --run_amrfinder --run_deeparg --run_abricate --abricate_update_db ncbi --db_dir ./databases -profile conda${c_reset}


    ${c_yellow}Input:${c_reset}             |Provide path to the Input directory.

    ${c_green}--assembly_dir${c_reset}                  Path to a directory containing fasta files (.fna .fasta  .fa) needs to be specified. 
                                    Single fasta mode is not implemented yet.
                                    ${c_dim}(check terminal output if path is correctly assigned)${c_reset}

    ${c_green}--db_dir${c_reset}                        Path to the databases direcory needs to be set. 
                                    The database folder that was initialized during the setup of AMRFlow has a specific folder structure. 
                                    The folder structure in more detail can be found in our git. 
                                    It is ${c_red}mandatory${c_reset} to set the full path to the ${c_red}global${c_reset} database directory.
                                    Here is an example: 
                                    ${c_dim}databases/
                                    ├── abricate/
                                    │   ├── ncbi
                                    │   ├── resfinder
                                    │   └── ...
                                    ├── amrfinder/
                                    │   └── database files
                                    └── deeparg/
                                        └── database files${c_reset}
                                    The defined path should only go to the global databases directory and not go into the sub-directories, as shown: 
                                    ${c_dim}--db_dir /full/path/to/databases${c_reset}


    ${c_yellow}Output:${c_reset}            |Provide path to output directory.

    ${c_green}--output_dir${c_reset}                    Specifies the path where the output will be stored
                                    ${c_dim}default is /results${c_reset}

    ${c_yellow}Tool Setup:${c_reset}        |This step is ${c_red}mandatory${c_reset} for setting up tools and their individual databases. 
                       |For instructions, visit the Git Reposetory.

    ${c_green}--update${c_reset}                        This flag updates and downloads the database for every tool specified. 

                                    When ever --update and --run_abricate is specified, --abricate_update_db 
                                    needs to also be specified. This can be used as follows:
                                    ${c_dim}nextflow run AMRFinder.nf --update \\
                                            --run_abricate \\
                                            --abricate_update_db ncbi \\
                                            --run_amrfinder \\
                                            --run_deeparg \\
                                            --db_dir ./databases \\
                                            -profile conda ${c_reset}
    
    ${c_green}--abricate_update_db${c_reset}            When ABRicate is initialized, the wanted database supported by ABRicate needs to be specified. 
                                    Note: Not every database used with ABRicate is still maintained. 
                                    The following options are tested and do work with this pipeline:
                                    ${c_dim}--update --run_abricate --abricate_update_db ncbi
                                    --update --run_abricate --abricate_update_db resfinder
                                    --update --run_abricate --abricate_update_db vfdb
                                    ${c_reset}

    ${c_yellow}Tools:${c_reset}             |When running AMRFlow, no tools are defined as default. Include one or multiple of these flaggs.
                                   
    ${c_green}--run_abricate${c_reset}                 If set, Abricate will run with default parameters (Min Identity 90, Min Coverage 90)
    ${c_green}--run_amrfinder${c_reset}                If set, AMRfinder will run with default parameters (Min Identity 90, Min Coverage 90)
    ${c_green}--run_amrfinder${c_reset}                If set, DeepARG will run with default parameters                              
    ${c_green}--run_fargene${c_reset}                  If set, fARGene will run with default parameters (--hmm_model class_A)
                                    ${c_dim}supported are all models fARGene support. Please look at their git ${c_reset}
    
    ${c_yellow}Tool Prams:${c_reset}       |Some tools have specific parameters that can be set.

    ${c_green}--min_ID${c_reset}               Minimum identity can be set [0-100]               
    ${c_green}--min_COV${c_reset}              Minimum coverage can be set [0-100]
    ${c_green}--organism_amrfinder${c_reset}            Organism specific mutations identification 
                                    ${c_dim}(see list of amrfinderplus in git)${c_reset}
    ${c_green}--hmm_model_fargene${c_reset}             Setup model for antibiotic class specific amr detection
                                    ${c_dim}(see models and descriptions at fARGene git)${c_reset}
    ${c_green}--no_summary${c_reset}                       Set to summarize all hAMRonization reports into one.

   
    Thank you for using AMRFlow.
    """.stripIndent()
}

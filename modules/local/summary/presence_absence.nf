process PRESENCE_ABSENCE {
    tag "Presence Absence Table"
    conda "envs/presence_absence.yaml"
    publishDir "${params.output_dir}/03_hAMRonization_summarize/", mode: 'copy'
    input:
        file(summary_table) 
        val(tool_name)
    output:
        path "presence_absence_${tool_name}.csv" 

    script:
    """
        #!/usr/bin/env python

        import pandas as pd
        import sys


        input_file = '${summary_table}'
        output_file = 'presence_absence_${tool_name}.csv'
        data = pd.read_csv(input_file, sep='\t') 

        pivot_table = data.pivot_table(index='input_file_name', columns='gene_symbol', 
                                        aggfunc='size', fill_value=0)

        pivot_table.to_csv(output_file)
    """
}
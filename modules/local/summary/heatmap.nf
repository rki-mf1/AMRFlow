process HEATMAPS {
    tag "heatmaps plotting"
    conda "envs/heatmap_R.yaml"
    publishDir "${params.output_dir}/04_visualizations/", mode: 'copy'
    input:
        path(presence_absence)
        val(tool_name)
        path(summary_file)
    output:
        file "heatmap_Genes_${tool_name}.pdf" 
        file "heatmap_AB_Class_${tool_name}.pdf"

    script:
    """
    Rscript $baseDir/bin/heatmap_Genes.r ${presence_absence} heatmap_Genes_${tool_name}.pdf
    Rscript $baseDir/bin/heatmap_AB_Class.r ${summary_file} heatmap_AB_Class_${tool_name}.pdf
    """
}


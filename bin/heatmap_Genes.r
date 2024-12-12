#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(tidyr)

args <- commandArgs(trailingOnly = TRUE)
input_file_path <- args[1]
output_file_path <- args[2]

data <- read.csv(input_file_path)

if ("input_file_name" %in% names(data) && sum(names(data) != "input_file_name") > 0) {
  data_long <- pivot_longer(data, cols = -input_file_name, names_to = "gene_symbol", values_to = "presence")

  plot_heatmap <- function(df) {
    gene_count <- length(unique(df$gene_symbol))
    sample_count <- length(unique(df$input_file_name))
    
    if (gene_count == 0 || sample_count == 0) {
      return(NULL)  # Return NULL if no genes or samples
    }

    width <- max(8, sample_count / 5) # PLot dimensions dynamically adjusted
    height <- max(6, gene_count / 5)

    p <- ggplot(df, aes(x = input_file_name, y = gene_symbol, fill = factor(presence))) +
      geom_tile(color = "white") +
      scale_fill_manual(values = c("0" = "yellow", "1" = "purple"),
                        labels = c("Absent" = "yellow", "Present" = "purple")) +
      labs(title = "Presence/Absence Heatmap",
           x = "Sample Name",
           y = "Gene Symbol",
           fill = "Gene Presence") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1),
            axis.text.y = element_text(),
            plot.title = element_text(size = 14))
    return(list(plot = p, width = width, height = height))
  }

  result <- plot_heatmap(data_long)
  if (!is.null(result)) {
    pdf(output_file_path, width = result$width, height = result$height)
    print(result$plot)
    dev.off()
  } else {
    pdf(output_file_path)
    dev.off()
  }

} else {
  pdf(output_file_path)
  dev.off()
}

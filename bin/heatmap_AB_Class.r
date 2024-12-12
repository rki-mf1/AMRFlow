library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
input_file_path <- args[1]
output_file_path <- args[2]

# Read the TSV file
data <- read.csv(input_file_path, sep = "\t")

# Extract and count occurrences
drug_data <- data %>%
  select(input_file_name, drug_class) %>%
  drop_na() %>%
  mutate(
    drug_class = str_replace_all(drug_class, fixed("/"), ";")  # Convert all '/' to ';' for uniformity
  ) %>%
  separate_rows(drug_class, sep = ";") %>%
  group_by(input_file_name, drug_class) %>%
  summarise(count = n(), .groups = 'drop')

# Pivot to a wide format suitable for heatmapping
drug_matrix <- drug_data %>%
  pivot_wider(names_from = drug_class, values_from = count, values_fill = list(count = 0))

# Calculate dimensions for the output based on the unique number of samples and drug classes
sample_count <- length(unique(drug_matrix$input_file_name))
gene_count <- length(drug_matrix) - 1  # Subtracting one for the input_file_name column

# Convert to long format for plotting
drug_long <- pivot_longer(drug_matrix, cols = -input_file_name, names_to = "drug_class", values_to = "count")

# Check if there are no drug classes or samples before plotting
if (sample_count == 0 || gene_count == 0) {
  pdf(output_file_path, width = 1, height = 1)  # Create an empty PDF
  dev.off()
} else {
  # Plotting the heatmap
  plot_heatmap <- function(df, width, height) {
    p <- ggplot(df, aes(x = input_file_name, y = drug_class, fill = count)) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "yellow", high = "purple") +
      labs(title = "Count of Drug Resistance Genes by Class",
           x = "Sample Name",
           y = "Drug Class",
           fill = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 10),
            axis.text.y = element_text(size = 10),
            plot.title = element_text(size = 14))
    return(p)
  }

  # Open a PDF device with dynamic dimensions
  width_adjusted <- max(8, sample_count / 5)
  height_adjusted <- max(6, gene_count / 5)
  pdf(output_file_path, width = width_adjusted, height = height_adjusted)
  p <- plot_heatmap(drug_long, width_adjusted, height_adjusted)
  print(p)
  dev.off()
}

library(ggplot2)

# Read column names from text file
args <- commandArgs(trailingOnly = TRUE)
column_names <- readLines(args[1])
#column_names <- readLines("columns.txt")
column_names <- gsub("%", ".", column_names)

# Read your data from a TSV file (assuming your data is in a TSV file named 'data.tsv')
data <- read.table(args[2], header = TRUE, sep = "\t")

# Keep specified columns
selected_columns <- c(column_names, "dataset")
filtered_data <- data[, selected_columns]

# Create a list to store ggplot objects for each column
ggplot_objects <- lapply(column_names, function(col_name) {
  ggplot(filtered_data, aes(x = dataset, y = .data[[col_name]], fill = dataset)) +
    geom_boxplot(alpha = 0.7, position = position_dodge(width = 0.75)) +
    geom_point(aes(y = .data[[col_name]]), 
               position = position_jitterdodge(dodge.width = 0.75), 
               shape = 16, size = 3, color = "black") +
    labs(title = paste("Boxplot for", col_name, "by Dataset"),
         x = "Dataset", y = col_name) +
    theme_minimal() +
    scale_fill_manual(values = rainbow(length(unique(filtered_data$dataset))))
})

# Save individual ggplot boxplots as JPEG images
for (i in 1:length(ggplot_objects)) {
  col_name <- column_names[i]
  output_file <- paste0(gsub(" ", "_", tolower(col_name)), "_boxplot.jpeg")
  ggsave(output_file, ggplot_objects[[i]], width = 8, height = 6)
}

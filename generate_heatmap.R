library(ggplot2)
library(reshape2) 
library(dplyr)
library(tidyr)
args <- commandArgs(trailingOnly = TRUE)

# Read the column names from the text file
column_names <- readLines(args[1])
#column_names <- readLines("/home/ctuni/columns.txt")
column_names <- gsub("%", ".", column_names)


data <- read.table(args[2], header = TRUE, sep = "\t")
#data <- read.table("QC_table_all.tsv", header = TRUE, sep = "\t")

# Ensure 'dataset' and 'sample' are included
essential_columns <- c("dataset", "Sample")
columns_to_keep <- unique(c(essential_columns, column_names))

# Filter the dataframe to keep only the required columns
filtered_data <- data[, columns_to_keep]
filtered_data_unique <- unique(filtered_data)

# Calculate the median value for each dataset across the columns
median_data <- filtered_data_unique %>%
  group_by(dataset) %>%
  summarize(across(all_of(column_names), median, na.rm = TRUE)) %>%
  pivot_longer(cols = -dataset, names_to = "metric", values_to = "value")

# Normalize the value column within each metric
median_data <- median_data %>%
  group_by(metric) %>%
  mutate(value_scaled = (value - min(value, na.rm = TRUE)) / 
           (max(value, na.rm = TRUE) - min(value, na.rm = TRUE)))

# Reshape the data to wide format for plotting
wide_data <- dcast(median_data, metric ~ dataset, value.var = "value_scaled")

# Creating the heatmap with scales normalized for each metric
heatmap_plot <- ggplot(melt(wide_data), aes(x = variable, y = metric, fill = value)) + 
  geom_tile() + 
  scale_fill_gradient(low = "blue", high = "red") +
  theme_minimal() +
  labs(x = "Dataset", y = "Metric", fill = "Scaled Value")

# Save the plot as a high-quality PNG file with rotated x-axis labels
png("heatmap_plot.png", width = 2600, height = 1200, res = 300)
heatmap_plot <- heatmap_plot + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(heatmap_plot)
dev.off()

# # Reshape the dataframe to wide format for plotting
# wide_data <- dcast(median_data, metric ~ dataset, value.var = "value")
# # Creating the transposed heatmap
# ggplot(melt(wide_data), aes(x = variable, y = metric, fill = value)) + 
#   geom_tile() + 
#   scale_fill_gradient(low = "blue", high = "red") +
#   theme_minimal() +
#   labs(x = "Dataset", y = "Metric", fill = "Median Value")
# 
# # Reshape the dataframe to long format
# long_data <- melt(filtered_data, id.vars = essential_columns)
# long_data_unique <- unique(long_data)
# 
# # Creating the heatmap
# ggplot(long_data, aes(x = Sample, y = variable, fill = value)) + 
#   geom_tile() + 
#   facet_grid(. ~ dataset) + 
#   scale_fill_gradient(low = "blue", high = "red") +
#   theme_minimal() +
#   labs(x = "Sample", y = "Metric", fill = "Value")

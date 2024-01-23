library(ggplot2)
library(dplyr)

# Read column names from text file
#args <- commandArgs(trailingOnly = TRUE)
#column_names <- readLines("/mnt/efs/home/jlagarde/projects/202312_cfRNA-Seq_comparison/columns.txt")
column_names <- readLines("columns.txt")
column_names <- gsub("%", ".", column_names)

# Read your data from a TSV file (assuming your data is in a TSV file named 'data.tsv')
#data <- read.table("/mnt/efs/home/jlagarde/projects/202312_cfRNA-Seq_comparison/QC_table_uniq_filtered_gen_2_new_exon.csv", header = TRUE, sep = "\t")
data <- read.table("public_samples/full_comparison/QC_table_uniq_filtered_gen_2_new_exon.csv", header = TRUE, sep = "\t")

biotype_columns <- c(    "Ala_tRNA", "Arg_tRNA", "Asn_tRNA", "Asp_tRNA", "Cys_tRNA", "Gln_tRNA", "Glu_tRNA", "Gly_tRNA", "His_tRNA", "IG_C_gene",
                         
                         "IG_C_pseudogene", "IG_D_gene", "IG_J_gene", "IG_J_pseudogene", "IG_V_gene", "IG_V_pseudogene", "IG_pseudogene", "Ile_tRNA", "Leu_tRNA", "Lys_tRNA", "Met_tRNA", "Mt_rRNA", "Mt_tRNA", "Phe_tRNA", "Pro_tRNA", "Pseudo_tRNA",
                         
                         "SeC.e._tRNA", "SeC_tRNA", "Ser_tRNA", "Sup_tRNA", "TEC", "TR_C_gene", "TR_D_gene", "TR_J_gene", "TR_J_pseudogene", "TR_V_gene", "TR_V_pseudogene", "Thr_tRNA", "Trp_tRNA", "Tyr_tRNA", "Undet_tRNA", "Val_tRNA", "lncRNA", "miRNA",
                         
                         "misc_RNA", "polymorphic_pseudogene", "processed_pseudogene", "protein_coding", "pseudogene", "rRNA", "rRNA_pseudogene", "ribozyme", "sRNA", "scRNA", "scaRNA", "snRNA", "snoRNA", "spike_in",
                         
                         "transcribed_processed_pseudogene", "transcribed_unitary_pseudogene", "transcribed_unprocessed_pseudogene", "translated_processed_pseudogene", "translated_unprocessed_pseudogene",
                         
                         "unitary_pseudogene", "unprocessed_pseudogene", "vault_RNA")

biotype_data <- data[, biotype_columns]
biotype_data$total <- rowSums(biotype_data)
biotype_data$percent_of_reads_mapping_to_spike_ins <- biotype_data$spike_in / biotype_data$total
biotype_data$percent_of_reads_mapping_to_spike_ins <- biotype_data$percent_of_reads_mapping_to_spike_ins * 100

# comparison <- data.frame (data$Sample, data$dataset, data$Exonic, biotype_data$total)
# comparison$difference <- comparison$data.Exonic - comparison$biotype_data.total
# summary(comparison$difference)
# write.csv(comparison, file = "exonic_minus_biotype.csv")

# Keep specified columns
selected_columns <- c( "Sample","dataset", column_names)
filtered_data <- data[ ,selected_columns]

filtered_data$percent_of_reads_mapping_to_spike_ins <- biotype_data$percent_of_reads_mapping_to_spike_ins
filtered_data$exonic_reads_minus_spike_ins <- filtered_data$exonic_reads_minus_spike_ins *100


result <- filtered_data %>%
  filter(percent_of_reads_mapping_to_spike_ins > 5) %>%  # Filter rows where variable1 is greater than 5
  group_by(dataset) %>%     # Group data by the 'dataset' column
  summarise(count = n())    # Count the number of rows in each group

#print(result)
table_filtered <- filtered_data %>%
  filter(percent_of_reads_mapping_to_spike_ins <= 5)

#table_filtered <- table_filtered %>% filter(dataset !='ngo') %>% filter(dataset !='exome_ibarra') %>% filter(dataset !='exome_toden') %>% filter(dataset !='exome_chalasani')

# Generate colors from the glasbey palette
num_datasets <- length(unique(table_filtered$dataset))
#glasbey_colors <- pals::glasbey(num_datasets)
table_filtered$dataset <- factor(table_filtered$dataset, levels = c("flomics_gen_1", "flomics_gen_2", "flomics_gen_3", "block", "zhu", "chen", "roskams", "ngo", "exome_ibarra", "exome_toden", "exome_chalasani", "encode_bulkRNA", "cfdna_tao_wei")) # change this vector for the real levels of your dataset variable

datasetsPalette=c("flomics_gen_1" = "#54aede", "flomics_gen_2" = "#217bab", "flomics_gen_3" = "#144d6b", "block" = "#b3b3b3", "zhu" ="#ffd633", "chen" = "#997a00", "roskams" = "#944dff",  "ngo" = "salmon", "exome_ibarra" = "#800000", "exome_toden" = "#800099", "exome_chalasani" = "#800040", "encode_bulkRNA"="#006600", "cfdna_tao_wei" ="#b32400")

datasetsLabels=c("flomics_gen_1" = "Flomics v1", "flomics_gen_2" = "Flomics v2", "flomics_gen_3" = "Flomics v3", "block" = "Block 2022", "zhu" ="Lu 2021", "chen" = "Lu 2022", "roskams" = "Roskams 2022", "ngo" = "Ngo 2018", "exome_ibarra" = "Ibarra 2020", "exome_toden" = "Toden 2020", "exome_chalasani" = "Chalasani 2021", "encode_bulkRNA"="ENCODE 2023\n(bulk RNA-Seq)", "cfdna_tao_wei" ="Wei 2020\n(cfDNA)")
column_names <- c(column_names, "percent_of_reads_mapping_to_spike_ins")

write.table(table_filtered, file="Qc_table_filtered.tsv")
# Create a list to store ggplot objects for each column
ggplot_objects <- lapply(column_names, function(col_name) {
  ggplot(table_filtered, aes(x = dataset, y = .data[[col_name]], fill = dataset)) +
    geom_boxplot(alpha = 0.3, color = datasetsPalette, position = position_dodge(width = 0.75), outlier.shape = NA ) +
    geom_point(aes(y = .data[[col_name]], color = dataset), 
               position = position_jitterdodge(dodge.width = 0.75, jitter.width = 0.8), 
               shape = 16, size = 2) +
    labs(title =  col_name,
         x = "Dataset", y = col_name) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.spacing.y = unit(0.3, 'cm')) +
    scale_x_discrete(labels=datasetsLabels)+
    scale_fill_manual(values = datasetsPalette, labels=datasetsLabels) +
    scale_color_manual(values = datasetsPalette, labels=datasetsLabels) + # Match outline colors to fill
    guides(fill = guide_legend(byrow=TRUE, override.aes = list(color = datasetsPalette))) # Override the legend

})

# Save individual ggplot boxplots as JPEG images
for (i in 1:length(ggplot_objects)) {
  col_name <- column_names[i]
  output_file <- paste0(gsub(" ", "_", tolower(col_name)), "_boxplot_with_points.pdf")
  ggsave(output_file, ggplot_objects[[i]], width = 8, height = 6)
}

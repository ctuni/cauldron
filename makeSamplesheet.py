import os
import csv

# Define the output CSV file name
output_csv = "samplesheet.csv"

# Get the current working directory as the input directory
input_directory = os.getcwd()

# Initialize a dictionary to store sample information
sample_data = {}

# Iterate over the files in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(".fastq.gz"):
        sample_name, file_type = filename.rsplit("_", 1)
        
        if file_type == "R1.fastq.gz" or file_type == "R1.fastq":
            if sample_name not in sample_data:
                sample_data[sample_name] = {"sample": sample_name, "fastq_1": filename, "fastq_2": "", "strandedness": "reverse"}
            else:
                sample_data[sample_name]["fastq_1"] = filename
        elif file_type == "R2.fastq.gz" or file_type == "R2.fastq":
            if sample_name in sample_data:
                sample_data[sample_name]["fastq_2"] = filename

# Convert dictionary values to a list for writing to CSV
data = list(sample_data.values())

# Write the data to the CSV file
with open(output_csv, 'w', newline='') as csvfile:
    csv_writer = csv.DictWriter(csvfile, fieldnames=["sample", "fastq_1", "fastq_2", "strandedness"])
    csv_writer.writeheader()
    csv_writer.writerows(data)

print(f"Samplesheet created and saved as {output_csv}")

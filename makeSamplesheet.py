import os
import csv

# Get the current working directory as the input directory
input_directory = os.getcwd()

# Define the base output CSV file name
base_output_csv = "samplesheet.csv"

# Check if samplesheet.csv already exists
existing_samplesheets = [filename for filename in os.listdir(input_directory) if filename.startswith("samplesheet") and filename.endswith(".csv")]
samplesheet_count = len(existing_samplesheets)

# Determine the output CSV file name
if samplesheet_count == 0:
    output_csv = base_output_csv
else:
    output_csv = f"samplesheet_{samplesheet_count}.csv"

# Initialize a list to store sample information
sample_data = []

# Iterate over the files in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(".fastq.gz"):
        sample_name, file_type = filename.rsplit("_", 1)
        
        # Check if the sample name already exists in the list
        existing_sample = next((sample for sample in sample_data if sample["sample"] == sample_name), None)
        if existing_sample is None:
            sample_entry = {"sample": sample_name, "fastq_1": "", "fastq_2": "", "strandedness": "reverse"}
            sample_data.append(sample_entry)
        else:
            sample_entry = existing_sample
        
        if file_type == "R1.fastq.gz":
            sample_entry["fastq_1"] = filename
        elif file_type == "R2.fastq.gz":
            sample_entry["fastq_2"] = filename

# Sort the samples alphabetically based on sample name
sample_data.sort(key=lambda x: x["sample"])

# Write the data to the CSV file
with open(output_csv, 'w', newline='') as csvfile:
    csv_writer = csv.DictWriter(csvfile, fieldnames=["sample", "fastq_1", "fastq_2", "strandedness"])
    csv_writer.writeheader()
    csv_writer.writerows(sample_data)

print(f"Samplesheet created and saved as {output_csv}")

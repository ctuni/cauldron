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

# Initialize a dictionary to store sample information
sample_data = {}

# Iterate over the files in the input directory
for filename in os.listdir(input_directory):
    if filename.endswith(("_1.fastq.gz", "_2.fastq.gz", "_R1.fastq.gz", "_R2.fastq.gz")):
        # Extract sample name and read type
        parts = filename.split("_")
        sample_name = f"{parts[0]}"
        read_type = parts[1].split(".")[0]
        fastq_file = filename
        
        # Check if the sample name already exists in the dictionary
        if sample_name not in sample_data:
            sample_data[sample_name] = {"sample": sample_name, "fastq_1": "", "fastq_2": "", "strandedness": ""}
        
        # Assign the fastq file to the correct field in the dictionary
        if read_type == "1" or read_type == "R1":
            sample_data[sample_name]["fastq_1"] = fastq_file
        elif read_type == "2" or read_type == "R2":
            sample_data[sample_name]["fastq_2"] = fastq_file

# Prompt the user for strandedness input
strandedness = input("Enter strandedness: ")

# Update the 'strandedness' field in the sample_data dictionary
for sample_entry in sample_data.values():
    sample_entry["strandedness"] = strandedness

# Convert the dictionary values to a list for writing to the CSV file
sample_list = list(sample_data.values())

# Sort the samples alphabetically based on sample name
sample_list.sort(key=lambda x: x["sample"])

# Write the data to the CSV file
with open(output_csv, 'w', newline='') as csvfile:
    csv_writer = csv.DictWriter(csvfile, fieldnames=["sample", "fastq_1", "fastq_2", "strandedness"])
    csv_writer.writeheader()
    csv_writer.writerows(sample_list)

print(f"Samplesheet created and saved as {output_csv}")

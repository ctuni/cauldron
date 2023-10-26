#!/bin/bash

# Get the current directory where the script is located
folder="$(dirname "$(readlink -f "$0")")"

# Prompt user for the value after -p option
read -p "Enter the value for -p option (default is 0.05): " p_value
p_value=${p_value:-0.05}  # Set default value to 0.05 if user input is empty

# Iterate through files ending with ".fastq.gz"
for file in "$folder"/*_1.fastq.gz; do
    # Extract prefix from the file name
    prefix=$(basename "${file}" _1.fastq.gz)
    
    # Check if corresponding "_2.fastq.gz" file exists
    if [ -e "$folder/${prefix}_2.fastq.gz" ]; then
        # Run sequit on paired-end files
        zcat ${prefix}_1.fastq.gz | seqkit sample -p ${p_value} -s 80 -o sub_${prefix}_1.fastq.gz
        zcat ${prefix}_2.fastq.gz | seqkit sample -p ${p_value} -s 80 -o sub_${prefix}_2.fastq.gz
    else
        echo "Error: ${prefix}_2.fastq.gz not found for ${prefix}_1.fastq.gz"
    fi
done

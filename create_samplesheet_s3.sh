#!/bin/bash

# Check if the required number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <S3_BUCKET_NAME> <S3_PREFIX>"
    echo "Example: $0 flomics-no-backup public_sequencing_data/chen/"
    exit 1
fi

# Extract the bucket name and prefix from the arguments
S3_BUCKET_NAME=$1
S3_PREFIX=$2

# Prompt the user for the strandedness
read -p "Enter the strandedness (forward/reverse/unstranded): " strandedness

# Validate strandedness input
if [[ $strandedness != "forward" && $strandedness != "reverse" && $strandedness != "unstranded" ]]; then
    echo "Invalid strandedness. Please enter 'forward', 'reverse', or 'unstranded'."
    exit 1
fi

# Use the AWS CLI to get the list of files from the bucket
aws_output=$(aws s3 ls "s3://$S3_BUCKET_NAME/$S3_PREFIX" --recursive)

# Start creating the samplesheet
echo "sample,fastq_1,fastq_2,strandedness" > samplesheet.csv

# Filter the output, format it, and append to the samplesheet
echo "$aws_output" | grep '_1.fastq.gz' | while read -r line; do
    # Extract the filename
    filename=$(echo $line | awk '{print $4}')
    # Extract the base sample name by stripping the prefix and the _1.fastq.gz part
    sample_name=$(basename $filename _1.fastq.gz)
    # Add the S3 path to filenames and write the line to the samplesheet
    echo "${sample_name},s3://$S3_BUCKET_NAME/$S3_PREFIX${sample_name}_1.fastq.gz,s3://$S3_BUCKET_NAME/$S3_PREFIX${sample_name}_2.fastq.gz,$strandedness" >> samplesheet.csv
done

# Output the contents of the samplesheet
cat samplesheet.csv

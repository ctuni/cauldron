#!/bin/bash

# Check if the input file is provided as a command line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Read the input file line by line and execute AWS S3 and fasterq-dump commands for each ID
input_file=$1
while IFS= read -r id; do
    # Download SRA file from AWS S3
    aws s3 cp --no-sign-request "s3://sra-pub-run-odp/sra/$id/$id" .

    # Execute fasterq-dump command with the current ID
    fasterq-dump -t /tmp/ -p -x "./$id"

    #subsample to 1M reads and gzip
    head -n 4000 ./"$id"_1.fastq | gzip > sub_"$id"_1.fastq.gz
    head -n 4000 ./"$id"_2.fastq | gzip > sub_"$id"_2.fastq.gz

    # Optional: Remove the downloaded SRA file if needed
    rm "./$id"

    echo "Processed ID: $id"
done < "$input_file"

echo "SRA download and fasterq-dump completed for all IDs in the file."

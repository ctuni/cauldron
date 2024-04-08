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

    # Compress the generated FASTQ files using gzip
    gzip ./"$id"_1.fastq ./"$id"_2.fastq

    # Optional: Remove the downloaded SRA file if needed
    rm "./$id"

    # Check integrity of gzipped files
    if gzip -t "$id"_1.fastq.gz; then
        echo "First mate of $id is okay"
        if gzip -t "$id"_2.fastq.gz; then
            echo "Second mate of $id is okay"
        else
            echo "Second mate $id is not okay" >> acc_list_failed
        fi
    else
        echo "First mate $id is not okay" >> acc_list_failed
    fi

    echo "Processed ID: $id"
done < "$input_file"

echo "SRA download and fasterq-dump completed for all IDs in the file."

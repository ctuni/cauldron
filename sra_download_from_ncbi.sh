#!/bin/bash

# Check if the input file is provided as a command line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

# Define a function to process each ID
process_id() {
    id="$1"

    # Download SRA file from NCBI
    prefetch $id

    # Execute fasterq-dump command with the current ID
    fasterq-dump -t /tmp/ -p -x "./$id"

    # Optional: Remove the downloaded SRA file if needed
    rm "./$id"
    rm "./$id"_1.fastq
    rm "./$id"_2.fastq

    echo "Processed ID: $id"
}

# Export the function so it can be used by GNU Parallel
export -f process_id

# Read the input file line by line and process IDs in parallel
input_file=$1
cat "$input_file" | parallel -j4 process_id

echo "SRA download and fasterq-dump completed for all IDs in the file."
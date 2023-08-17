#!/bin/bash

input_dir="$(pwd)"

for bam_file in "$input_dir"/*_filtered.bam; do
    if [[ -f "$bam_file" ]]; then
        base_name=$(basename "$bam_file")
        prefix="${base_name%_filtered.bam}"
        
        echo "Processing $base_name..."

        picard SamToFastq I="$bam_file" F="${base_name}_R1.fastq" F2="${base_name}_R2.fastq"
        
        gzip ${base_name}_R1.fastq
        gzip ${base_name}_R2.fastq
        
        echo "Processed $base_name."
    fi
done

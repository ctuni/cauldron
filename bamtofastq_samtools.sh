#!/bin/bash

input_dir="$(pwd)"

for bam_file in "$input_dir"/*_filtered.bam; do
    if [[ -f "$bam_file" ]]; then
        base_name=$(basename "$bam_file")
        prefix="${base_name%_filtered.bam}"
        
        echo "Processing $base_name..."
        
        samtools sort -n "$bam_file" -o "${base_name}_sorted.bam"

        samtools fastq -@ 8 "${base_name}_sorted.bam" -1 "${base_name}_R1.fastq.gz" -2 "${base_name}_R2.fastq.gz" -0 /dev/null -s /dev/null -n
        
        echo "Processed $base_name."
    fi
done

#!/bin/bash

input_dir="$(pwd)"

for bam_file in "$input_dir"/*.bam; do
    if [[ -f "$bam_file" ]]; then
        base_name=$(basename "$bam_file")
        prefix="${base_name%.bam}"

	echo "Processing $base_name..."
        
        # Step 1: Extract header
        samtools view -H "$bam_file" > tmpheader
        
        # Step 2: Filter based on condition
        samtools view "$bam_file" | awk '$9>=100' > tmp1
        
        # Step 3: Further filter based on condition
        samtools view "$bam_file" | awk '$9<=-100'> tmp2
        
        # Step 4: Concatenate header and filtered data
        cat tmpheader tmp1 tmp2 | samtools view -bS -o "${prefix}_filtered.bam" -
        
        # Clean up temporary files
        rm tmpheader tmp1 tmp2

	echo "Processed $base_name."
    fi
done

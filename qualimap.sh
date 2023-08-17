#!/bin/bash

input_dir="$(pwd)"

for bam_file in "$input_dir"/*.bam; do
    if [[ -f "$bam_file" ]]; then
        base_name=$(basename "$bam_file")
        prefix="${base_name%.bam}"
        
        echo "Processing $base_name..."
        
        qualimap rnaseq --java-mem-size=30G -bam "$bam_file" -gtf gencode.v39.annotation_tRNA_SIRV-set3.sorted.gtf -p 'strand-specific-reverse' -pe -outdir "${base_name}_qualimap_out"
        
        echo "Processed $base_name."
    fi
done

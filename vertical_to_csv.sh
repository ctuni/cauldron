#!/bin/bash

# Check if an input file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="${input_file%.txt}.csv"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

# Transform the vertical list to CSV
tr '\n' ',' < "$input_file" | sed 's/,$/\n/' > "$output_file"

echo "CSV file created: $output_file"

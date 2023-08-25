#!/bin/bash

# Prompt the user for input
echo "Which branch?"
read user_input

rm -rf test_outdir/
# Use the input as a variable
nextflow run Flomics/rnaseq -c /test_dir/test.config -params-file /test_dir/test_params.yml -r $user_input

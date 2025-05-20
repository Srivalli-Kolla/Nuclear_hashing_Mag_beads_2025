#!/bin/bash

# Exit on any error
set -e

# Load conda environment properly
source ~/miniconda3/etc/profile.d/conda.sh
conda activate cellbender

# Define base directories
base_input_dir="/home/gruengroup/srivalli/Github/Nuclear_hashing_Mag_beads_2025/data/filtered_feature_bc_matrix"
base_output_dir="/home/gruengroup/srivalli/Github/Nuclear_hashing_Mag_beads_2025/data/cellbender_processed_data"

# Define FPR values
fpr_values=(0.01 0.03 0.05 0.07 0.1)

# Compress input files if not already gzipped
for file in "matrix.mtx" "barcodes.tsv" "features.tsv"; do
    if [ ! -f "$base_input_dir/${file}.gz" ]; then
        echo "Compressing $file..."
        gzip -k "$base_input_dir/$file"
    fi
done

# Run CellBender for each FPR value
for fpr in "${fpr_values[@]}"; do
    output_dir="${base_output_dir}/${fpr}_ambient"
    mkdir -p "$output_dir"

    echo "Running CellBender (ambient) for FPR=$fpr"

    cellbender remove-background \
        --input "$base_input_dir" \
        --output "${output_dir}/${fpr}_ambient.h5" \
        --fpr "$fpr" \
        --model ambient \
        --cuda 
done
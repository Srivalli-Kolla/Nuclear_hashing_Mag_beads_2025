#!/bin/bash

# Activate the conda environment
conda activate cellbender

# Define base directories
base_input_dir="/home/gruengroup/srivalli/Github/Nuclear_hashing_Mag_beads_2025/data/filtered_feature_bc_matrix"
base_output_dir="/home/gruengroup/srivalli/Github/Nuclear_hashing_Mag_beads_2025/data/cellbender_processed_data"

# Define the FPR values
fpr_values=(0.01 0.03 0.05 0.07 0.1)

# Get the number of available CPU cores
THREADS=$(sysctl -n hw.ncpu)

# Ensure files are gzipped
for file in "matrix.mtx" "barcodes.tsv" "features.tsv"; do
    if [ ! -f "$base_input_dir/${file}.gz" ]; then
        echo "Compressing $file..."
        gzip -k "$base_input_dir/$file"
    fi
done

# Run CellBender
run_cellbender_ambient() {
    local input_dir=$1
    local fpr=$2

    local output_dir="$base_output_dir/${fpr}_ambient/"
    mkdir -p "$output_dir"

    echo "Running ambient model for $input_dir with FPR $fpr..."

    cellbender remove-background \
        --input "$input_dir" \
        --output "$output_dir/${fpr}_after_cb.h5" \
        --fpr "$fpr" \
        --model ambient \
        --cpu-threads "64"
}

# Loop through FPR values and run CellBender
for fpr in "${fpr_values[@]}"; do
    run_cellbender_ambient "$base_input_dir" "$fpr"
done
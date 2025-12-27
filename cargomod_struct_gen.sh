#!/bin/bash

# Setup folders
OUTPUT_DIR="package_trees"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

JSONL_DIR="jsonl"
rm -rf $JSONL_DIR
mkdir -p $JSONL_DIR

# Get cargo-modules output message
cd rust-bitcoin
cargo-modules structure &> ../listofpackages
cd ..

# Retrieve the list of packages
list=$(cat listofpackages | awk 'NR > 4' | head -n -1 | cut -c 3-)
rm listofpackages

# Loop through the list to create txt files
for package in $list; do
  filename="$package.txt"

  # Use NO_COLOR to avoid unreadable chars
  echo "Processing package $package..."
  echo -n $(NO_COLOR=1 cargo-modules structure --package $package &> $OUTPUT_DIR/$filename)
  # Remove empty line on top
  sed -i '/^$/d' $OUTPUT_DIR/$filename

  # Run python script for each file
  echo -n $(python3 pkgtree_jsonl.py -f $filename > $JSONL_DIR/"$package.jsonl")
done

#!/bin/bash

# Setup folders
OUTPUT_DIR="package_trees"
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Get cargo-modules output
cd rust-bitcoin
cargo-modules structure &> ../listofpackages
cd ..

# Retrieve the list of packages
list=$(cat listofpackages | awk 'NR > 4' | head -n -1 | cut -c 3-)
rm listofpackages

# Loop through the list
for package in $list; do
  filename="$package.txt"

  # Use NO_COLOR to avoid unreadable chars
  echo "Processing package $package..."
  echo $(NO_COLOR=1 cargo-modules structure --package $package &> $OUTPUT_DIR/$filename)

  # Remove empty line on top
  sed -i '/^$/d' $OUTPUT_DIR/$filename
done

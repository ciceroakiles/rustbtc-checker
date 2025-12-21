#!/bin/bash

cd rust-bitcoin
cargo-modules structure &> ../listofpackages
cd ..

# Retrieve the list of packages
list=$(cat listofpackages | awk 'NR > 4' | head -n -1 | cut -c 3-)

# Loop through the list
for package in $list; do
  # Use NO_COLOR to avoid unreadable chars
  echo "Processing package $package..."
  echo $(NO_COLOR=1 cargo-modules structure --package $package &> package_trees/$package.txt)
done

rm listofpackages

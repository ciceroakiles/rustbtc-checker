#!/bin/bash

# Get project files
rm -rf rust-bitcoin
git clone https://github.com/rust-bitcoin/rust-bitcoin.git

# Rustdocs
rm -rf rustdocs
mkdir -p "rustdocs"
echo ""
echo -n "Running rustdocs_generator.sh... "
echo $(./rustdocs_generator.sh | tee rustdocs/report > /dev/null)

# Rustdocs report file
mv rustdocs/report rustdocs/report.txt

echo "Done."

#!/bin/bash

# Get project files
rm -rf rust-bitcoin
git clone https://github.com/rust-bitcoin/rust-bitcoin.git

cd rust-bitcoin
touch project_files_go_here
cd..

# Run cargo-modules installation
cargo install cargo-modules

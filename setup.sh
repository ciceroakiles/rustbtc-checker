#!/bin/bash

# Get project files
rm -rf rust-bitcoin
git clone https://github.com/rust-bitcoin/rust-bitcoin.git

# Run cargo-modules installation
cargo install cargo-modules

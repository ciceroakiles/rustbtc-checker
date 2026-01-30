#!/bin/bash

# Get project files
rm -rf rust-bitcoin
git clone https://github.com/rust-bitcoin/rust-bitcoin.git

touch rust-bitcoin/project_files_go_here

# Run cargo-modules installation
cargo install cargo-modules

# Switch to nightly toolchain
rustup default nightly

# Run cargo-public-api installation
cargo +nightly install cargo-public-api --locked

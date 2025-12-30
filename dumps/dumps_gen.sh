#!/bin/bash

# Setup folder
REPO_DIR=$(git rev-parse --show-toplevel)
cd $REPO_DIR/rust-bitcoin

# File names
dump_cargo="dump_cargopubapi.txt"
dump_feat="dump_all-features.txt"

# First dump
cargo +nightly --locked public-api --simplified --all-features --color=never -p bitcoin-units | sort --numeric-sort | uniq > ../dumps/"$dump_cargo"

# Second dump
cat ../dumps/"$dump_cargo" | grep -e "pub enum" -e "pub mod" -e "pub struct" | grep -v -x "pub mod bitcoin_units" > ../dumps/"$dump_feat"

cd ..

# Second dump filtered as jsonl
echo -n $(python3 $REPO_DIR/dumps/dump_jsonl_gen.py -f $REPO_DIR/dumps/$dump_feat > $REPO_DIR/dumps/jsonl/"filtered_dump.jsonl")

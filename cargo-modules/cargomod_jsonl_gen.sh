#!/bin/bash

# Setup folders
REPO_DIR=$(git rev-parse --show-toplevel)
PKGTREE_DIR="$REPO_DIR/cargo-modules/package_trees"
JSONL_DIR="$REPO_DIR/cargo-modules/jsonl"

# A specific package name.
# To get a full list of packages available, run "cargo-modules structure"
package="bitcoin-units"

main() {
    cd $REPO_DIR
    filename="$package.txt"

    # Use NO_COLOR to avoid unreadable chars
    echo "Processing package $package..."
    echo -n $(NO_COLOR=1 cargo-modules structure --package $package &> $PKGTREE_DIR/$filename)
    # Remove empty line on top
    sed -i '/^$/d' $PKGTREE_DIR/$filename

    # Run python script
    echo -n $(python3 $REPO_DIR/cargo-modules/pkgtree_jsonl_gen.py -f $PKGTREE_DIR/$filename > $JSONL_DIR/"$package.jsonl")

    # Clean up
    rm -f temp.jsonl
    find $JSONL_DIR -type f -empty -delete
}

main "$@"
exit 0

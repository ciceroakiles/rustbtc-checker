#!/bin/bash

# Setup folders
REPO_DIR=$(git rev-parse --show-toplevel)
PKGTREE_DIR="$REPO_DIR/cargo-modules/package_trees"
JSONL_DIR="$REPO_DIR/cargo-modules/jsonl"

main() {
    # Get cargo-modules output message
    cd $REPO_DIR/rust-bitcoin
    cargo-modules structure &> ../cargo-modules/listofpackages
    cd ..

    # Retrieve the list of packages
    list=$(cat "$REPO_DIR/cargo-modules/listofpackages" | awk 'NR > 4' | head -n -1 | cut -c 3-)
    rm "$REPO_DIR/cargo-modules/listofpackages"

    # Loop through the list to create txt files
    for package in $list; do
        filename="$package.txt"

        # Use NO_COLOR to avoid unreadable chars
        echo "Processing package $package..."
        echo -n $(NO_COLOR=1 cargo-modules structure --package $package &> $PKGTREE_DIR/$filename)
        # Remove empty line on top
        sed -i '/^$/d' $PKGTREE_DIR/$filename

        # Run python script for each file
        echo -n $(python3 $REPO_DIR/cargo-modules/pkgtree_jsonl.py -f $PKGTREE_DIR/$filename > temp.jsonl)

        # Apply a filter on json lines
        jq -c 'select(.visible=="pub") | select(.type=="enum" or .type=="mod" or .type=="struct")' temp.jsonl > $JSONL_DIR/"$package.jsonl"

        # Clean up
        rm -f temp.jsonl
        find $JSONL_DIR -type f -empty -delete
    done
}

main "$@"
exit 0

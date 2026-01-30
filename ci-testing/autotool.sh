#!/bin/bash

REPO_DIR=$(git rev-parse --show-toplevel)
LOCAL_DIR="ci-testing"

package_name="bitcoin-units"


main() {
    create_package_tree

    create_jsonl
    rm tree.txt

    filter_jsonl 5 0
    rm parsed_tree.jsonl

    create_public_api_file_default
    check_policy_1 report_default
    cat report_default.txt

    echo ""

    create_public_api_file_nightly
    check_policy_1 report_nightly
    cat report_nightly.txt

    rm cargopubapi.txt
    rm filtered_parsed_tree.jsonl
}


create_public_api_file_default() {
    # Dump public api contents
    cd $REPO_DIR/rust-bitcoin
    echo "Getting public api contents..."

    # Default
    echo -n $(cargo public-api -p $package_name > $REPO_DIR/$LOCAL_DIR/cargopubapi.txt)

    cd ../$LOCAL_DIR
}


create_public_api_file_nightly() {
    # Dump public api contents
    cd $REPO_DIR/rust-bitcoin
    echo "Getting public api contents..."

    # Nightly
    echo -n $(cargo +nightly --locked public-api --simplified --all-features --color=never -p $package_name | sort --numeric-sort | uniq > $REPO_DIR/$LOCAL_DIR/cargopubapi.txt)

    cd ../$LOCAL_DIR
}


create_package_tree() {
    # Use NO_COLOR to avoid unreadable chars
    cd $REPO_DIR/rust-bitcoin
    echo "Processing package $package_name..."
    echo -n $(NO_COLOR=1 cargo-modules structure --package $package_name &> $REPO_DIR/$LOCAL_DIR/tree.txt)
    # Remove empty line on top
    sed -i '/^$/d' ../$LOCAL_DIR/tree.txt

    cd ../$LOCAL_DIR
}


create_jsonl() {
    # Run python script jsonl_parser.py
    echo "Parsing tree for $package_name..."
    echo -n $(python3 $REPO_DIR/$LOCAL_DIR/jsonl_parser.py -f $REPO_DIR/$LOCAL_DIR/tree.txt > $REPO_DIR/$LOCAL_DIR/parsed_tree.jsonl)
}


filter_jsonl() {
    # Run python script jsonl_filter.py
    echo "Filtering $package_name tree contents..."
    echo -n $(python3 $REPO_DIR/$LOCAL_DIR/jsonl_filter.py -f $REPO_DIR/$LOCAL_DIR/parsed_tree.jsonl -t $1 -l $2)
}


check_policy_1() {
    # Run python script policy_errors.py
    printf "First policy selected: reporting..."
    echo $(python3 $REPO_DIR/$LOCAL_DIR/policy_errors_1.py -f $REPO_DIR/$LOCAL_DIR/filtered_parsed_tree.jsonl > $REPO_DIR/$LOCAL_DIR/$1.txt)
}


main "$@"
exit 0

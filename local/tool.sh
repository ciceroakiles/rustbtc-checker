#!/bin/bash

REPO_DIR=$(git rev-parse --show-toplevel)
LOCAL_DIR="local"

package_list=""
package_name="none"


main() {
    # Preload a list of packages
    package_list_preload

    # Entry point
    first_menu
}


# Main menu
first_menu() {
    local PS3="> "
    while true; do
        COLUMNS=12
        local items=(
            "List available packages"			# 1)
            "Select package (selected: $package_name)"	# 2)
            "View package tree"				# 3)
            "Publicly exposed items"			# 4)
            "Check against public api"			# 5)
        )
        select item in "${items[@]}" Exit
        do
            case $REPLY in
                # List available packages
                1)
                    echo ""
                    for p in $package_list; do
                        echo $p
                    done
                    echo ""
                    break;;

                # Select package
                2)
                    echo -n "Package name: "
                    read package_name
                    if exists_in_list "$package_list" " " $package_name; then
                        echo "Package $package_name selected."
                    else
                        package_name="none"
                    fi
                    echo ""
                    break;;

                # View package tree
                3)
                    if [ $package_name != "none" ]; then
                        create_package_tree
                        echo ""
                        cat tree.txt
                        rm tree.txt
                        cd ..
                    else
                        echo "Error: no package selected"
                    fi
                    echo ""
                    break;;

                # Publicly exposed items
                4)
                    if [ $package_name != "none" ]; then
                        create_package_tree
                        create_jsonl

                        # Default to "All"
                        filter_jsonl 1 0

                        echo ""
                        pub_items_submenu
                    else
                        echo "Error: no package selected"
                    fi
                    echo ""
                    break;;

                # Check against public api
                5)
                    if [ $package_name != "none" ]; then
                        policies_submenu
                    else
                        echo "Error: no package selected"
                    fi
                    echo ""
                    break;;

                # Exit
                $((${#items[@]}+1))) echo -n ""; break 2;;

                # Default
                *)
                    echo -e "Unknown option: $REPLY\n"
                    break;
            esac
        done
    done
}


# Publicly exposed items submenu
pub_items_submenu() {
    # Save $REPLY state
    rep=0

    local PS3="> "
    while true; do
        # Number of lines in file
        LINE_COUNT=$(wc -l < filtered_parsed_tree.jsonl)

        COLUMNS=12
        echo "Publicly exposed items:"
        local items=(
            "All"
            "enum/mod/struct" 
            "type/trait/fn/const_fn"
            "error (x1 only)"
            "error (x2 or more)"
            "Line selection (1-$LINE_COUNT)"
        )
        select item in "${items[@]}" Back
        do
            case $REPLY in
                # All
                1)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl | less
                    echo ""
                    break;;

                # enum/mod/struct
                2)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl | less
                    echo ""
                    break;;

                # type/trait/fn/const_fn
                3)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl | less
                    echo ""
                    break;;

                # error (x1 only)
                4)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                # error (x2 or more)
                5)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                # Line selection
                6)
                    echo -n "Line number: "
                    read line_number
                    if ((line_number >= 1 && line_number <= LINE_COUNT)); then
                        echo ""
                        filter_jsonl $REPLY $line_number

                        cat dataframe.txt
                        rm dataframe.txt
                    fi

                    # Keep previous filter
                    filter_jsonl $rep 0

                    echo -e "\n"
                    break;;

                # Back
                7)
                    rm tree.txt
                    rm parsed_tree.jsonl
                    rm filtered_parsed_tree.jsonl
                    cd ..
                    return;;

                # Default
                *)
                    echo -e "Unknown option: $REPLY\n"
                    break;
            esac
        done
    done
}


policies_submenu() {
    echo ""
    local PS3="> "
    while true; do
        COLUMNS=12
        local items=(
            "foo::error::BarError versus public api (default)"	# 1)
            "foo::error::BarError versus public api (nightly)"	# 2)
        )
        select item in "${items[@]}" Back
        do
            case $REPLY in
                # foo::error::BarError versus public api (default)
                1)
                    create_public_api_file_default

                    create_package_tree

                    create_jsonl
                    rm tree.txt

                    filter_jsonl 5 0
                    rm parsed_tree.jsonl

                    check_policy_1
                    rm filtered_parsed_tree.jsonl

                    cat report.txt | less
                    echo ""
                    break;;

                # foo::error::BarError versus public api (nightly)
                2)
                    create_public_api_file_nightly

                    create_package_tree

                    create_jsonl
                    rm tree.txt

                    filter_jsonl 5 0
                    rm parsed_tree.jsonl

                    check_policy_1
                    rm filtered_parsed_tree.jsonl

                    cat report.txt | less
                    echo ""
                    break;;

                # Back
                3)
                    rm cargopubapi.txt
                    rm report.txt
                    cd ..
                    return;;
            esac
        done
    done
}


package_list_preload() {
    cd $REPO_DIR/rust-bitcoin
    cargo-modules structure &> ../$LOCAL_DIR/listofpackages
    cd ..
    package_list=$(cat "$REPO_DIR/$LOCAL_DIR/listofpackages" | awk 'NR > 4' | head -n -1 | cut -c 3-)
    rm "$REPO_DIR/$LOCAL_DIR/listofpackages"
}


exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
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
    echo $(python3 $REPO_DIR/$LOCAL_DIR/policy_errors_1.py -f $REPO_DIR/$LOCAL_DIR/filtered_parsed_tree.jsonl > $REPO_DIR/$LOCAL_DIR/report.txt)
}


main "$@"
exit 0

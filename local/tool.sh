#!/bin/bash

REPO_DIR=$(git rev-parse --show-toplevel)
LOCAL_DIR="$REPO_DIR/local"
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
                        echo ""

                        # Default to "All"
                        filter_jsonl 1 0

                        pub_items_submenu
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
            "error x2"
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
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                # enum/mod/struct
                2)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                # type/trait/fn/const_fn
                3)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                # error x2
                4)
                    filter_jsonl $REPLY 0
                    rep=$REPLY
                    echo ""
                    cat -n filtered_parsed_tree.jsonl
                    echo ""
                    break;;

                5)
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
                6)
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


package_list_preload() {
    cd $REPO_DIR/rust-bitcoin
    cargo-modules structure &> ../local/listofpackages
    cd ..
    package_list=$(cat "$LOCAL_DIR/listofpackages" | awk 'NR > 4' | head -n -1 | cut -c 3-)
    rm "$LOCAL_DIR/listofpackages"
}


exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    echo $LIST | tr "$DELIMITER" '\n' | grep -F -q -x "$VALUE"
}


create_package_tree() {
    # Use NO_COLOR to avoid unreadable chars
    cd $REPO_DIR/rust-bitcoin
    echo "Processing package $package_name..."
    echo -n $(NO_COLOR=1 cargo-modules structure --package $package_name &> ../local/tree.txt)
    # Remove empty line on top
    sed -i '/^$/d' ../local/tree.txt

    cd ../local
}


create_jsonl() {
    # Run python script jsonl_parser.py
    echo -n $(python3 $LOCAL_DIR/jsonl_parser.py -f $LOCAL_DIR/tree.txt > $LOCAL_DIR/parsed_tree.jsonl)
}


filter_jsonl() {
    # Run python script jsonl_filter.py
    echo -n $(python3 $LOCAL_DIR/jsonl_filter.py -f $LOCAL_DIR/parsed_tree.jsonl -t $1 -l $2)
}


main "$@"
exit 0

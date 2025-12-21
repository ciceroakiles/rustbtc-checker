#!/bin/bash

# Setup exclusion list for first run
EXCLUDE_LIST="exclusion_list"
touch $EXCLUDE_LIST

process_fields() {
  # Remove system info from JSON
  file=$1
  edited_json=$(cat $file.json | jq -r 'del(."target") | del(."external_crates".[]."path")')
  echo $edited_json > $file.json

  # Sort paths and export them to a JSONL file
  jsonl_pre=$(cat $file.json | jq -r '."paths" | (to_entries | sort_by(.key | tonumber) | from_entries) | to_entries | map("\(.value)") | .[]')
  echo $jsonl_pre | tr ' ' '\n' > ../../$JSONL_DIR/$file.jsonl
}

rustdocs() {
  # Parse path and filename
  filename="${path#???}"
  out="${filename//\//-}"

  # Display progress
  echo -n "Running rustdoc for file: $filename"

  # Run rustdoc and redirect error output
  cmd=$(rustdoc $path --output-format json -Z unstable-options -o $out 2>&1)

  if [ -d "$out" ]; then
    if [[ ! -n "$cmd" ]]; then

      # If the error output is empty, then move JSON to /doc, and remove folder
      cd $out
      mv *.json ../doc/$out.json
      cd ../doc
      echo $(process_fields $out)
      cd .. && rmdir $out
      echo -n " [PASS]"

    else

      # Trigger warning: move JSON and logs to its folder
      cd $out
      mv *.json ../$WARN_DIR/$out.json
      cd ../$WARN_DIR
      echo $(process_fields $out)
      cd .. && rmdir $out
      echo "$cmd" > $WARN_DIR/$out.txt
      echo -n " [WARN]"

    fi
  else

    # No folder was created and error output is not empty:
    # a rustdoc JSON was not generated, so move error logs to its folder
    echo "$cmd" > $ERROR_DIR/$out.txt
    echo -n " [FAIL]"

  fi
  echo ""
}

# Setup folders
OUTPUT_DIR="rustdocs"
DOCS_DIR="doc"
WARN_DIR="warnings"
ERROR_DIR="errors"
JSONL_DIR="jsonl"
rm -rf $OUTPUT_DIR/$DOCS_DIR/*
rm -rf $OUTPUT_DIR/$WARN_DIR/*
rm -rf $OUTPUT_DIR/$ERROR_DIR/*
rm -rf $JSONL_DIR/*
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/$DOCS_DIR
mkdir -p $OUTPUT_DIR/$WARN_DIR
mkdir -p $OUTPUT_DIR/$ERROR_DIR
mkdir -p $JSONL_DIR

cd $OUTPUT_DIR

# Get *.rs file locations and filter them,
# by removing the ones present in the exclusion list
files=$(find ../../rust-bitcoin/ -type f -name '*.rs')
echo "$files" > files_preload
grep -Fxvf ../$EXCLUDE_LIST files_preload > ../files
rm -f files_preload

# Read file list
echo -e "Run rustdocs\n"
while R= read -r path; do
  echo $(rustdocs)
done < ../files

# Remove some residual *.txt files
rm -f *.txt

echo -e "\n-------\n"

# Count files
pass=$(find "doc" -type f -name "*.json" | wc -l)
warn=$(find "$WARN_DIR" -type f -name "*.json" | wc -l)
fail=$(find "$ERROR_DIR" -type f -name "*.txt" | wc -l)
total=$(($pass+$warn+$fail))

# Metrics
echo -e "Rustdoc metrics\n"
echo -n "  JSON files in /doc: $pass"

echo -n " ("
printf "%.3f" "$(echo "scale=3; ($pass / $total) * 100" | bc)"
echo "%)"

echo -n "            Warnings: $warn"

echo -n " ("
printf "%.3f" "$(echo "scale=3; ($warn / $total) * 100" | bc)"
echo "%)"

echo -n "     Logs in /errors: $fail"

echo -n " ("
printf "%.3f" "$(echo "scale=3; ($fail / $total) * 100" | bc)"
echo "%)"

echo -e "\n-------\n"

# Generate a sorted JSON list
find . -type f -name "*.json" | sort -n | cut -c 3- > json_list.txt

#!/bin/bash

OUTPUT_FILE="all_scala_files.txt"
SRC_DIR="src/main/scala/cpu"

# Clear output file
> "$OUTPUT_FILE"

# Loop through scala files
for file in "$SRC_DIR"/*.scala; do
    if [ -f "$file" ]; then
        echo "========================================" >> "$OUTPUT_FILE"
        echo "File: $(basename "$file")" >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo -e "\n\n" >> "$OUTPUT_FILE"
    fi
done

echo "All scala files concatenated into $OUTPUT_FILE"

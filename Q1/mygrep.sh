#!/bin/bash

# mygrep.sh - A simplified version of grep

# Function to display usage information
function show_usage {
    echo "Usage: $0 [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE."
    echo ""
    echo "Options:"
    echo "  -n         Show line numbers for each match"
    echo "  -v         Invert the match (print lines that do not match)"
    echo "  --help     Display this help message and exit"
    exit 1
}

# Initialize variables
show_line_numbers=false
invert_match=false

# Parse options
while [[ "$1" == -* ]]; do
    case "$1" in
        -n)
            show_line_numbers=true
            ;;
        -v)
            invert_match=true
            ;;
        -vn|-nv)
            show_line_numbers=true
            invert_match=true
            ;;
        --help)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
    shift
done

# Check if we have enough arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments."
    show_usage
fi

pattern="$1"
file="$2"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Perform the search
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Case-insensitive match using grep (to avoid complex bash pattern matching)
    if echo "$line" | grep -qi "$pattern"; then
        match_found=true
    else
        match_found=false
    fi
    
    # Determine whether to print the line based on match and invert settings
    if { $match_found && ! $invert_match; } || { ! $match_found && $invert_match; }; then
        if $show_line_numbers; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"

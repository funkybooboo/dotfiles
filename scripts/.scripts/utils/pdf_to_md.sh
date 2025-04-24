#!/bin/bash

# Ensure the correct number of arguments are passed
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input-pdf-file>"
    exit 1
fi

# Input and output files
input_pdf="$1"
output_txt="${input_pdf%.pdf}.txt"
output_md="${input_pdf%.pdf}.md"

# Check if pdftotext is installed
if ! command -v pdftotext &>/dev/null; then
    echo "pdftotext could not be found. Please install poppler-utils first."
    exit 1
fi

# Check if pandoc is installed
if ! command -v pandoc &>/dev/null; then
    echo "Pandoc could not be found. Please install it first."
    exit 1
fi

# Step 1: Extract text from the PDF using pdftotext
echo "Extracting text from PDF..."
pdftotext "$input_pdf" "$output_txt"

# Check if the text extraction was successful
if [ $? -ne 0 ]; then
    echo "Error extracting text from PDF."
    exit 1
fi

# Step 2: Convert extracted text to Markdown using Pandoc
echo "Converting text to Markdown..."
pandoc "$output_txt" -o "$output_md"

# Check if the conversion was successful
if [ $? -eq 0 ]; then
    echo "Markdown conversion successful: $output_md"
else
    echo "Error converting to Markdown."
    exit 1
fi

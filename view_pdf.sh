#!/usr/bin/env bash

pdf_file="$1"
page_num=1

# Convert PDF to images (PNG format)
pdftoppm -png "$pdf_file" page

# Display each page in Kitty
while [ -f "page-$page_num.png" ]; do
    kitty +kitten icat "page-$page_num.png"
    page_num=$((page_num + 1))
done

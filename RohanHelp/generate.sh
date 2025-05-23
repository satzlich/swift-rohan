#!/bin/bash

# Function to convert markdown to HTML with MathJax (SVG renderer)
md2html() {
  # Check for correct number of arguments
  if [ "$#" -ne 2 ]; then
    echo "Usage: md2html input.md output.html"
    return 1
  fi

  local input_file="$1"
  local output_file="$2"

  pandoc --standalone --mathjax \
    -f markdown -t html --columns=1000 \
    --template=template.html \
    -o "$output_file" "$input_file"
}

md2html commands.md Rohan.help/Contents/Resources/en.lproj/index.html

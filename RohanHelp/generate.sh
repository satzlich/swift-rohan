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
    -o "Rohan.help/Contents/Resources/en.lproj/$output_file" "md/$input_file"
}

md2html getting-started.md index.html
md2html commands.md commands.html
md2html replacement-rules.md replacement-rules.html
md2html code-snippets.md code-snippets.html
md2html discrepancy.md discrepancy.html

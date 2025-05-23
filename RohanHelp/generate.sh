#!/bin/bash

pandoc  --standalone --mathjax \
  -f markdown -t html --columns=1000 \
  --template=template.html \
  -o Rohan.help/Contents/Resources/en.lproj/index.html commands.md 

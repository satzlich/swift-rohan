#!/bin/bash

pandoc  --standalone --mathjax -f markdown -t html --columns=1000 \
  -o HelpBook/Commands.html Commands.md 

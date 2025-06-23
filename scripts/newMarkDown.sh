#!/bin/bash

# Get the current date and time in the format YYYY.MM.DD-HHMM
filename=$(date +"%Y.%m.%d-%H%M.md")

# Run NeoVim with the generated filename
nvim "~/Documents/$filename"

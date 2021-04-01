#!/bin/sh
vale -v 
echo "# Breakdown of vale errors per module:"

for module in modules/*
    do
    echo -n "$module: "
    vale --minAlertLevel=error --output=line "$module" | wc -l
done

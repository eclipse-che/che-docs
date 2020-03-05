#!/usr/bin/env bash

# Exit on any error
set -e

function usage {
    echo "Usage: /${BASH_SOURCE[0]} [-h]
    PURPOSE:
    Validate that all attributes are processed correctly in the HTML output.
    OPTIONS:
      -h help
      -p install requirements (on CentOS, Fedora)"
}

function run {
    # Get the list of attributes from the jekyll configuration file
    attributes=$(shyaml keys asciidoc_attributes < src/main/_config.yml)
    for attribute in ${attributes}
    do
        # Check if the attribute remains unprocessed in the HTML output.
        set +e
        while IFS= read -r error 
        do
            >&2 echo "${attribute}: ${error}"
            ((status++))
        done < <(grep -ire "{${attribute}}" src/main/_site/che-7/)
    done
}

status=0
# Print usage if no option
if [ $# -eq "0" ]
then
  run
  echo "$status errors detected"
  exit $status
fi

# Using getopts to read the options - see http://tldp.org/LDP/abs/html/internal.html#EX33
while getopts ":hp" Option
do
  case $Option in
    p) sudo dnf install bash shyaml;;
    h) usage;;
    *) run;;
  esac
done
# Decrements the argument pointer so it points to next argument.
shift $((OPTIND - 1))

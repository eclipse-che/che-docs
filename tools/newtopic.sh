#!/usr/bin/env bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

echo 'Choose the target guide:'
PS3='Please select the target guide: '
options=("administration-guide" "contributor-guide" "end-user-guide" "extensions" "overview")
select guide in "${options[@]}"
do
    case $guide in
        "administration-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "contributor-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "end-user-guide")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "extensions")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        "overview")
            echo "you chose choice $REPLY which is $guide"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

cd "modules/$guide/partials" || exit

echo 'Choose the topic nature:'

PS3='Please select the topic nature: '
options=("assembly" "concept" "procedure" "reference")
select nature in "${options[@]}"
do
    case $nature in
        "assembly")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "concept")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "procedure")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        "reference")
            echo "you chose choice $REPLY which is $nature"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

echo 'Enter the title for the new topic';
read -r title;
newdoc --no-comments "--$nature" "${title}"

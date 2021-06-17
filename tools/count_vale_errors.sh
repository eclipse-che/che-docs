#!/bin/sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
set -e

vale -v 

echo "= Breakdown of vale infringements per module"
for module in modules/*
    do
    printf "== %s\n" "$module"
    report=".cache/vale-report-${module#modules/}.json"
    vale --minAlertLevel=suggestion --output=JSON --no-exit "$module" > "$report"
    printf "=== Severity\n"
    jq .[][].Severity "$report" | sort | uniq -c | sort -nr 
    printf "=== Check\n"
    jq .[][].Check "$report" | sort | uniq -c | sort -nr
done

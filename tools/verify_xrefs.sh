#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

echo "Verifying xrefs."
for MODULES_DIR in $@
do

echo "* Checking remains of {site-baseurl}:"
grep -Ernie '{site-baseurl}' "${MODULES_DIR}" | cat -n

echo "* Checking xref with anchor without a {context}:"
grep -Ernie 'xref:.?*#' "${MODULES_DIR}" | grep -Ev '{context}' | cat -n

echo "* Checking xref with anchor without a file name:"
grep -Ernie 'xref:.?*#' "${MODULES_DIR}" | grep -v 'adoc' | cat -n

echo "* Checking xref with {context} without a #:"
grep -Ernie 'xref:.?*{context}' "${MODULES_DIR}" | grep -v '#' | cat -n

echo "* Checking xref without file name:"
grep -Ernie 'xref:' "${MODULES_DIR}" | grep -v 'adoc.*adoc' | cat -n

done
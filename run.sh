#!/bin/sh
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
docker run --rm -ti -p 35729:35729 -p 4000:4000 -v $(pwd)/src/main:/che-docs:Z eclipse/che-docs sh -c "cd /che-docs; jekyll serve --incremental --livereload -H 0.0.0.0"

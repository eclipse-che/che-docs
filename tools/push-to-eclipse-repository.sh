#!/usr/bin/env sh
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

# Fail on errors and display commands
set -ex

GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
export GIT_SSH_COMMAND
git clone --depth=1 "ssh://genie.che@git.eclipse.org:29418/www.eclipse.org/che.git" .
git checkout master
ls -ltr
rm -rf docs/ _/
cp -Rvf ../che-docs/docs .
cp -f ../che-docs/404.html .
cp -f ../che-docs/sitemap.xml .
cp -f ../che-docs/search-index.js .
git add -A
if ! git diff --cached --exit-code; then
    echo "Changes have been detected, publishing to repo 'www.eclipse.org/che'"
    git config --global user.email "che-bot@eclipse.org"
    git config --global user.name "Che Bot"
    DOC_COMMIT_MSG=$(git log --oneline --format=%B -n 1 HEAD | tail -1)
    export DOC_COMMIT_MSG
    git commit -s -m "[docs] ${DOC_COMMIT_MSG}"
    git log --graph --abbrev-commit --date=relative -n 5
    git push origin HEAD:master
else
    echo "No change have been detected since last build, nothing to publish"
fi

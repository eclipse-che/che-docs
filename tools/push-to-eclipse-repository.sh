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

PROJECT_NAME="${PROJECT_NAME:-che}"
PROJECT_BOT_NAME="${PROJECT_BOT_NAME:-CHE Bot}"

GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
export GIT_SSH_COMMAND
git clone "ssh://genie.${PROJECT_NAME}@git.eclipse.org:29418/www.eclipse.org/${PROJECT_NAME}.git" .
git checkout master
ls -ltr
rm -rf docs/ _/
cp -Rvf ../che-docs/_ .
cp -Rvf ../che-docs/docs .
cp -f ../che-docs/404.html .
cp -f ../che-docs/favicon.ico .
cp -f ../che-docs/robots.txt .
cp -f ../che-docs/sitemap.xml .
git add -A
if ! git diff --cached --exit-code; then
    echo "Changes have been detected, publishing to repo 'www.eclipse.org/${PROJECT_NAME}'"
    git config --global user.email "${PROJECT_NAME}-bot@eclipse.org"
    git config --global user.name "${PROJECT_BOT_NAME}"
    DOC_COMMIT_MSG=$(git log --oneline --format=%B -n 1 HEAD | tail -1)
    export DOC_COMMIT_MSG
    git commit -s -m "[docs] ${DOC_COMMIT_MSG}"
    git log --graph --abbrev-commit --date=relative -n 5
    git push origin HEAD:master
else
    echo "No change have been detected since last build, nothing to publish"
fi

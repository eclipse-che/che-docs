#!/bin/bash
#
# Copyright (c) 2021 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Release process automation script.
# See: RELEASE.adoc

# Fail on error
set -e

# set to 1 to actually trigger changes in the release branch
TAG_RELEASE=0 
DOCOMMIT=1 # by default DO commit the change
DOPUSH=1 # by default DO push the change
REPO=git@github.com:eclipse/che-docs
MAIN_BRANCH="main"
PUBLICATION_BRANCH="publication-builder"
USE_TMP_DIR=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t'|'--trigger-release')
      TAG_RELEASE=1
      DOCOMMIT=1
      shift 0
      ;;
    '-v'|'--version')
      VERSION="$2"
      shift 1
      ;;
    '-n'|'--nocommit')
      DOCOMMIT=0
      DOPUSH=0
      shift 0
      ;;
    '--nopush')
      DOPUSH=0
      shift 0
      ;;
    '-tmp'|'--use-tmp-dir')
      USE_TMP_DIR=1
      shift 0
      ;;
  esac
  shift 1
done

usage ()
{
  echo "
Usage: $0 --version [VERSION TO RELEASE] 
Example: $0 --version 7.25.2 -t

Options: 
  --trigger-release, -t   Tag this release
  --nocommit, -n          Do not commit changes to git branches
  --nopush                Do not push changes to git remote
  -tmp, --use-tmp-dir     Use a fresh git clone in a temporary directory
"
}

if [[ ! ${VERSION} ]]; then
  usage
  exit 1
fi

gitClone() {
  if [[ ${USE_TMP_DIR} -eq 1 ]]; then
    # Getting a local copy with all ta
    cd /tmp/
    TMPDIR=tmp-${0##*/}-$VERSION
    rm -rf "${TMPDIR}"
    git clone $REPO "${TMPDIR}"
    cd "/tmp/${TMPDIR}"
    git pull
  fi
}

checkoutVersionBranch() {
  # Handle the version branch: create it or update it.
  # Check if the branch exists, locally or on the remote.
  EXISTING_BRANCH=0
  git fetch
  local BUGFIX_BRANCH=${MAJOR}.${MINOR}.x
  EXISTING_BRANCH=$(git ls-remote --heads origin "${BUGFIX_BRANCH}")
  case ${EXISTING_BRANCH} in
    "") echo "[INFO] Creating new branch: ${BUGFIX_BRANCH} from branch: ${MAIN_BRANCH}."
      git checkout "${MAIN_BRANCH}"
      git checkout -b "${BUGFIX_BRANCH}"
      ;;
    *) echo "[INFO] Updating branch: ${BUGFIX_BRANCH}."
      git checkout "${BUGFIX_BRANCH}"
      ;;
  esac
}

gitCommit() {
  if  [[ ${DOCOMMIT} -eq 1 ]]; then 
    git add "antora*.yml" "modules/installation-guide/examples/*" 
    git commit -s -m "chore: release: bump version to ${VERSION}"
  fi
}

gitPush() {
  local BUGFIX_BRANCH=$1
  if  [[ ${DOPUSH} -eq 1 ]]; then 
    git pull origin "${BUGFIX_BRANCH}" || true
    git push origin "${BUGFIX_BRANCH}"
  fi
}

gitTag() {
  if [[ ${TAG_RELEASE} -eq 1 ]]; then
    echo "[INFO] Creating release tag"
    git tag "${VERSION}"
    git push origin "${VERSION}" || true
  fi
}

versionFormatIsValid() {
# Validating version format
[[ ${VERSION} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && MAJOR="${BASH_REMATCH[1]}" ; MINOR="${BASH_REMATCH[2]}"; PATCH="${BASH_REMATCH[3]};"
case ${MAJOR} in
 "") echo "[ERROR] Version ${VERSION} is not in form MAJOR.MINOR.PATCH."
     exit 1
     ;;
esac
case ${MINOR} in
 "") echo "[ERROR] Version ${VERSION} is not in form MAJOR.MINOR.PATCH."
     exit 1
     ;;
esac
case ${PATCH} in
 "") echo "[ERROR] Version ${VERSION} is not in form MAJOR.MINOR.PATCH."
     exit 1
     ;;
esac
echo "[INFO] Version format for: ${VERSION} is in form MAJOR.MINOR.PATCH."
}

replaceFieldSed()
{
  local YAMLFILE=$1
  local YAMLKEY=$2
  local YAMLVALUE=$3
  echo "[INFO] Updating file: ${YAMLFILE}: setting attribute: ${YAMLKEY}: ${YAMLVALUE}"
  sed -i "${YAMLFILE}" -r -e "s#( ${YAMLKEY}: ).+#\1${YAMLVALUE}#"
}

patchVersionUpdate() {
  checkoutVersionBranch
  local YAMLFILE="antora.yml"
  replaceFieldSed "${YAMLFILE}" 'prerelease' "false"
  replaceFieldSed "${YAMLFILE}" 'version' "\"${MAJOR}.${MINOR}.x\""
  replaceFieldSed "${YAMLFILE}" 'display_version' "\"${MAJOR}.${MINOR}.x\""
  replaceFieldSed "${YAMLFILE}" 'prod-ver-major' "\"${MAJOR}\""
  replaceFieldSed "${YAMLFILE}" 'prod-ver' "\"${MAJOR}.${MINOR}\""
  replaceFieldSed "${YAMLFILE}" 'prod-ver-patch' "\"${MAJOR}.${MINOR}.${PATCH}\""
  ./tools/checluster_docs_gen.sh
  ./tools/environment_docs_gen.sh
  gitTag
  gitPush "${MAJOR}.${MINOR}.x"
  echo "[INFO] Finished handling version update on branch: ${MAJOR}.${MINOR}.x"
}

# Validate the version format.
versionFormatIsValid

# Get a working copy if necessary.
gitClone

# Update version in the version branch
patchVersionUpdate

echo "[INFO] Project version has been updated"

if [[ ${USE_TMP_DIR} -eq 1 ]]; then
  rm -fr "/tmp/${TMPDIR}"
fi

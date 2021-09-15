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
# 0. Verify VERSION is defined as X.Y.Z
# 1. Start from the accurate branch
#    * If Z = 0, start from master branch.
#    * Else, start from X.Y.x release branch
# 2. Update versions in `antora.yml`:
#    * `prod-ver` = version to release
#    * Set other `ver` attributes accordingly.
# 3. Run scripts generating doc
#    * checluster_docs_gen.sh
#    * environment_docs_gen.sh
# 4. Commit and push to the release branch.
# 5. (If defined) Tag the release

# Fail on error
set -e

# set to 1 to actually trigger changes in the release branch
TAG_RELEASE=0 
DOCOMMIT=1 # by default DO commit the change
DOPUSH=1 # by default DO push the change
REPO=git@github.com:eclipse/che-docs
MAIN_BRANCH="master"
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

gitBranch() {
  # Handle the version branch: create it or update it.
  # Check if the branch exists, locally or on the remote.
  EXISTING_BRANCH=0
  git fetch
  EXISTING_BRANCH=$(git ls-remote --heads origin "${TARGET_BRANCH}")
  case ${EXISTING_BRANCH} in
    "") echo "[INFO] Creating new branch: ${TARGET_BRANCH} from branch: ${MAIN_BRANCH}."
      git checkout "${MAIN_BRANCH}"
      git checkout -b "${TARGET_BRANCH}"
      ;;
    *) echo "[INFO] Updating branch: ${TARGET_BRANCH} from branch: ${MAIN_BRANCH}."
      git checkout "${TARGET_BRANCH}"
      git pull --rebase origin "${MAIN_BRANCH}"
      ;;
  esac
}

gitCommit() {
  if  [[ ${DOCOMMIT} -eq 1 ]]; then 
    git add "antora*.yml" "modules/installation-guide/examples/*" 
    git commit -s -m "release: Bump version to ${VERSION}"
  fi
}

gitPush() {
  if  [[ ${DOPUSH} -eq 1 ]]; then 
    git pull origin "${TARGET_BRANCH}" || true
    git push origin "${TARGET_BRANCH}"
  fi
}

gitPullRequest() {
  if  [[ ${DOCOMMIT} -eq 1 ]]; then 
    git pull origin "${TARGET_BRANCH}" || true
    git push origin "${TARGET_BRANCH}"
    LASTCOMMITCOMMENT="$(git log -1 --pretty=%B)"
    hub pull-request --force --message "${LASTCOMMITCOMMENT}" --base "${MAIN_BRANCH}" --head "${TARGET_BRANCH}"
  fi
}

gitTag() {
  if [[ ${TAG_RELEASE} -eq 1 ]]; then
    echo "[INFO] Creating release tag"
    git checkout "${TARGET_BRANCH}"
    git pull origin "${TARGET_BRANCH}" || true
    git tag "${VERSION}"
    git push origin "${VERSION}" || true
  fi
}

versionFormatIsValid() {
# Validating version format
[[ ${VERSION} =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && MAJOR="${BASH_REMATCH[1]}" ; MINOR="${BASH_REMATCH[2]}"; PATCH="${BASH_REMATCH[3]}"
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

versionIsIncremented() {
  # Validation version is incremented, never decremented
  OLDVERSION="$(yq -r '.asciidoc.attributes."prod-ver-patch"' "${YAMLFILE}")" # existing prod-ver-patch version 7.yy.z
  VERSIONS="${OLDVERSION} ${VERSION}"
  VERSIONS_SORTED="$(echo "${VERSIONS}" | tr " " "\n" | sort -V | tr "\n" " ")"
  # echo "Compare '${VERSIONS_SORTED}' with '${VERSIONS} '"
  if [[ "${VERSIONS_SORTED}" != "${VERSIONS} " ]] || [[ "${OLDVERSION}" == "${VERSION}" ]]; then # note trailing space after VERSIONS is required!
    echo "[ERROR] Target version ${VERSION} is smaller than existing version: ${OLDVERSION}. Version should not go backwards, so nothing to do!"
    return 1
  fi
  echo "[INFO] Target version: ${VERSION} is an increment for current version: ${OLDVERSION}."
}

replaceFieldSed()
{
  YAMLFILE=$1
  YAMLKEY=$2
  YAMLVALUE=$3
  echo "[INFO] Updating file: ${YAMLFILE} on branch: ${TARGET_BRANCH}: setting attribute: ${YAMLKEY}: ${YAMLVALUE}"
  sed -i "${YAMLFILE}" -r -e "s#( ${YAMLKEY}: ).+#\1${YAMLVALUE}#"
}

versionUpdate() {
  # Update the version, defined in the antora.yml file, in following keys:
  #    prod-prev-ver-major: "6" [never changes]
  #    prod-ver-major: "7" [never changes]
  #    prod-prev-ver: "7.24" [always prod-ver - 1]
  #    prod-ver: "7.25"
  #    prod-ver-patch: "7.25.2"
  # Major version upgrade is expected to fail.
  YAMLFILE=antora.yml
  # prod-ver should never go down, only up
  versionIsIncremented
  replaceFieldSed "${YAMLFILE}" 'prod-ver-major' "\"${MAJOR}\""
  replaceFieldSed "${YAMLFILE}" 'prod-ver' "\"${MAJOR}.${MINOR}\""
  replaceFieldSed "${YAMLFILE}" 'prod-ver-patch' "\"${MAJOR}.${MINOR}.${PATCH}\""
  replaceFieldSed "${YAMLFILE}" 'prod-prev-ver' "\"${MAJOR}.$((MINOR - 1))\""
  # Update the version, defined in the antora-playbook-for-publication.yml file, in following keys:
  #    branches: 7.32.x
  #    edit_url: "https://github.com/eclipse/che-docs/edit/7.35.x/{path}"
  YAMLFILE=antora-playbook-for-publication.yml
  if [ -f "${YAMLFILE}" ]
  then
    replaceFieldSed "${YAMLFILE}" 'branches' "\"${MAJOR}.${MINOR}.x\""
    replaceFieldSed "${YAMLFILE}" 'edit_url' "\"https://github.com/eclipse/che-docs/edit/${MAJOR}.${MINOR}.x/{path}\""
  else
    echo "[WARNING] Cannot find file: ${YAMLFILE} on branch: ${TARGET_BRANCH}. Skipping."
  fi  
  echo "[INFO] Generating single-sourced docs on branch: ${TARGET_BRANCH}."
  ./tools/checluster_docs_gen.sh
  ./tools/environment_docs_gen.sh
  echo "[INFO] Finished handling version update on branch: ${TARGET_BRANCH}.."
}

# Validate the version format.
versionFormatIsValid

# Get a working copy if necessary.
gitClone

# Update version in the version branch and in the main branch.
for TARGET_BRANCH in "${MAJOR}.${MINOR}.x" "release-${VERSION}"
do
  gitBranch
  versionUpdate
  gitCommit
  gitPush
  case ${TARGET_BRANCH} in
    "${MAJOR}.${MINOR}.x")
      gitTag
      ;;
    "release-${VERSION}")
      gitPullRequest
      ;;
  esac
done

echo "[INFO] Project version has been updated"

if [[ ${USE_TMP_DIR} -eq 1 ]]; then
  rm -fr "/tmp/${TMPDIR}"
fi

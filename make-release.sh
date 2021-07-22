#!/bin/bash
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


# set to 1 to actually trigger changes in the release branch
TAG_RELEASE=0 
docommit=1 # by default DO commit the change
REPO=git@github.com:eclipse/che-docs
MAINBRANCH="master"
USE_TMP_DIR=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t'|'--trigger-release') TAG_RELEASE=1; docommit=1; shift 0;;
    '-v'|'--version') VERSION="$2"; shift 1;;
    '-n'|'--nocommit') docommit=0; shift 0;;
    '-tmp'|'--use-tmp-dir') USE_TMP_DIR=1; shift 0;;
  esac
  shift 1
done

usage ()
{
  echo "
Usage: $0 --version [VERSION TO RELEASE] 
Example: $0 --version 7.25.2 -t

Options: 
  --trigger-release, -t  tag this release
  --no-commit, -n        do not commit changes to branches
"
}

set -e

if [[ ! ${VERSION} ]]; then
  usage
  exit 1
fi

if [[ ${USE_TMP_DIR} -eq 1 ]]; then
  cd /tmp/ && tmpdir=tmp-${0##*/}-$VERSION && git clone $REPO "$tmpdir" && cd "/tmp/$tmpdir"
fi

# where in other repos we have a VERSION file, here we have an antora.yml file which contains some keys:
#    prod-prev-ver-major: "6" [never changes]
#    prod-ver-major: "7" [never changes]
#    prod-prev-ver: "7.24" [always prod-ver - 1]
#    prod-ver: "7.25"
#    prod-ver-patch: "7.25.2"
updateYaml() {
  playbookfile=antora.yml
  NEWVERSION=${1}
  echo "[INFO] update $playbookfile with prod-ver = $NEWVERSION"

  [[ $NEWVERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE1="${BASH_REMATCH[1]}"; BASE2="${BASH_REMATCH[2]}"; # for VERSION=7.25.2, get BASE1=7; BASE2=25
  # prod-ver should never go down, only up
  OLDVERSION=$(yq -r '.asciidoc.attributes."prod-ver-patch"' $playbookfile) # existing prod-ver-patch version 7.yy.z
  VERSIONS="${OLDVERSION} ${NEWVERSION}"
  VERSIONS_SORTED="$(echo "$VERSIONS" | tr " " "\n" | sort -V | tr "\n" " ")"
  # echo "Compare '$VERSIONS_SORTED' with '$VERSIONS '"
  if [[ "${VERSIONS_SORTED}" != "${VERSIONS} " ]] || [[ "${OLDVERSION}" == "${NEWVERSION}" ]]; then # note trailing space after VERSIONS is required!
    echo "[WARN] Existing prod-ver ${OLDVERSION} is greater or equal than planned update to ${NEWVERSION}. Version should not go backwards, so nothing to do!"
    return 1
  else 
    replaceFieldSed $playbookfile 'prod-ver' "\"${BASE1}.${BASE2}\""
    replaceFieldSed $playbookfile 'prod-ver-patch' "\"$NEWVERSION\""
    # set prod-prev-ver = 7.y-1
    (( BASE2=BASE2-1 ))
    replaceFieldSed $playbookfile 'prod-prev-ver' "\"${BASE1}.${BASE2}\""
  fi
}

replaceFieldSed()
{
  YAMLFILE=$1
  updateName=$2
  updateVal=$3
  # echo "[INFO] * ${YAMLFILE} ==> ${updateName}: ${updateVal}"
  sed -i "${YAMLFILE}" -r -e "s#(    $updateName: ).+#\1${updateVal}#"
}

bump_version() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  NEXTVERSION=$1
  BUMP_BRANCH=$2

  git checkout "${BUMP_BRANCH}"

  echo "[INFO] Update project version to ${NEXTVERSION}"
  if updateYaml "${NEXTVERSION}" && [[ ${docommit} -eq 1 ]]; then
    COMMIT_MSG="[release] Bump to ${NEXTVERSION} in ${BUMP_BRANCH}"
    git commit -s -m "${COMMIT_MSG}" $playbookfile
    git pull origin "${BUMP_BRANCH}"

    set +e
    PUSH_TRY="$(git push origin "${BUMP_BRANCH}")"

    # shellcheck disable=SC2181
    if [[ $? -gt 0 ]] || [[ $PUSH_TRY == *"protected branch hook declined"* ]] || [[ $PUSH_TRY == *"Protected branch update"* ]]; then
    PR_BRANCH=pr-${BUMP_BRANCH}-to-${NEXTVERSION}
      # create pull request for master branch, as branch is restricted
      git branch "${PR_BRANCH}"
      git checkout "${PR_BRANCH}"
      git pull origin "${PR_BRANCH}"
      git push origin "${PR_BRANCH}"
      lastCommitComment="$(git log -1 --pretty=%B)"
      hub pull-request -f -m "${lastCommitComment}" -b "${BUMP_BRANCH}" -h "${PR_BRANCH}"
    fi 
    set -e
  fi
  git checkout "${CURRENT_BRANCH}"
}

set -x

# derive branch from version
VERSION_MAJOR=${VERSION%%.*}
VERSION_MINOR=${VERSION%.*}
VERSION_PATCH=${VERSION}
VERSION_Z=${VERSION##*.}
BRANCH=${VERSION%.*}.x
# echo "Major: $VERSION_MAJOR
# Minor: $VERSION_MINOR 
# Patch: $VERSION_PATCH 
# Z: $VERSION_Z 
# Target branch: $BRANCH"

EXISTING_BRANCH=0
# create new branch off ${BASEBRANCH} (or check out latest commits if branch already exists), then push to origin

# Handle target branch.
EXISTING_BRANCH=$(git branch --list "${BRANCH}")
case ${EXISTING_BRANCH} in
  "") echo "Branch ${BRANCH} does not exist: creating it."
     git checkout -b "${BRANCH}"
     ;;
  *) echo "Branch ${BRANCH} already exists: working on it."
     git checkout ${BRANCH}
     git pull --rebase origin master
     ;;
esac


updateYaml "${VERSION_PATCH}"
bash -c tools/checluster_docs_gen.sh
git add "/modules/installation-guide/examples/checluster-properties.adoc"
git commit -m "Updating checluster-properties.adoc for version $VERSION_PATCH"
bash -c tools/environment_docs_gen.sh
git add "modules/installation-guide/examples/system-variables.adoc"
git commit -m "Updating system-variables.adoc for version $VERSION_PATCH"
# git push
exit

# if doing a .0 release, use master; if doing a .z release, use $BRANCH
case ${VERSION_Z} in
  "0") echo "First patch version $VERSION_PATCH"
       # bump the y digit, if it is a major release
       [[ $BRANCH =~ ^([0-9]+)\.([0-9]+)\.x ]] && BASE=${BASH_REMATCH[1]}; NEXT=${BASH_REMATCH[2]}; # for BRANCH=7.25.x, get BASE=7, NEXT=25 [DO NOT BUMP]
       NEXTVERSION="${BASE}.${NEXT}.0"
       ;;
  *)  echo "Not the fist patch version"
      # bump the z digit
      [[ $VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"; NEXT="${BASH_REMATCH[3]}"; # for VERSION=7.25.2, get BASE=7.25, NEXT=2 [DO NOT BUMP]
      NEXTVERSION="${BASE}.${NEXT}"
      ;;
esac

bump_version "${NEXTVERSION}" "${MAINBRANCH}"
bump_version "${NEXTVERSION}" "${BRANCH}"
echo "[INFO] Project version has been updated"

if [[ $TAG_RELEASE -eq 1 ]]; then
  echo "[INFO] Creating release tag"
  git checkout "${BRANCH}" && git pull origin "${BRANCH}" || true
  git tag "${VERSION}"
  git push origin "${VERSION}" || true
fi

if [[ ${USE_TMP_DIR} -eq 1 ]]; then
  rm -fr "/tmp/$tmpdir"
fi

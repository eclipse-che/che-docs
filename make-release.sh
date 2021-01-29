#!/bin/bash
# Release process automation script.
# Used to create branch/tag, update versions in pom.xml
# and and trigger release by force pushing changes to the release branch

# set to 1 to actually trigger changes in the release branch
TAG_RELEASE=0 
docommit=1 # by default DO commit the change

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t'|'--trigger-release') TAG_RELEASE=1; docommit=1; shift 0;;
    '-r'|'--repo') REPO="$2"; shift 1;;
    '-v'|'--version') VERSION="$2"; shift 1;;
    '-n'|'--nocommit'|'--no-commit') docommit=0; shift 0;;
  esac
  shift 1
done

usage ()
{
  echo "
Usage: $0 --repo [GIT REPO TO EDIT] --version [VERSION TO RELEASE] 
Example: $0 --repo git@github.com:eclipse/che-docs --version 7.25.2

Options: 
  --trigger-release, -t  tag this release
  --no-commit, -n        do not commit changes to branches
"
}

if [[ ! ${VERSION} ]] || [[ ! ${REPO} ]]; then
  usage
  exit 1
else # clone into a temp folder so we don't collide with local changes to this script
  cd /tmp/ && tmpdir=tmp-${0##*/}-$VERSION && git clone $REPO $tmpdir && cd /tmp/$tmpdir
fi

# where in other repos we have a VERSION file, here we have an antora-playbook.yml file which contains some keys:
#    prod-prev-ver-major: 6 [never changes]
#    prod-ver-major: 7 [never changes]
#    prod-prev-ver: 7.24 [always prod-ver - 1]
#    prod-ver: 7.25
#    prod-ver-patch: 7.25.2
playbookfile=antora-playbook.yml
updateYaml() {
  NEWVERSION=${1}
  echo "[INFO] update $playbookfile with prod-ver = $NEWVERSION"

  [[ $NEWVERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE1="${BASH_REMATCH[1]}"; BASE2="${BASH_REMATCH[2]}"; # for VERSION=7.25.2, get BASE1=7; BASE2=25
  replaceFieldSed $playbookfile 'prod-ver' "${BASE1}.${BASE2}"
  replaceFieldSed $playbookfile 'prod-ver-patch' $NEWVERSION
  # set prod-prev-ver = 7.y-1
  (( BASE2=BASE2-1 ))
  replaceFieldSed $playbookfile 'prod-prev-ver' "${BASE1}.${BASE2}"
}

# NOTE that if using yq, comments in the file will be lost and formatting will change!
#  replaceFieldYq $playbookfile '.asciidoc.attributes."prod-ver"' $BASE
#  replaceFieldYq $playbookfile '.asciidoc.attributes."prod-ver-patch"' $NEWVERSION
replaceFieldYq()
{
  YAMLFILE=$1
  updateName=$2
  updateVal=$3
  # echo "[INFO] * ${YAMLFILE} ==> ${updateName}: ${updateVal}"
  cat ${YAMLFILE} | yq -Y --arg updateName "${updateName}" --arg updateVal "${updateVal}" \
    ${updateName}' = $updateVal' \
    > ${YAMLFILE}.2; mv ${YAMLFILE}.2 ${YAMLFILE}
}

replaceFieldSed()
{
  YAMLFILE=$1
  updateName=$2
  updateVal=$3
  # echo "[INFO] * ${YAMLFILE} ==> ${updateName}: ${updateVal}"
  sed -i ${YAMLFILE} -r -e "s#(    $updateName: ).+#\1${updateVal}#"
}

bump_version() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  NEXTVERSION=$1
  BUMP_BRANCH=$2

  git checkout ${BUMP_BRANCH}

  echo "Update project version to ${NEXTVERSION}"
  updateYaml ${NEXTVERSION}

  if [[ ${docommit} -eq 1 ]]; then
    COMMIT_MSG="[release] Bump to ${NEXTVERSION} in ${BUMP_BRANCH}"
    git commit -s -m "${COMMIT_MSG}" $playbookfile
    git pull origin "${BUMP_BRANCH}"

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
      hub pull-request -f -m "${lastCommitComment}
${lastCommitComment}" -b "${BUMP_BRANCH}" -h "${PR_BRANCH}"
    fi 
  fi
  git checkout ${CURRENT_BRANCH}
}

# derive branch from version
BRANCH=${VERSION%.*}.x

# if doing a .0 release, use master; if doing a .z release, use $BRANCH
if [[ ${VERSION} == *".0" ]]; then
  BASEBRANCH="master"
else 
  BASEBRANCH="${BRANCH}"
fi

# get sources from ${BASEBRANCH} branch
git fetch origin "${BASEBRANCH}":"${BASEBRANCH}"
git checkout "${BASEBRANCH}"

# create new branch off ${BASEBRANCH} (or check out latest commits if branch already exists), then push to origin
if [[ "${BASEBRANCH}" != "${BRANCH}" ]]; then
  git branch "${BRANCH}" || git checkout "${BRANCH}" && git pull origin "${BRANCH}"
  git push origin "${BRANCH}"
  git fetch origin "${BRANCH}:${BRANCH}"
  git checkout "${BRANCH}"
fi

# now update ${BASEBRANCH} to the new snapshot version
git fetch origin "${BASEBRANCH}":"${BASEBRANCH}"
git checkout "${BASEBRANCH}"

if [[ "${BASEBRANCH}" != "${BRANCH}" ]]; then
  # bump the y digit, if it is a major release
  [[ $BRANCH =~ ^([0-9]+)\.([0-9]+)\.x ]] && BASE=${BASH_REMATCH[1]}; NEXT=${BASH_REMATCH[2]}; # for BRANCH=7.25.x, get BASE=7, NEXT=25 [DO NOT BUMP]
  NEXTVERSION_Y="${BASE}.${NEXT}.0"
  bump_version ${NEXTVERSION_Y} ${BASEBRANCH}
  bump_version ${NEXTVERSION_Y} ${BRANCH}
else
  # bump the z digit
  [[ $VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"; NEXT="${BASH_REMATCH[3]}"; # for VERSION=7.25.2, get BASE=7.25, NEXT=2 [DO NOT BUMP]
  NEXTVERSION_Z="${BASE}.${NEXT}"
  bump_version ${NEXTVERSION_Z} ${BASEBRANCH}
  bump_version ${NEXTVERSION_Z} ${BRANCH}
fi

if [[ $TAG_RELEASE -eq 1 ]]; then
  git checkout "${BRANCH}"
  git tag "${VERSION}"
  git push origin "${VERSION}" || true
fi


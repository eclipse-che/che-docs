#!/bin/bash
# Release process automation script.
# Used to create branch/tag, update versions in pom.xml
# and and trigger release by force pushing changes to the release branch

# set to 1 to actually trigger changes in the release branch
TRIGGER_RELEASE=0 
NOCOMMIT=0

bump_version() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  NEXTVERSION=$1
  BUMP_BRANCH=$2

  git checkout ${BUMP_BRANCH}

  echo "Updating project version to ${NEXTVERSION}"
  echo ${NEXTVERSION} > VERSION

  if [[ ${NOCOMMIT} -eq 0 ]]; then
    COMMIT_MSG="[release] Bump to ${NEXTVERSION} in ${BUMP_BRANCH}"
    git commit -s -m "${COMMIT_MSG}" VERSION
    git pull origin "${BUMP_BRANCH}"

    PUSH_TRY="$(git push origin "${BUMP_BRANCH}")"
    # shellcheck disable=SC2181
    if [[ $? -gt 0 ]] || [[ $PUSH_TRY == *"protected branch hook declined"* ]]; then
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

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t'|'--trigger-release') TRIGGER_RELEASE=1; NOCOMMIT=0; shift 0;;
    '-r'|'--repo') REPO="$2"; shift 1;;
    '-v'|'--version') VERSION="$2"; shift 1;;
  esac
  shift 1
done

usage ()
{
  echo "Usage: $0 --repo [GIT REPO TO EDIT] --version [VERSION TO RELEASE] [--trigger-release]"
  echo "Example: $0 --repo git@github.com:eclipse/che-subproject --version 7.7.0 --trigger-release"; echo
}

if [[ ! ${VERSION} ]] || [[ ! ${REPO} ]]; then
  usage
  exit 1
fi

# derive branch from version
BRANCH=${VERSION%.*}.x

# if doing a .0 release, use master; if doing a .z release, use $BRANCH
if [[ ${VERSION} == *".0" ]]; then
  BASEBRANCH="master"
else 
  BASEBRANCH="${BRANCH}"
fi

# work in tmp dir
TMP=$(mktemp -d); pushd "$TMP" > /dev/null || exit 1

# get sources from ${BASEBRANCH} branch
echo "Check out ${REPO} to ${TMP}/${REPO##*/}"
git clone "${REPO}" -q
cd "${REPO##*/}" || exit 1
git fetch origin "${BASEBRANCH}":"${BASEBRANCH}"
git checkout "${BASEBRANCH}"

# create new branch off ${BASEBRANCH} (or check out latest commits if branch already exists), then push to origin
# NOTE: cico job will automatically remove -SNAPSHOT suffix in the 7.a.x branch as part of the release to Nexus
if [[ "${BASEBRANCH}" != "${BRANCH}" ]]; then
  git branch "${BRANCH}" || git checkout "${BRANCH}" && git pull origin "${BRANCH}"
  git push origin "${BRANCH}"
  git fetch origin "${BRANCH}:${BRANCH}"
  git checkout "${BRANCH}"
fi

if [[ $TRIGGER_RELEASE -eq 1 ]]; then
  # create GH release - doesn't work unless you have admin rights
  # GH_URL="https://api.github.com/repos/${REPO#*:}/releases"
  # curl -v -X POST -H "Accept: application/vnd.github.v3+json" -H 'Authorization:token '"${GITHUB_TOKEN}" \
  #   -d '{"tag_name": "'"${VERSION}"'", "target_commitish": "'"${BASEBRANCH}"'", "name": "'"${VERSION}"'", "body": "'"${VERSION}"'", "draft": "false", "prerelease": "false"}' \
  #   $GH_URL

  # or, just tag the release... which any fool can do, apparently
  git checkout "${BRANCH}"
  git tag "${VERSION}"
  git push origin "${VERSION}"
fi

# now update ${BASEBRANCH} to the new snapshot version
git fetch origin "${BASEBRANCH}":"${BASEBRANCH}"
git checkout "${BASEBRANCH}"

# infer project version + commit change into ${BASEBRANCH} branch
if [[ "${BASEBRANCH}" != "${BRANCH}" ]]; then
  # bump the y digit, if it is a major release
  [[ $BRANCH =~ ^([0-9]+)\.([0-9]+)\.x ]] && BASE=${BASH_REMATCH[1]}; NEXT=${BASH_REMATCH[2]}; (( NEXT=NEXT+1 )) # for BRANCH=7.10.x, get BASE=7, NEXT=11
  NEXTVERSION_Y="${BASE}.${NEXT}.0-SNAPSHOT"
  bump_version ${NEXTVERSION_Y} ${BASEBRANCH}
fi
# bump the z digit
[[ $VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"; NEXT="${BASH_REMATCH[3]}"; (( NEXT=NEXT+1 )) # for VERSION=7.7.1, get BASE=7.7, NEXT=2
NEXTVERSION_Z="${BASE}.${NEXT}-SNAPSHOT"
bump_version ${NEXTVERSION_Z} ${BASEBRANCH}

popd > /dev/null || exit

# cleanup tmp dir
cd /tmp && rm -fr "$TMP"

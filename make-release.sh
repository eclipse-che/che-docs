#!/bin/bash
# Release process automation script.
# Used to create branch/tag, update versions in pom.xml
# and and trigger release by force pushing changes to the release branch

# set to 1 to actually trigger changes in the release branch
TRIGGER_RELEASE=0 
NOCOMMIT=0


# where in other repos we have a VERSION file, here we have an antora-playbook.yml file which contains some keys:
#    prod-prev-ver-major: 6 [never changes]
#    prod-ver-major: 7 [never changes]
#    prod-prev-ver: 7.24
#    prod-ver: 7.25
#    prod-ver-patch: 7.25.2
playbookfile=antora-playbook.yml
updateYaml() {
  NEWVERSION=${1}; NEWVERSION=${NEWVERSION/-SNAPSHOT/}
  echo "[INFO] update $playbookfile with prod-ver = $NEWVERSION"

  prodPrevVer=$(cat $playbookfile | grep -E "    prod-ver: " | sed -r -e "s#(    prod-ver: )(.+)#\2#")
  if [[ $prodPrevVer ]]; then replaceFieldSed $playbookfile 'prod-prev-ver' $prodPrevVer; fi

  [[ $NEWVERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"; # for VERSION=7.25.2-SNAPSHOT, get BASE=7.25
  replaceFieldSed $playbookfile 'prod-ver' $BASE
  replaceFieldSed $playbookfile 'prod-ver-patch' $NEWVERSION
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

  if [[ ${NOCOMMIT} -eq 0 ]]; then
    COMMIT_MSG="[release] Bump to ${NEXTVERSION} in ${BUMP_BRANCH}"
    if [[ $docommit -eq 1 ]]; then
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
      else
        echo "[INFO] docommit = $docommit :: $COMMIT_MSG"
      fi
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

# get sources from ${BASEBRANCH} branch
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
  # or, just tag the release... which any fool can do, apparently
  git checkout "${BRANCH}"
  
  updateYaml ${VERSION}
  git commit -sm "Release version ${VERSION}" VERSION

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
bump_version ${NEXTVERSION_Z} ${BRANCH}

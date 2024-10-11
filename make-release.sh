#!/bin/bash
# Release process automation script.
# Used to create branch/tag, update versions in pom.xml
# and and trigger release by force pushing changes to the release branch

# set to 1 to actually trigger changes in the release branch
TAG_RELEASE=0
PUBLICATION_BUILDER_BRANCH="publication-builder"
DO_COMMIT=1 # by default DO commit the change
REPO=git@github.com:eclipse/che-docs
MAINBRANCH="main"
USE_TMP_DIR=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    '-t'|'--trigger-release') TAG_RELEASE=1; DO_COMMIT=1; shift 0;;
    '-v'|'--version') VERSION="$2"; shift 1;;
    '-n'|'--nocommit') DO_COMMIT=0; shift 0;;
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
  cd /tmp/ && tmpdir=tmp-${0##*/}-$VERSION && git clone $REPO $tmpdir && cd /tmp/$tmpdir
fi

# where in other repos we have a VERSION file, here we have an antora-playbook.yml file which contains some keys:
#    prod-prev-ver-major: 6 [never changes]
#    prod-ver-major: 7 [never changes]
#    prod-prev-ver: 7.24 [always prod-ver - 1]
#    prod-ver: 7.25
#    prod-ver-patch: 7.25.2
playbookfile=antora.yml
updateYaml() {
  NEWVERSION=${1}
  echo "[INFO] update $playbookfile with prod-ver = $NEWVERSION"

  [[ $NEWVERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE1="${BASH_REMATCH[1]}"; BASE2="${BASH_REMATCH[2]}"; # for VERSION=7.25.2, get BASE1=7; BASE2=25
  # prod-ver should never go down, only up
  OLDVERSION=$(cat $playbookfile | yq -r '.asciidoc.attributes."prod-ver-patch"') # existing prod-ver-patch version 7.yy.z
  VERSIONS="${OLDVERSION} ${NEWVERSION}"
  VERSIONS_SORTED="$(echo $VERSIONS | tr " " "\n" | sort -V | tr "\n" " ")"
  # echo "Compare '$VERSIONS_SORTED' with '$VERSIONS '"
  if [[ "${VERSIONS_SORTED}" != "${VERSIONS} " ]] || [[ "${OLDVERSION}" == "${NEWVERSION}" ]]; then # note trailing space after VERSIONS is required!
    echo "[WARN] Existing prod-ver ${OLDVERSION} is greater or equal than planned update to ${NEWVERSION}. Version should not go backwards, so nothing to do!"
    return 1
  else
    if [[ $(git rev-parse --abbrev-ref HEAD) == *"${BRANCH}"* ]]; then
        replaceFieldSed $playbookfile '^version' "${BRANCH}"
        replaceFieldSed $playbookfile 'prerelease' "false"
    fi
    # special fields for updating PR for 7.x.y branch
    git clone https://github.com/devfile/devworkspace-operator /tmp/dwo
    pushd /tmp/dwo
        DWO_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1) )
    popd
    replaceFieldSed $playbookfile '    devworkspace-operator-version-patch' "\"${DWO_VERSION#v}\""
    replaceFieldSed $playbookfile '    prod-ver' "\"${BASE1}.${BASE2}\""
    replaceFieldSed $playbookfile '    prod-ver-patch' "\"$NEWVERSION\""
  fi
}

playbookPublicationFile=publication-builder-antora-playbook.yml
updatePublicationYaml() {
  sed -i ${playbookPublicationFile} -r -e "s#- 7.*.x#- ${BRANCH}#"
}

replaceFieldSed()
{
  YAMLFILE=$1
  updateName=$2
  updateVal=$3
  # echo "[INFO] * ${YAMLFILE} ==> ${updateName}: ${updateVal}"
  sed -i ${YAMLFILE} -r -e "s#($updateName: ).+#\1${updateVal}#"
}

bump_branch() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)

  local base_branch=$1
  git checkout "${base_branch}"
  local pr_branch="pr-${base_branch}-to-${NEXTVERSION}"
  git branch "${pr_branch}"
  git checkout "${pr_branch}"

  echo "[INFO] Update project version to ${NEXTVERSION}"
  if updateYaml "${NEXTVERSION}" && [[ ${DO_COMMIT} -eq 1 ]]; then
    commit_and_create_pr \
      "$playbookfile" \
      "${pr_branch}" \
      "${base_branch}" \
      "chore: Bump to ${NEXTVERSION} in ${base_branch}"
  fi
  git checkout ${current_branch}
}

bump_publication_builder_branch() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)

  git checkout "${PUBLICATION_BUILDER_BRANCH}"
  local pr_branch="pr-${PUBLICATION_BUILDER_BRANCH}-to-${BRANCH}"
  git branch "${pr_branch}"
  git checkout "${pr_branch}"

  echo "[INFO] Update project version to ${NEXTVERSION}"
  if updatePublicationYaml "${NEXTVERSION}" && [[ ${DO_COMMIT} -eq 1 ]]; then
    commit_and_create_pr \
      "$playbookPublicationFile" \
      "pr-${PUBLICATION_BUILDER_BRANCH}-to-${BRANCH}" \
      "${PUBLICATION_BUILDER_BRANCH}" \
      "chore: Bump to ${BRANCH} in ${PUBLICATION_BUILDER_BRANCH}"
  fi
  git checkout "$current_branch"
}

commit_and_create_pr() {
  local pr_files_to_commit=$1
  local pr_head_branch=$2
  local pr_base_branch=$3
  local pr_commit_message=$4

  local pr_body_message

  pr_body_message=$(cat <<-END
## What does this pull request change?
Bump up the Che version to the latest release for the ${pr_base_branch} branch.

## Specify the version of the product this pull request applies to
Merge to ${pr_base_branch}"
END
)

  git checkout "$pr_head_branch"

  git commit -s -m "${pr_commit_message}" "$pr_files_to_commit"
  git push origin "${pr_head_branch}"
    
  gh pr create -f -t "${pr_commit_message}" -b "${pr_body_message}" -B "${pr_base_branch}" -H "${pr_head_branch}"
}

init_variables () {
  # derive branch from version
  BRANCH=${VERSION%.*}.x

  EXISTING_BRANCH=0
  # create new branch off ${BASEBRANCH} (or check out latest commits if branch already exists), then push to origin
  if [[ ${VERSION} == *".0" ]]; then
    # note: if branch already exists, do not recreate it!
    if [[ $(git branch "${BRANCH}" 2>&1 || true) == *"already exists"* ]]; then
      EXISTING_BRANCH=1
    fi

    if [[ ${EXISTING_BRANCH} -eq 0 ]]; then
      git push origin "${BRANCH}"
    fi
  fi

  # if doing a .0 release, use main; if doing a .z release, use $BRANCH
  if [[ ${VERSION} == *".0" ]]; then
    # bump the y digit, if it is a major release
    [[ $BRANCH =~ ^([0-9]+)\.([0-9]+)\.x ]] && BASE=${BASH_REMATCH[1]}; NEXT=${BASH_REMATCH[2]}; # for BRANCH=7.25.x, get BASE=7, NEXT=25 [DO NOT BUMP]
    NEXTVERSION="${BASE}.${NEXT}.0"
  else
    # bump the z digit
    [[ $VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]] && BASE="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"; NEXT="${BASH_REMATCH[3]}"; # for VERSION=7.25.2, get BASE=7.25, NEXT=2 [DO NOT BUMP]
    NEXTVERSION="${BASE}.${NEXT}"
  fi
}

set -x

init_variables
bump_branch "${BRANCH}"
bump_branch "${MAINBRANCH}"
bump_publication_builder_branch
echo "[INFO] Project version has been updated"

if [[ $TAG_RELEASE -eq 1 ]]; then
  echo "[INFO] Creating release tag"
  git checkout "${BRANCH}" && git pull origin "${BRANCH}" || true
  git tag "${VERSION}"
  git push origin "${VERSION}" || true
fi

if [[ ${USE_TMP_DIR} -eq 1 ]]; then
  rm -fr /tmp/$tmpdir
fi

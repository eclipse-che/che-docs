#!/usr/bin/env bash

# Run once to migrate from Jekyll to Antora.

# Exit on any error
set -e

# Variables for the project
WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOTDIR="${WORKDIR%tools/antora-migration*}"
MODULES_DIR="${ROOTDIR}modules"
MODULES="administration-guide contributor-guide end-user-guide extensions installation-guide overview"
SRC_NAV="${ROOTDIR}src/main/_data/sidebars/che_7_docs.yml"
SUBS_XREF="${WORKDIR}/substitutions-xref.sed"

function cleanup_dest {
    echo "* cleaning up directories"
    rm -rf "${GUIDE_DEST_PATH}"
    mkdir -p "${GUIDE_DEST_PATH}/attachments" "${GUIDE_DEST_PATH}/examples" "${GUIDE_DEST_PATH}/images" "${GUIDE_DEST_PATH}/pages" "${GUIDE_DEST_PATH}/partials" 
    touch  "${GUIDE_DEST_PATH}/attachments/.placeholder" "${GUIDE_DEST_PATH}/examples/.placeholder" "${GUIDE_DEST_PATH}/images/.placeholder" "${GUIDE_DEST_PATH}/pages/.placeholder" "${GUIDE_DEST_PATH}/partials/.placeholder"
}

function generate_nav {
    echo "* generating navigation"
    jinja2 "${WORKDIR}/nav.j2" \
        "${WORKDIR}/pagesvars.yaml" \
        -D target="${GUIDE}" \
        > "${GUIDE_DEST_NAV}"

    jinja2 "${WORKDIR}/pagesvars.j2" \
        "${WORKDIR}/pagesvars.yaml" \
        -D target="${GUIDE}" \
        > "${WORKDIR}/pagesvars-${GUIDE}.yaml"
}

function generate_pages {
    echo "* generating pages"
    grep xref "${GUIDE_DEST_NAV}" | \
        cut -d. -f 1 | \
        cut -d: -f 2 | \
        xargs -r -n1 -I'{}' \
        jinja2 "${WORKDIR}/page.j2" \
            "${WORKDIR}/pagesvars-${GUIDE}.yaml" \
            -D target="${GUIDE}" \
            -D page="{}" \
            -o "${GUIDE_DEST_PAGES}/{}.adoc"
}

function copy_partials {
    echo "* copying partials"
    grep -ire 'adoc' "${GUIDE_DEST_PAGES}" | \
        cut -d[ -f 1 | \
        cut -d$ -f 2 | \
        xargs -r -n1 -I'{}' \
        atree -b -h "${GUIDE_SRC_PATH}/{}" | \
            grep adoc | \
            xargs -r -n1 -I'@@' \
            cp -f '@@' "${GUIDE_DEST_PARTIALS}"
}

function copy_images {
    echo "* copying images"
    # Create target directories for images
    grep -ire 'image:.\?*\[' "${GUIDE_SRC_PATH}" | \
        grep -v https | \
        sed 's@.*image:@@;s@:@@;s@\/.*@@;s@{project-context}@che@g;s@{imagesdir}@@g' | \
        sort | \
        uniq | \
        xargs -r -n1 -I'{}' \
        mkdir -p "${GUIDE_DEST_IMAGES}{}"

    # "Copying images to ${GUIDE_DEST_IMAGES}"
    # (We must copy some twice, example: architecture/che-high-level.png)
    grep -ire 'image:.\?*\[' "${GUIDE_SRC_PATH}" | \
        grep -v https |\
        sed 's@.*image:@@;s@:@@;s@\[.*@@;s@{project-context}@che@g;s@{imagesdir}\/@@g' | \
        xargs -r -n1 -I'{}' \
        cp -f -T "${ROOTDIR}src/main/images/{}" "${GUIDE_DEST_IMAGES}{}" 
}

function copy_examples {
    echo "* copying examples"
    # Creating target directories for examples
    grep -ire 'include::examples/.*/' "${GUIDE_SRC_PATH}" | \
        sed -E 's@.*examples/(.?*)/.*@\1@' | \
        sort | \
        uniq | \
        xargs -r -n1 -I'{}' \
        mkdir -p "${GUIDE_DEST_PATH}/examples/{}"
    
    # Copying examples
    # To execute before link: to xref: substitutions
    grep -ire 'include::example' "${GUIDE_SRC_PATH}" | \
        cut -d[ -f 1 | \
        cut -d: -f4 | \
        sed 's@{project-context}@che@g' | \
        xargs -r -n1 -I'{}' \
        cp -f -T "${GUIDE_SRC_PATH}/{}" "${GUIDE_DEST_PATH}/{}" 
}

function prepare_substitutions {
    # Run it only once.

    # Remove Jekyll Headers
    # Handle include statements for Partials, Examples, Images
    # First step for link: to xref:
    find "${MODULES_DIR}" -name "*.adoc" -exec \
        sed -E -i -f "${WORKDIR}/antora-substitutions.sed" {} +

    # It leaves us with xref:<id>[] or xref:<id>#<anchor>_{context}[]
    # We need to add the .adoc extension
    # We need to add the guide name for cross guides references
    
    # Generate substitutions file to add guide name in all xref statements.
    find "${MODULES_DIR}" -name "*.adoc" | sort | \
        sed -E "
            s@.*\/nav\.adoc@@
            s@.?*modules\/(.?*)\/.?*\/(.?*)@s|xref:\2(\[\\\[#\])|xref:\1:\2\\\\1|@;\
            s@\.adoc@@
            s@con_@@
            s@proc_@@
            s@assembly_@@
            " - \
        > "${SUBS_XREF}"
    find "${MODULES_DIR}" -name "*.adoc" | sort  | \
        sed -E "
            s@.*\/nav\.adoc@@
            s@.?*modules\/(.?*)\/.?*\/(.?*)@s|xref:\2_\\\{context\\\}|xref:\1:\2|@;\
            s@\.adoc@@
            s@con_@@
            s@proc_@@
            s@assembly_@@
            " - \
        >> "${SUBS_XREF}"

}


function substitutions {
    echo "* substitutions"

    # Generate substitutions file for ${GUIDE} to add guide name only when relevant.
    SUBS_XREF_GUIDE="${WORKDIR}/substitutions-xref-${GUIDE}.sed"
    sed -E "s@${GUIDE}:@@" "${SUBS_XREF}" > "${SUBS_XREF_GUIDE}"

    # Add guide name in xref (step 2 execute subs)
    find "${GUIDE_DEST_PARTIALS}" -name "*.adoc" -exec \
        sed -E -i -f "${SUBS_XREF_GUIDE}" {} +
    find "${GUIDE_DEST_EXAMPLES}" -name "*.adoc" -exec \
        sed -E -i -f "${SUBS_XREF_GUIDE}" {} +
}

function map_permalink_to_file {
    # Create a permalink to file name map. Usage: generate navigation, transform links into xrefs.

    grep "permalink:" -T "${ROOTDIR}"/src/main/pages/che-7/*/*.adoc |\
        sed -E 's@.*/([^/]*.adoc).*permalink.*che-7/(.*[^/]).*@map: \n  - {url: \2,  file: \1}@' |\
        sort | uniq \
        > "${WORKDIR}/filesmap.yaml"

    cat "${SRC_NAV}" "${WORKDIR}/filesmap.yaml" "${WORKDIR}/aliases.yaml" \
        > "${WORKDIR}/pagesvars.yaml"

}

function migrate_guide_copy {
    echo "Migrating ${GUIDE}, preliminary step"

    GUIDE_SRC_PATH="${ROOTDIR}src/main/pages/che-7/${GUIDE}"
    GUIDE_DEST_PATH="${MODULES_DIR}/${GUIDE}"
    GUIDE_DEST_NAV="${GUIDE_DEST_PATH}/nav.adoc"
    GUIDE_DEST_EXAMPLES="${GUIDE_DEST_PATH}/examples/"
    GUIDE_DEST_IMAGES="${GUIDE_DEST_PATH}/images/"
    GUIDE_DEST_PAGES="${GUIDE_DEST_PATH}/pages/"
    GUIDE_DEST_PARTIALS="${GUIDE_DEST_PATH}/partials/"

    cleanup_dest
    generate_nav
    generate_pages
    copy_partials
    copy_images
    copy_examples
}

function migrate_guide_subs {
    echo "Migrating ${GUIDE}, final step"

    GUIDE_SRC_PATH="${ROOTDIR}src/main/pages/che-7/${GUIDE}"
    GUIDE_DEST_PATH="${MODULES_DIR}/${GUIDE}"
    GUIDE_DEST_NAV="${GUIDE_DEST_PATH}/nav.adoc"
    GUIDE_DEST_EXAMPLES="${GUIDE_DEST_PATH}/examples/"
    GUIDE_DEST_IMAGES="${GUIDE_DEST_PATH}/images/"
    GUIDE_DEST_PAGES="${GUIDE_DEST_PATH}/pages/"
    GUIDE_DEST_PARTIALS="${GUIDE_DEST_PATH}/partials/"

    substitutions
}

cd "$WORKDIR"
map_permalink_to_file
for GUIDE in ${MODULES}
    do
    migrate_guide_copy

done
prepare_substitutions
for GUIDE in ${MODULES}
    do
    migrate_guide_subs
done

${ROOTDIR}/tools/verify_xrefs.sh "${MODULES_DIR}"

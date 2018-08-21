---
title: "Release: 6.10.0"
keywords: release notes
sidebar: rn_sidebar
permalink: release-${VERSION}.html
folder: release_notes
---
{% include links.html %}

## Release Summary

Eclipse Che {version} includes:
- **Feature1**: Quick value description
- **Feature2**: Quick value description
- ...

## Upgrade

Instruction how to upgrade

---

## Release Details

### Secure Servers (#ISSUE)
Eclipse Che extension developers might be interested in a new feature - "Secure Servers"
It can be useful if you want to protect your web-based tool, that running as part of a workspace with Che authentification.

Example:
```json
"tooling": {
    "port": "4921",
    "protocol": "http",
    "attributes": {
        "secure": "true",
        "unsecuredPaths": "/liveness",
        "cookiesAuthEnabled": "true"
    }
}
```
For an example, take a look at the [demo](https://www.youtube.com/watch?v=or0CWHAVR4Q).


### Feature2 (#ISSUE)

{image / animated gif}

Feature description focusing on value to the user or contributor.

Learn more in the documentation: {Link to the documentation}


## Other Notable Enhancements

- Issue title. (#ISSUE)


## Notable Bug Fixes

- Fixed issue's title. (#ISSUE)

## Community Thank You!

We’d like to say a big thank you to everyone who helped to make Che even better:
- {Contributor Name} -- {Company} -- (#PR): PR Title

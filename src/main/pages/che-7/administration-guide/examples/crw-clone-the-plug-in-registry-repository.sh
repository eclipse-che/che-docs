$ podman login registry.redhat.io
Username: ${REGISTRY-SERVICE-ACCOUNT-USERNAME}
Password: ${REGISTRY-SERVICE-ACCOUNT-PASSWORD}
Login Succeeded!

$ podman pull registry.redhat.io/codeready-workspaces/pluginregistry-rhel8
$ cd codeready-workspaces/pluginregistry-rhel8

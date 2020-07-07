#!/bin/sed -i -f

# Replace long and short project name by an attribute
s/Eclipse Che\b/{prod}/g
s/\bChe\b/{prod-short}/g

# Put back hardcoded project name in Jekyll headers which doesn't understand attributes
# Run twice: we may have 2 occurences in a title
s/\(\(title:\|tags:\)\(.*\?\)\){prod-short}/\1Che/
s/\(\(title:\|tags:\)\(.*\?\)\){prod-short}/\1Che/
s/\(\(title:\|tags:\)\(.*\?\)\){prod}/\1Eclipse Che/
s/\(\(title:\|tags:\)\(.*\?\)\){prod}/\1Eclipse Che/

# Replace project id by an attribute
# Run twice: we may have 2 occurences in the same id
s/\(\(\[id=\|xref\|<<\).*\)\bche\b/\1{prod-id-short}/g
s/\(\(\[id=\|xref\|<<\).*\)\bche\b/\1{prod-id-short}/g

# Replace version numbers
s/\({prod-id-short}-\|{prod-short} \|{prod} \)6/\1{prod-prev-ver}/g
s/\({prod-id-short}-\|{prod-short} \|{prod} \)7/\1{prod-ver}/g

# Revert back baseurl in xref to hardcoded values
s/{site-baseurl}{prod-id-short}-{prod-ver}/{site-baseurl}che-7/g

# Revert back Che-Theia
s/{prod-short}-Theia/Che-Theia/g
s/{prod-id-short}-theia/che-theia/g

# Revert back Hosted Che
s/Hosted {prod-short}/Hosted Che/g
s/hosted-{prod-id-short}/hosted-che/g
s/{prod} hosted by Red Hat/Eclipse Che hosted by Red Hat/

# Revert back {prod-short} plug-ins types: `type: Che Plugin` `Che Editor`
s/{prod-short} Plugin/Che Plugin/g
s/\*Che Plugins\* panel/*{prod-short} Plugins* panel/g
s/Che Plugin metadata/{prod-short} plug-in metadata/g
s/Che Plugin registry/{prod-short} plug-in registry/g
#s/metadata of Che Plugin/metadata of {prod-short} plug-in/g
s/{prod-short} Editor/Che Editor/g

# Replace version numbers
s/\({prod-id-short}-\|{prod-short} \|{prod} \)6/\1{prod-prev-ver}/g
s/\({prod-id-short}-\|{prod-short} \|{prod} \)7/\1{prod-ver}/g

# Replace with care chectl by prod-cli attribute.
s/\bchectl\b/{prod-cli}/g
s/\bchectl_/{prod-cli}_/g
# Revert chectl in file names
s/\(include::.*\?\){prod-cli}/\1chectl/g
# Revert chectl in attributes names
s/\(:parent.*\?\){prod-cli}/\1chectl/g
s/\(:parent.*\?\){prod-cli}/\1chectl/g
s/\({parent[^}]*\){prod-cli}/\1chectl/g
# Revert chectl in jekyll headers
s/\(title:[^\[]*\){prod-cli}/\1chectl/g
s/\(permalink:[^\[]*\){prod-cli}/\1chectl/g

s/config map/ConfigMap/g
s/custom resource/Custom Resource/g
s/the operator/the Operator/
s/the {prod-short} operator/the {prod-short} Operator/

s/ namespace / {orch-namespace} /g
s/ namespace\./ {orch-namespace}./g
s/ namespace,/ {orch-namespace},/g
s/ namespaces/ {orch-namespace}s/g
s/oc create {orch-namespace}/oc create namespace/g
s/oc label {orch-namespace}/oc label namespace/g
s/kubectl create {orch-namespace}/kubectl create namespace/g
s/kubectl label {orch-namespace}/kubectl label namespace/g
s/\(API.*\?\){orch-namespace}/\1namespace/g
s/{orch-namespace}\(.*\?API\)/namespace\1/g
s/\(theia.*\?\){orch-namespace}/\1namespace/g
s/\(^title:.*\?\){orch-namespace}/\1namespace/g

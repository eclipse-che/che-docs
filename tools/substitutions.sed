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

# Revert back {prod-short} plug-ins types: `type: Che Plugin` `Che Editor`
s/{prod-short} plug-in\b/Che Plugin/g
s/{prod-short} Plugin\b/Che Plugin/g
s/Che Plugin metadata/{prod-short} plug-in metadata/g
s/Che Plugin registry/{prod-short} plug-in registry/g
#s/metadata of Che Plugin/metadata of {prod-short} plug-in/g
s/{prod-short} Editor/Che Editor/g

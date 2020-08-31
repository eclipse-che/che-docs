# Fix fa icon
s@icon:fa-@icon:@

# Remove Jekyll headers
1 s/^---$/---===ooo===---/; /---===ooo===---/,/^---$/d
s@:page-liquid:@@

# Partials
# Add "partial$" in include statements.
s@include::assembly_@include::partial$assembly_@
s@include::con_@include::partial$con_@
s@include::proc_@include::partial$proc_@
s@include::ref_@include::partial$ref_@

# Examples
# Handle "example$" include statements
s@include::examples/@include::example$@

# Images
s@\{imagesdir\}\/@@g
s@link="@link="../_images/@
# Revert back one external link.
s@link="../_images/https@link="https@

############

# Transform link: to xref:<filename>.adoc#<anchor>[]
# We need another step to add guide in cross guide references

# Handle link:{site-baseurl}che-7[]
s@link:\{site-baseurl\}che-7\[.?*\]@link:https://www.eclipse.org/che/docs[Eclipse Che]@

# Fix content
 s@\[prod-short\}@\{prod-short\}@

# Transform any occurrence of link:{site-baseurl} (with or without /) into xref.

s@link:\{site-baseurl\}che-7(.?*)\[.?*\]@xref:\1[]@g
s@link:\{site-baseurl\}che-7(.?*)\[.?*\]@xref:\1[]@g
s@link:\{site-baseurl\}/che-7(.?*)\[.?*\]@xref:\1[]@g

# Replace {prod-id-short} in xref:
s@(xref:.?*)\{prod-id-short\}@\1che@g

# Replace {prod-cli} in xref:
s@(xref:.?*)\{prod-cli\}@\1chectl@g

# Remove slashes in xref
s@(xref:)/(.?*\[)@\1\2@g
s@(xref:)/(.?*\[)@\1\2@g
s@(xref:.?*)/@\1@g
s@(xref:.?*)/@\1@g

# Fix "_{context}"
s@(xref:.?*_).?*\[@\1\{context\}\[@g

# So now we have xref:<id>[] or xref:<id>#<anchor_{context}[]
# We need to add the adoc extension, and for cross guide references the guide name

# Fix broken ids in xrefs

s@xref:advanced-configuration-options\[@xref:configuring-the-che-installation\[@

# s@xref:creating-and-configuring-a-new-workspace@xref:creating-and-configuring-a-new-che-7-workspace@

s@xref:installing-the-chectl-management-tool@xref:using-the-chectl-management-tool@

s@xref:kubernetes-image-puller-configuration@xref:image-puller-configuration_{context}@

s@xref:deploying-the-kubernetes-image-puller-using-helm@xref:deploying-image-puller-using-helm@

s@xref:additional-tools-in-the-che-workspace@xref:additional-tools-in-the-che-workspace_{context}@

s@xref:adding-language-support-plug-in-to-the-che-workspace@xref:adding-language-support-plug-in-to-the-che-workspace_{context}@

s@xref:what-is-a-che-theia-plugin@xref:what-is-a-che-theia-plug-in@

s@xref:supported-platforms@xref:supported_platforms@

s@xref:installing-che-on-bare-metal-using-kubespray@xref:installing-che-on-kubespray@

s@xref:installing-che-on-openshift-4-from-operatorhub@xref:installing-che-on-openshift-4-using-operatorhub@

s@xref:installing-ingress-on-azure@xref:installing-ingress-on-azure-{context}@

s@xref:run-chectl-on-kind@xref:installing-che-on-kind.adoc#run-chectl-on-kind@

s@xref:supported_platforms@xref:supported-platforms@

s@xref:using-different-type-of-storage@xref:using-different-type-of-storage@

# Fix link:https:che.openshift.io
s@https:che@https://che@

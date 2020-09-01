# Transform link: to xref:XXXidXXX, ready for id to filename substitutions
# Must happen before other substitutions.
#s@link:\({site-baseurl}che-7/\|#\)\([^[]*\)/\(.*\?\[[^]]*\]\)@xref:XXX\2XXX\3@
#s@link:\({site-baseurl}/che-7/\|#\)\([^[]*\)/\(.*\?\[[^]]*\]\)@xref:XXX\2XXX\3@
#s@link:\({site-baseurl}che-7/\|#\)\([^[]*\)\[\([^]]*\)\]@xref:XXX\2XXX\[\3\]@
#s@link:\({site-baseurl}/che-7/\|#\)\([^[]*\)\[\([^]]*\)\]@xref:XXX\2XXX\[\3\]@



# Ad-hoc fixes for links with improper ids

s@XXXchecking-important-logs_viewing-logs-from-language-servers-and-debug-adaptersXXX@XXXviewing-che-server-logsXXX@

s@XXXcollecting-logs-using-{prod-cli}@XXXcollecting-logs-using-chectl@

s@XXXinstalling-the-{prod-cli}-management-tool@XXXinstalling-the-chectl-management-tool@

s@XXXinstalling-{prod-id-short}-in-tls-mode-with-self-signed-certificates@XXXinstalling-che-in-tls-mode-with-self-signed-certificates@

s@XXXincluding-a-kubernetes-application-in-a-workspace-devfile-definition_{context}XXX@XXXmaking-a-workspace-portable-using-a-devfileXXX@

s@XXXadding-a-kubernetes-application-to-an-existing-workspace-using-the-dashboard_{context}XXX@XXXnavigating-che-using-the-dashboardXXX@

s@XXXgenerating-a-devfile-from-an-existing-kubernetes-application_{context}XXX@XXXediting-a-devfile-and-plug-in-at-runtimeXXX@

s@XXXadditional-tools-in-the-che-workspaceXXX@XXXadding-tools-to-che-after-creating-a-workspaceXXX@

s@XXXadding-language-support-plug-in-to-the-che-workspaceXXX@XXXadding-support-for-a-new-languageXXX@

s@XXXusing-alternative-ides-in-{prod-id-short}XXX@XXXusing-alternative-ides-in-cheXXX@

s@XXXusing-a-visual-studio-code-extension-in-{prod-id-short}XXX@XXXusing-a-visual-studio-code-extension-in-cheXXX@

s@XXXmaking-a-workspace-portable-using-a-devfile_using-developer-environments-workspacesXXX@XXXmaking-a-workspace-portable-using-a-devfileXXX@

s@link:{site-baseurl}che-7@link:https://www.eclipse.org/che/docs/@

s@xref:what-is-eclipse-{prod-id-short}@xref:what-is-eclipse-che_{context}@

s@XXXhigh-level-{prod-id-short}-architectureXXX@XXXhigh-level-che-architectureXXX@

s@XXXupgrading-the-{prod-cli}-management-tool_{context}XXX@upgrading-the-chectl-management-tool_{context}@

s@XXXinstalling-the-chectl-management-tool-on-windows_{context}XXX@installing-the-chectl-management-tool-on-windows_{context}@

s@XXXinstalling-the-chectl-management-tool-on-linux-or-macos_{context}XXX@installing-the-chectl-management-tool-on-linux-or-macos_{context}@

s@XXXupgrading-the-{prod-cli}-management-tool_{context}XXX@upgrading-the-{prod-cli}-management-tool_{context}@

s@XXXmounting-custom-ssl-certificates-to-che-workspace-podsXXX@mounting-custom-ssl-certificates-to-{prod-id-short}-workspace-pods_{context}@

# End of link: to xref: substitutions.





# Pages includes
s@include::../../overview/pages/@include::overview:partial$@


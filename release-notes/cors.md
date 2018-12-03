

## New Tomcat and CORS security issue 

Tomcat 8.5.32 introduced changes to CORS filter that will disallow it's usage with following configuration:
```
cors.support.credentials=true
cors.allowed.origins=*
```

More info at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

Currently we use CORS filters with such configuration on Che for WS Master and WS Agent Tomcats. 
While it is allowed to run such configuration in Tomcat versions prior to 8.5.32,
attempting to run in on newer versions will result in exception an failure of start.

## Adding ability to change CORS authentication

We plan to upgrade Tomcat from 8.5.23 to 8.5.35 and change the CORS configuration for WS Master and WS Agent:
 
- WS Master - CORS Filter disabled
- WS Agent - CORS Filter enabled, allowing requests with credentials, providing Domain of WS Master as an allowed origin

Before these changes will happen in Che 6.16, there will be an opportunity to test new configuration in Che 6.15.
We want you to try this configuration. 

## Enabling new configuration in Che 6.15

Steps to apply the given configuration for WS Master and WS Agent:

1) use `CHE_CORS_ENABLED=false` environment variable for Che deployment to disable CORS on WS Master.
2) use `CHE_WSAGENT_CORS_ALLOWED__ORIGINS=<wsmaster-domain>` to set the default allowed origin of WS Agent CORS pointing to Domain of WS Master (replace `<wsmaster-domain>` with actual Domain value)
Setting origin for WS Agent would be later done automatically in PR for Upgrading Tomcat.

**If you discover an regression related to this configuration (e.g. errors related to not suitable CORS configuration).
Please reach out to us describing the issues you have.**

Additionally, here is the full list of environment vairables, that are introduced in 6.15 for configuring CORS filter (https://github.com/eclipse/che/issues/12058), should you want to try other configurations:
You can use them, to tryo your own CORS configuration for WS Master (by applying following variables to Che deployemt), or WS Agent (by applying them to Che Workspace configuration)

- `CHE_CORS_ENABLED` - if true, enables CORS filter (default "true"). Works only for WS Master.
- `CHE_CORS_ALLOW__CREDENTIALS` - "cors.support.credentials" property for CORS filter (default "true")
- `CHE_CORS_ALLOWED__ORIGINS` - "cors.allowed.origins" property for CORS filter, to define allowed origins for requests (default "*")




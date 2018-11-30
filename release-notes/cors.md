

## New Tomcat and CORS security issue 

Tomcat 8.5.32 introduced changes to CORS filter that will disallow it's usage with following configuration:
```
cors.support.credentials=true
cors.allowed.origins=*
```

More info at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

Currently we use CORS filters with such configuration on Che for WS Master and WS Agent Tomcats. 
Attempting to use a CORS filter with such configuration will result in exception.

## Adding ability to change CORS authentication 

in Che 6.15, a possibility will be added to override certain parameters of CORS filter https://github.com/eclipse/che/issues/12058
- `CHE_CORS_ENABLED` - if true, enables CORS filter for WS Master (default "true").
- `CHE_CORS_ALLOW__CREDENTIALS` - "cors.support.credentials" property for CORS filter (default "true")
- `CHE_CORS_ALLOWED__ORIGINS` - "cors.allowed.origins" property for CORS filter, to define allowed origins for requests (default "*")

So, defaults CORS settings and Tomcat version will remain the same in 6.15.

## Testing new Configuration before upgrading Tomcat

We want to test in all following configuration for Che WS Master and WS Agent:

- WS Master - CORS Filter disabled
- WS Agent - CORS Filter enabled, allowing requests with credentials, providing Domain of WS Master as an allowed origin

Steps to apply the given configuration:

1) use `CHE_CORS_ENABLED=false` environment variable for Che deployment
2) For Che Workspaces, add an environment variable for workspace configuration to configure allowed origin of your WS Master domain: `CHE_CORS_ALLOWED__ORIGINS=<http://che-eclipse-che.127.0.0.1.nip.io>` 
Setting origin for WS Agent would be later done automatically in PR for Upgrading Tomcat.

If there is a need to try other configuration (for example, you may still need CORS filter for WS Master)
You can try using other variants, either with disabled support for request with credentials, or providing a "non-wildcard" allowed origin(s) for CORS Filter.

We plan to change CORS configuration and upgrade Tomcat to 8.5.35 for Che 6.16 release.
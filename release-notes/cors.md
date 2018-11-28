

## New Tomcat and CORS security issue 

Tomcat 8.5.32 introduced changes to CORS filter that will disallow it's usage with following configuration:
```
cors.support.credentials=true
cors.allowed.origins=*
```

More info at https://bz.apache.org/bugzilla/show_bug.cgi?id=62343 

Currently we use CORS filters with such configuration on Che for WS Master and WS Agent Tomcats. 
Attempting to use a CORS filter with such configuration will result in exception.

## Adding properties to change CORS authentication 

in Che 6.15, a possibility will be added to override certain parameters of CORS filter https://github.com/eclipse/che/issues/12058
so tha values for `cors.credential.support` and `cors.allowed.origin` via corresponding env.variables (che properties)

while this ability will be added, CORS settings and Tomcat version will remain the same.

## Upgrading Tomcat & CORS configuration

In version 6.16, we intend to test the following configuration:

```
cors.support.credentials=false
cors.allowed.origins=*
```

This configuration can be set through environment variables `CHE_CORS_ALLOWED__ORIGINS` `CHE_CORS_SUPPORT__CREDENTIALS` for Openshift/Kubernetes deployments of Che

In 6.17 Tomcat is planned to be upgraded, and this configuration will be applied as well

